import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:intl/intl.dart';
import 'package:crypto/crypto.dart';

/// 华为OBS对象存储服务核心类
class HwObsUtil {
  ///

  static HwObsUtil? _instance;

  /// 私有的构造函数
  HwObsUtil._();

  static late Dio _dio;

  static late String _ak;
  static late String _sk;
  static late String _endpoint;
  static late String _bucketName;

  // 公共的静态方法获取实例
  static HwObsUtil getInstance() {
    if (_instance == null) {
      _dio = Dio();
      _ak = "WME9RK9W2EA5J7WMG0ZD";
      _sk = "mW2cNSmvCgDBk2WSeqNSdJowr7KlMTe5FxDl9ovB";
      _endpoint = "obs.ap-southeast-1.myhuaweicloud.com";
      _bucketName = "kbzpay-apppackage";
      _instance = HwObsUtil._();
    }
    return _instance!;
  }

  String nowDate() {
    DateTime now = DateTime.now();
    DateFormat formatter = DateFormat('E, dd MMM yyyy HH:mm:ss', 'en_GB');
    String formatted = formatter.format(now.toUtc());
    return "$formatted GMT";
  }

  String getAuthorizationForUpload(
      String method, String requestTime, String objName) {
    // 1 构造请求字符串（StringToSign）;

    debugPrint("requestTime: $requestTime");
    // 提前计算出要上传对象的MD5，在上传完成之后服务端会进行校验，如果不同，会告知客户端，传输过程中遇到风险了
    String contentMD5 = "";
    String contentType = "";
    String canonicalizedHeaders = "";
    String canonicalizedResource = "/$_bucketName/$objName";
    debugPrint("canonicalizedResource: $canonicalizedResource");
    String stringToSign =
        "$method\n$contentMD5\n$contentType\n$requestTime\n$canonicalizedHeaders$canonicalizedResource";
    debugPrint("加密前的原文:\n$stringToSign");
    debugPrint("加密用的sk是: $_sk");
    // 2. 使用SK对StringToSign UTF-8编码之后的结果进行HMAC-SHA1签名计算
    List<int> keyBytes = utf8.encode(_sk);
    List<int> messageBytes =
        utf8.encode(stringToSign); // 对 StringToSign 进行 UTF-8 编码
    Hmac hmacSha1 = Hmac(sha1, keyBytes);
    Digest hmacDigest = hmacSha1.convert(messageBytes);
    // 3. 对第3步的结果进行Base64编码
    String encodedMessage = base64.encode(hmacDigest.bytes);
    debugPrint("最终签名: OBS $_ak:$encodedMessage"); // 打印编码后的字符串

    return 'OBS $_ak:$encodedMessage';
  }

  String getAuthorizationForListBucket(String method, String requestTime) {
    debugPrint("requestTime: $requestTime");

    String contentMD5 =
        ""; // 提前计算出要上传对象的MD5，在上传完成之后服务端会进行校验，如果不同，会告知客户端，传输过程中遇到风险了
    String contentType = "";
    String canonicalizedHeaders = "";
    String canonicalizedResource = "/$_bucketName/";
    debugPrint("canonicalizedResource: $canonicalizedResource");
    String stringToSign =
        "$method\n$contentMD5\n$contentType\n$requestTime\n$canonicalizedHeaders$canonicalizedResource";
    debugPrint("加密前的原文:\n$stringToSign");
    debugPrint("加密用的sk是: $_sk");
    // 2. 使用SK对StringToSign UTF-8编码之后的结果进行HMAC-SHA1签名计算
    List<int> keyBytes = utf8.encode(_sk);
    List<int> messageBytes =
        utf8.encode(stringToSign); // 对 StringToSign 进行 UTF-8 编码
    Hmac hmacSha1 = Hmac(sha1, keyBytes);
    Digest hmacDigest = hmacSha1.convert(messageBytes);
    // 3. 对第3步的结果进行Base64编码
    String encodedMessage = base64.encode(hmacDigest.bytes);

    debugPrint("最终签名: OBS $_ak:$encodedMessage"); // 打印编码后的字符串

    return 'OBS $_ak:$encodedMessage';
  }

  /// 列举桶列表
  duList() async {
    try {
      String requestTime = nowDate();
      String url = "https://$_bucketName.$_endpoint";
      debugPrint("请求地址为：$url");

      var options = Options(
        // 请求头
        headers: {
          'Date': requestTime,
          'Authorization': getAuthorizationForListBucket('GET', requestTime),
        },
      );

      final response = await _dio.get(url, options: options);

      debugPrint('responseCode  =  ${response.statusCode ?? 0}');

      debugPrint('responseCode.data  =  ${response.data ?? 'null'}');
    } catch (e) {
      if (e is DioError) {
        final response = e.response;
        if (response != null) {
          print("具体的报错信息: ${response.data}");
        } else {
          print("请求出错: ${e.message}");
        }
      } else {
        print("请求出错: $e");
      }
    }
  }

  /// 调用 OBS上传，必须关闭XGate，不然网络有问题
  doUpload() async {
    onSendProgress(int current, int total) {
      double result = (current / total) * 100;
      String formattedResult = result.toStringAsFixed(2);
      debugPrint("请求发送中...$formattedResult%");
    }

    onReceiveProgress(int current, int total) {
      double result = (current / total) * 100;
      String formattedResult = result.toStringAsFixed(2);
      debugPrint("请求接收中...$formattedResult%");
    }

    try {
      String requestTime = nowDate();

      String objName = "test.txt"; // 上传之后保存的对象名,注意这里如果有中文，必须先编码

      String url = "https://$_bucketName.$_endpoint/$objName";
      debugPrint("请求地址为：$url");

      // 构建 FormData 请求体
      var formData = FormData.fromMap({
        "file": await MultipartFile.fromFile('D:\\OBSobject\\text01.txt'),
      });

      // 请求头
      var options = Options(
        headers: {
          'Date': requestTime,
          'Authorization':
              getAuthorizationForUpload('PUT', requestTime, objName),
        },
        contentType: 'multipart/form-data',
      );

      final response = await _dio.put(url,
          options: options,
          data: formData, //TODO 去掉这一行就返回200，怀疑，是不是加了data之后，请求头中要增加对应的东西？
          onSendProgress: onSendProgress,
          onReceiveProgress: onReceiveProgress);

      debugPrint('responseCode  =  ${response.statusCode}');
      debugPrint(
          'response.headers:\n{\n${response.headers.toString().trim()}\n}');
    } catch (e) {
      if (e is DioError) {
        final response = e.response;
        if (response != null) {
          debugPrint("具体的报错信息: ${response.data}");
        } else {
          debugPrint("请求出错: ${e.message}");
        }
      } else {
        debugPrint("请求出错: $e");
      }
    }
  }
}
