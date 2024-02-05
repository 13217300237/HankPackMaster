import 'dart:io';

import 'package:dio/dio.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'package:crypto/crypto.dart' as crypto;

/// 华为OBS对象存储服务核心类
class HwObsUtil {
  ///

  static HwObsUtil? _instance;

  /// 私有的构造函数
  HwObsUtil._();

  static late Dio _dio;

  // 公共的静态方法获取实例
  static HwObsUtil getInstance() {
    if (_instance == null) {
      _dio = Dio();
      _ak = "WME9RK9W2EA5J7WMG0ZD";
      _sk = "mW2cNSmvCgDBk2WSeqNSdJowr7KlMTe5FxDl9ovB";
      _endpoint = "https://obs.ap-southeast-1.myhuaweicloud.com";
      _bucketName = "kbzpay-apppackage";
      _instance = HwObsUtil._();
    }
    return _instance!;
  }

  static late String _ak;
  static late String _sk;
  static late String _endpoint;
  static late String _bucketName;

  String signWithHmacSha1({
    required String input,
    required String secureKey,
  }) {
    var signingKey = Uint8List.fromList(secureKey.codeUnits);
    var mac = crypto.Hmac(crypto.sha1, signingKey);
    var bytes = Uint8List.fromList(input.codeUnits);
    var digest = mac.convert(bytes);
    return base64.encode(digest.bytes);
  }

  // 每次发送给OBS服务器的http请求，都必须包含由 SK ,请求时间，请求类型 等信息生成的签名信息。
  // 签名信息放在header中
  // 格式为：Authorization: OBS [AccessKeyID]:[Signature]
  // AccessKeyID 为 AK
  // Signature 是由 SK和一个StringToSign字符串计算而成
  String canonicalString({
    required String sk,
    required String dateTime,
    required String bucketName,
    required String objectName,
  }) {
    String httpVerb = "PUT";
    String contentMD5 = "1";
    String contentType = "1";
    String canonicalizedHeaders = "1";
    String canonicalizedResource = "/$bucketName/$objectName";

    var stringToSign = """
$httpVerb
$contentMD5
$contentType
$dateTime
$canonicalizedHeaders$canonicalizedResource"""
        .trim();
    return stringToSign;
  }

  final String _obj = "text01.text"; // 上传的对象名 test-object?acl
  final String _filePath = 'D:\\OBSobject\\text01.txt';
  final String _area = "ap-southeast-1";

  /// 上传到obs
  Future doUpload() async {
    String url = "https://$_bucketName.obs.$_area.myhuaweicloud.com/";
    debugPrint("url->$url");

    String dateTime = '${DateTime.now().millisecondsSinceEpoch}'; // 当前时间的毫秒数

    debugPrint("dateTime-> $dateTime");

    String canonical = canonicalString(
      sk: _sk,
      dateTime: dateTime,
      bucketName: _bucketName,
      objectName: _obj,
    );
    debugPrint(
        "\n=======canonical start========\n$canonical\n=======canonical end========\n");

    String sign = signWithHmacSha1(input: canonical, secureKey: _sk);

    debugPrint("sign->$sign");

    // 构建 FormData
    FormData formData =
        FormData.fromMap({"file": await MultipartFile.fromFile(_filePath)});

    final response = await _dio.put(url,
        options: Options(headers: {
          "Authorization": "OBS $_ak:$sign",
          "Date": dateTime,
        }),
        data: formData);

    if (response.statusCode == 200) {
      // 请求成功
      debugPrint("getPgyToken 请求成功===> ${response.data}");

      return null;
    } else {
      // 请求失败
      debugPrint('pgy 请求失败===> 错误码：${response.statusCode}');
      return null;
    }
  }
}
