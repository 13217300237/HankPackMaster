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

List<File> findApkFiles(String folderPath) {
  List<File> apkFiles = [];
  Directory directory = Directory(folderPath);

  if (directory.existsSync()) {
    _explore(directory, apkFiles);
  } else {
    print('文件夹不存在: $folderPath');
  }

  return apkFiles;
}

void _explore(Directory directory, List<File> apkFiles) {
  List<FileSystemEntity> entities = directory.listSync();

  for (FileSystemEntity entity in entities) {
    if (entity is File && entity.path.toLowerCase().endsWith('.apk')) {
      apkFiles.add(entity);
    } else if (entity is Directory) {
      _explore(entity, apkFiles);
    }
  }
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
