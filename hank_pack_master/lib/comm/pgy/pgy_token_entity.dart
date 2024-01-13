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
  Map<String,dynamic>? data;

  ReleaseResultEntity({this.code, this.message,this.data});

  ReleaseResultEntity.fromJson(Map<String, dynamic> json) {
    code = json['code'];
    message = json['message'];
    data = json['data'];
  }
}
