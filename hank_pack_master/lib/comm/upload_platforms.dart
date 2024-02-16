

class UploadPlatform {
  final String name;
  final int index;

  const UploadPlatform._(this.name, this.index);

  static const UploadPlatform pgy = UploadPlatform._('蒲公英平台', 0);
  static const UploadPlatform hwobs = UploadPlatform._('华为obs平台', 1);
}

List<UploadPlatform> uploadPlatforms = [
  UploadPlatform.pgy,
  UploadPlatform.hwobs
];
