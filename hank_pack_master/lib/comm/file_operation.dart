import 'dart:convert';
import 'dart:io';

import 'package:fluent_ui/fluent_ui.dart';

///
/// [path] 指定路径
/// [outputList] 输入数组
void searchForAPKFiles(String path, List<String> apkFilePaths) {
  final dir = Directory(path);
  dir.list(recursive: true).listen((fileSystemEntity) {
    if (fileSystemEntity is File) {
      if (fileSystemEntity.path.endsWith('.apk')) {
        apkFilePaths.add(fileSystemEntity.path);
      }
    } else if (fileSystemEntity is Directory) {
      searchForAPKFiles(fileSystemEntity.path, apkFilePaths);
    }
  });
}

Future<List<String>> findApkFiles(String folderPath) async {
  List<String> apkFilePaths = [];

  // 遍历文件夹中的文件
  Directory folder = Directory(folderPath);
  if (!(await folder.exists())) {
    debugPrint("folderPath-> $folderPath 目录不存在");
    return apkFilePaths;
  }

  List<FileSystemEntity> files = folder.listSync(recursive: false);

  for (var file in files) {
    // 检查文件是否为apk文件
    if (file.path.endsWith('.apk')) {
      // 检查文件修改时间
      FileStat stat = await file.stat();
      Duration timeDiff = DateTime.now().difference(stat.modified);

      // 判断修改时间是否在10分钟以内
      if (timeDiff.inMinutes <= 10) {
        apkFilePaths.add(file.path); // 将符合条件的apk文件路径添加到列表中
      }
    }
  }

  return apkFilePaths;
}

Future<List<String>?> readLinesWithEncoding(
    File file, Encoding encoding) async {
  try {
    final lines = await file.readAsLines(encoding: encoding);
    return lines;
  } catch (e) {
    return null;
  }
}

Future<String?> updateGradleProperties(
    File gradleFile, String key, String value) async {
  if (!gradleFile.existsSync()) {
    return 'gradle.properties文件不存在';
  }

  List<String>? lines = await readLinesWithEncoding(gradleFile, utf8);
  lines ??= await readLinesWithEncoding(gradleFile, latin1);
  if (lines == null) {
    return 'utf8/latin1 编码均无法解析该 gradle.properties 文件';
  }
  bool keyExists = false;

  for (int i = 0; i < lines.length; i++) {
    String line = lines[i];
    if (line.startsWith('$key=')) {
      lines[i] = '$key=$value';
      keyExists = true;
      break;
    }
  }

  if (!keyExists) {
    lines.add('$key=$value');
  }

  gradleFile.writeAsStringSync(lines.join('\n'));
  return null;
}
