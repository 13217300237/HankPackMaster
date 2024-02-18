import 'dart:io';

import 'package:dio/dio.dart';
import 'package:path/path.dart' as path;

import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

class OBSResponse {
  String? objectName;
  String? fileName;
  String? url;
  int? size;
  String? ext;
  String? md5;
}

class OBSClient {
  static String? ak;
  static String? sk;
  static String? bucketName;
  static String? domain;

  static void init({
    required String ak,
    required String sk,
    required String domain,
    required String bucketName,
  }) {
    OBSClient.ak = ak;
    OBSClient.sk = sk;
    OBSClient.domain = domain;
    OBSClient.bucketName = bucketName;
  }

  static Dio _getDio() {
    var dio = Dio();
    dio.interceptors.add(PrettyDioLogger(
        requestHeader: true, requestBody: true, responseHeader: true));
    return dio;
  }

  static Future<OBSResponse?> putObject(
      {required String objectName,
      required List<int> data,
      String xObsAcl = "public-read"}) async {
    String contentMD5 = data.toMD5Base64();
    int size = data.length;
    var stream = Stream.fromIterable(data.map((e) => [e]));
    OBSResponse? obsResponse =
        await put(objectName, stream, contentMD5, size, xObsAcl: xObsAcl);
    return obsResponse;
  }

  static Future<OBSResponse?> putString(String objectName, String content,
      {String xObsAcl = "public-read"}) async {
    var contentMD5 = content.toMD5Base64();
    var size = content.length;
    OBSResponse? obsResponse =
        await put(objectName, content, contentMD5, size, xObsAcl: xObsAcl);
    return obsResponse;
  }

  static Future<OBSResponse?> putFile(
      {required String objectName,
      required File file,
      String xObsAcl = "public-read"}) async {
    var contentMD5 = await getFileMd5Base64(file);
    var stream = file.openRead();
    OBSResponse? obsResponse = await put(
        objectName, stream, contentMD5, await file.length(),
        xObsAcl: xObsAcl);
    return obsResponse;
  }

  static Future<OBSResponse?> put(String objectName, data, String md5, int size,
      {String xObsAcl = "public-read"}) async {
    if (objectName.startsWith("/")) {
      objectName = objectName.substring(1);
    }
    String url = "$domain/$objectName";

    var contentMD5 = md5;
    var date = HttpDate.format(DateTime.now());
    var contentType = "application/octet-stream";

    Map<String, String> headers = {};
    headers["Content-MD5"] = contentMD5;
    headers["Date"] = date;
    headers["x-obs-acl"] = xObsAcl;
    headers["Authorization"] = _sign("PUT", contentMD5, contentType, date,
        "x-obs-acl:$xObsAcl", "/$bucketName/$objectName");

    Options options = Options(headers: headers, contentType: contentType);

    Dio dio = _getDio();

    await dio.put(url, data: data, options: options);
    OBSResponse obsResponse = OBSResponse();
    obsResponse.md5 = contentMD5;
    obsResponse.objectName = objectName;
    obsResponse.url = url;
    obsResponse.fileName = path.basename(objectName);
    obsResponse.ext = path.extension(objectName);
    obsResponse.size = size;
    return obsResponse;
  }

  static Future<OBSResponse?> putFileWithPath(
      String objectName, String filePath,
      {String xObsAcl = "public-read"}) async {
    return putFile(objectName: objectName, file: File(filePath));
  }

  static String _sign(String httpMethod, String contentMd5, String contentType,
      String date, String acl, String res) {
    if (ak == null || sk == null) {
      throw "ak or sk is null";
    }
    String signContent =
        "$httpMethod\n$contentMd5\n$contentType\n$date\n$acl\n$res";

    return "OBS $ak:${signContent.toHmacSha1Base64(sk!)}";
  }
}

extension StringMd5Ext on String {
  List<int> toMD5Bytes() {
    var content = const Utf8Encoder().convert(this);
    var digest = md5.convert(content);
    return digest.bytes;
  }

  String toMD5() {
    return toMD5Bytes().toString();
  }

  String toMD5Base64() {
    var md5Bytes = toMD5Bytes();
    return base64.encode(md5Bytes);
  }

  String toHmacSha1Base64(String sk) {
    var hmacSha1 = Hmac(sha1, utf8.encode(sk));
    return base64.encode(hmacSha1.convert(utf8.encode(this)).bytes);
  }
}

extension ListIntExt on List<int> {
  List<int> toMD5Bytes() {
    return md5.convert(this).bytes;
  }

  String toMD5() {
    return toMD5Bytes().toString();
  }

  String toMD5Base64() {
    return base64.encode(toMD5Bytes());
  }
}

Future<List<int>> getFileMd5BytesFromPath(String filePath) async {
  File file = File(filePath);
  var digest = await md5.bind(file.openRead()).first;
  return digest.bytes;
}

Future<List<int>> getFileMd5Bytes(File file) async {
  var digest = await md5.bind(file.openRead()).first;
  return digest.bytes;
}

Future<String> getFileMd5Base64FromPath(String filePath) async {
  var md5bytes = await getFileMd5BytesFromPath(filePath);
  return base64.encode(md5bytes);
}

Future<String> getFileMd5Base64(File file) async {
  var md5bytes = await getFileMd5Bytes(file);
  return base64.encode(md5bytes);
}

String getRFC1123Date() {
  return HttpDate.format(DateTime.now());
}
