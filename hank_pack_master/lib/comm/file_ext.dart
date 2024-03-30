import 'dart:io';

import 'package:cross_file/cross_file.dart';
import 'package:hank_pack_master/comm/text_util.dart';

import 'hwobs/obs_client.dart';

extension XFileExt on XFile {
  Future<List<String>> detail() async {
    List<String> res = [];

    res.add('文件路径： $path ');
    res.add('文件名：$name');
    res.add('文件大小：${(await length()).toMb()}');
    res.add('最后修改时间：${(await lastModified()).formatYYYMMDDHHmmSS()}');
    res.add('MD5: ${await getFileMd5Base64(File(path))}');

    return res;
  }
}
