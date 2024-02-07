import 'package:dio/dio.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:hank_pack_master/comm/pgy/pgy_entity.dart';
import 'package:hank_pack_master/comm/const.dart';
import 'package:hank_pack_master/hive/env_config_operator.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

import '../../ui/projects/project_task_vm.dart';

/// 文件上传工具类，仅支持 apk和 ipa
class PgyUploadUtil {
  static PgyUploadUtil? _instance;

  // 私有的构造函数
  PgyUploadUtil._();

  static late Dio _dio;

  // 公共的静态方法获取实例
  static PgyUploadUtil getInstance() {
    if (_instance == null) {
      _dio = Dio();
      _dio.interceptors.add(PrettyDioLogger(
          requestHeader: true, requestBody: true, responseHeader: true));
      _instance = PgyUploadUtil._();
    }
    return _instance!;
  }

  /// 上传到蒲公英的第一步，鉴权，获取token
  Future<PgyTokenEntity?> getPgyToken({
    required String buildDescription,
    required String buildUpdateDescription,
  }) async {
    try {
      final response = await _dio.post(
        'https://www.pgyer.com/apiv2/app/getCOSToken',
        queryParameters: {
          '_api_key': EnvConfigOperator.searchEnvValue(Const.pgyApiKey),
          'buildType': 'android',
          'buildDescription': buildDescription,
          'buildUpdateDescription': buildUpdateDescription,
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
    } catch (e) {
      debugPrint('dio error: $e');
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
        uploadProgressAction("pgy 上传中  $formattedResult%");
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

  ///
  /// 判断查询结果是否已确定
  ///
  bool judgeReleaseResultEntityConfirmed(
    ReleaseResultEntity? entity, {
    required void Function(String s) onReleaseCheck,
  }) {
    if (entity == null) {
      return false;
    }
    if (entity.code == null) {
      return false;
    }
    if (entity.code == 1246 || entity.code == 1247) {
      onReleaseCheck("发布中，稍后重新查询");
      return false;
    }
    return true;
  }

  /// 上传到蒲公英的第三步，检查发布结果
  Future<ReleaseResultEntity?> checkUploadRelease(
    PgyEntity pgyEntity, {
    required void Function(String s) onReleaseCheck,
  }) async {
    ReleaseResultEntity? entity;

    try {
      while (!judgeReleaseResultEntityConfirmed(entity,
          onReleaseCheck: onReleaseCheck)) {
        // 每次循环之前都检查 发布结果是否确定
        await Future.delayed(const Duration(milliseconds: 5000));

        onReleaseCheck("开始查询发布结果");

        final response = await _dio.post(
          "https://www.pgyer.com/apiv2/app/buildInfo",
          queryParameters: {
            '_api_key': EnvConfigOperator.searchEnvValue(Const.pgyApiKey),
            'buildKey': pgyEntity.key,
          },
        );

        int code = response.statusCode ?? 0;

        if (code >= 200 && code < 300) {
          entity = ReleaseResultEntity.fromJson(response.data);
        } else {
          // 请求失败
          entity = ReleaseResultEntity();
          onReleaseCheck("发布请求执行失败 $code  ${response.statusMessage}");
        }
      }
    } catch (e) {
      debugPrint('dio error: $e');
      return null;
    }

    return entity;
  }
}
