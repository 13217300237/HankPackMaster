import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:hank_pack_master/core/command_util.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

class NetUtil {
  static NetUtil? _instance;

  // 私有的构造函数
  NetUtil._();

  static late Dio _dio;

  // 公共的静态方法获取实例
  static NetUtil getInstance() {
    if (_instance == null) {
      _dio = Dio();
      _instance = NetUtil._();
    }
    return _instance!;
  }

  void checkCodehub() async {
    try{
      var response = await _dio.get("https://codehub-g.huawei.com/");
      if (response.statusCode == 200) {
        debugPrint("checkCodehub: 200,已连上xGate");
      } else {
        debugPrint("checkCodehub: ${response.statusCode}");
      }
    }catch(e){
      debugPrint("${e.toString()}  已失去和xGate的连接");
    }

  }

  /// 检查网络状况
  void getNetConnect() async {
    final connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile) {
      debugPrint("I am connected to a mobile network.");
    } else if (connectivityResult == ConnectivityResult.wifi) {
      debugPrint("I am connected to a wifi network.");
    } else if (connectivityResult == ConnectivityResult.ethernet) {
      debugPrint("I am connected to a ethernet network.");
    } else if (connectivityResult == ConnectivityResult.vpn) {
      debugPrint("I am connected to a vpn network.");
      debugPrint("Note for iOS and macOS:");
      debugPrint("There is no separate network interface type for [vpn].");
      debugPrint("It returns [other] on any device (also simulator)");
    } else if (connectivityResult == ConnectivityResult.bluetooth) {
      debugPrint("I am connected to a bluetooth.");
    } else if (connectivityResult == ConnectivityResult.other) {
      debugPrint(
          "I am connected to a network which is not in the above mentioned networks.");
    } else if (connectivityResult == ConnectivityResult.none) {
      debugPrint("I am not connected to any network.");
    }
  }

  /// 检查 proxyhk.huawei.com 是否能连通，如果可以，则说明 连上的xGate
  void checkProxyhk() {
    CommandUtil.getInstance().ping(
        proxy: "proxyhk.huawei.com",
        action: (s) {
          debugPrint("checkProxyhk:$s");
        });
  }
}
