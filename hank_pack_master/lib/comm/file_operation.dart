import 'dart:io';

Future<List<String>> findApkFiles(String folderPath) async {
  List<String> apkFilePaths = [];

  // 遍历文件夹中的文件
  Directory folder = Directory(folderPath);
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
