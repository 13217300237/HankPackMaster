import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:hank_pack_master/comm/pgy/pgy_token_entity.dart';

import '../ui/projects/project_task_vm.dart';

/// 文件上传工具类，仅支持 apk和 ipa
class UploadUtil {
  static UploadUtil? _instance;

  // 私有的构造函数
  UploadUtil._();

  static late Dio _dio;

  // 公共的静态方法获取实例
  static UploadUtil getInstance() {
    if (_instance == null) {
      _dio = Dio();
      _dio.options.contentType = Headers.multipartFormDataContentType;
      _instance = UploadUtil._();
    }
    return _instance!;
  }

  /// 上传到蒲公英的第一步，鉴权，获取token
  Future<PgyTokenEntity?> getPgyToken() async {
    final response = await _dio.post(
      'https://www.pgyer.com/apiv2/app/getCOSToken',
      queryParameters: {
        '_api_key': '3e3bb841269ccb9e3fb9b3feffa4273c',
        'buildType': 'android',
      },
    );

    if (response.statusCode == 200) {
      // 请求成功
      debugPrint("getPgyToken 请求成功===> ${response.data}");
      try {
        // 使用 jsonDecode 解码 JSON 字符串
        // 将 jsonData 转化为相应的 Dart 对象
        PgyTokenEntity tokenEntity = PgyTokenEntity.fromJson(response.data);

        if (0 == tokenEntity.code) {
          return tokenEntity;
        }
      } catch (e) {
        debugPrint("pgy json 转化为实体类失败... $e");
        return null;
      }
      return null;
    } else {
      // 请求失败
      debugPrint('pgy 请求失败===> 错误码：${response.statusCode}');
      return null;
    }
  }

  /// 上传到蒲公英的第二步，执行上传动作
  Future<String?> doUpload(
    PgyEntity pgyEntity, {
    required String filePath,
    required String oriFileName,
    required void Function(String s) uploadProgressAction,
  }) async {
    try {
      var map = <String, dynamic>{
        "key": pgyEntity.key,
        'signature': pgyEntity.signature,
        'x-cos-security-token': pgyEntity.xCosSecurityToken,
        'file': await MultipartFile.fromFile(filePath),
        'x-cos-meta-file-name': oriFileName,
      };

      final response = await _dio.post(pgyEntity.endpoint!,
          data: FormData.fromMap(map), onSendProgress: (current, total) {
        double result = (current / total) * 100;
        String formattedResult = result.toStringAsFixed(2);
        uploadProgressAction("pgy 上传中===> $formattedResult");
      });

      if (response.statusCode == 204) {
        // 请求成功
        debugPrint("pgy 上传成功===> ${response.data}");
        return null;
      } else {
        // 请求失败
        debugPrint('pgy 上传失败===> ：${response.statusCode}  ${response.data}');
        return "${response.statusCode}  ${response.data}";
      }
    } catch (e) {
      return "上传失败，$e";
    }
  }
}
