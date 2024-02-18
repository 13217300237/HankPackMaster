class UploadPlatform {
  final String name;
  final int index;

  const UploadPlatform._(this.name, this.index);

  static const UploadPlatform pgy = UploadPlatform._('蒲公英平台', 0);
  static const UploadPlatform hwobs = UploadPlatform._('华为obs平台', 1);

  static String findNameByIndex(String index) {
    for (var e in uploadPlatforms) {
      if ("${e.index}" == index) {
        return e.name;
      }
    }

    return "";
  }
}

List<UploadPlatform> uploadPlatforms = [
  UploadPlatform.pgy,
  UploadPlatform.hwobs
];
