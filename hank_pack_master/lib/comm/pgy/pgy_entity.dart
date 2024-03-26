import 'package:hank_pack_master/comm/text_util.dart';

class PgyTokenEntity {
  int? code;
  String? message;
  Details? data;

  PgyTokenEntity({this.code, this.message, this.data});

  PgyTokenEntity.fromJson(Map<String, dynamic> json) {
    code = json['code'];
    message = json['message'];
    data = Details.fromJson(json['data']);
  }

  @override
  String toString() {
    return """
message = $message 
endpoint = ${data?.endpoint} 
xCosSecurityToken = ${data?.params?.xCosSecurityToken} 
signature = ${data?.params?.signature} 
key = ${data?.params?.key}""";
  }
}

class Details {
  Params? params;
  String? key;
  String? endpoint;

  Details({this.params, this.key, this.endpoint});

  Details.fromJson(Map<String, dynamic> json) {
    params = Params.fromJson(json['params']);
    key = json['key'];
    endpoint = json['endpoint'];
  }
}

class Params {
  String? signature;
  String? xCosSecurityToken;
  String? key;

  Params({this.signature, this.xCosSecurityToken, this.key});

  Params.fromJson(Map<String, dynamic> json) {
    signature = json['signature'];
    xCosSecurityToken = json['x-cos-security-token'];
    key = json['key'];
  }
}

class ReleaseResultEntity {
  int? code;
  String? message;
  Map<String, dynamic>? data;

  ReleaseResultEntity({this.code, this.message, this.data});

  ReleaseResultEntity.fromJson(Map<String, dynamic> json) {
    code = json['code'];
    message = json['message'];
    data = json['data'];
  }
}

class PgyEntity {
  String? endpoint;
  String? key;
  String? signature;
  String? xCosSecurityToken;

  PgyEntity({
    required this.endpoint,
    required this.key,
    required this.signature,
    required this.xCosSecurityToken,
  });

  @override
  String toString() {
    return '''
    endpoint-> $endpoint
    key-> $key
    signature-> $signature
    xCosSecurityToken-> $xCosSecurityToken
    ''';
  }

  bool isOk() {
    if (endpoint.empty()) {
      return false;
    }
    if (key.empty()) {
      return false;
    }
    if (signature.empty()) {
      return false;
    }
    if (xCosSecurityToken.empty()) {
      return false;
    }

    return true;
  }
}
