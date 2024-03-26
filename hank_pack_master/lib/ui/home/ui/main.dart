import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import 'multi_state_wrap.dart';
import 'other.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  final StateController _stateController = StateController();

  // 模拟请求正常
  Future<DataWrapper> _getFutureData() async {
    await Future.delayed(const Duration(milliseconds: 2000));
    return DataWrapper(data: "正式数据布局加载成功", isSuccess: true);
  }

  // 模拟请求异常
  Future<DataWrapper> _getFutureFailed() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return DataWrapper(data: null, isSuccess: false);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(primarySwatch: Colors.blue),
        home: Scaffold(
            appBar: AppBar(title: const Text('演示')),
            body: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _buildButtons(),
                    const SizedBox(height: 30),
                    _buildMultipleStateWidgetSimpleDemo(
                        overtimeDuration: const Duration(milliseconds: 3000),
                        width: 200,
                        loadingHeight: 200,
                        radius: 15,
                        successHeight: 200),
                  ]),
            )));
  }

  ///
  /// 简单案例
  ///
  /// 如果成功之后的布局与loading相差很大呢？
  ///
  Widget _buildMultipleStateWidgetSimpleDemo(
      {required double width,
      required double loadingHeight,
      required double successHeight,
      required double radius,
      required Duration overtimeDuration}) {
    successLayoutBuilder(data) {
      return Container(
          width: width,
          height: successHeight,
          decoration: BoxDecoration(
              color: Colors.blue, borderRadius: BorderRadius.circular(radius)),
          child: Center(
              child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('images/cat.png', width: 100, height: 100),
              const SizedBox(height: 20),
              Text('$data',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold))
            ],
          )));
    }

    Widget initLayout() {
      return Container(
          decoration: BoxDecoration(
              color: Colors.blue, borderRadius: BorderRadius.circular(radius)),
          width: width,
          height: loadingHeight,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset('images/idle.png',
                  width: 100, height: 100, color: Colors.white),
              const SizedBox(height: 20),
              const Text("初始化布局",
                  style: TextStyle(color: Colors.white, fontSize: 20))
            ],
          ));
    }

    Widget errLayout() {
      return Container(
          decoration: BoxDecoration(
              color: Colors.blue, borderRadius: BorderRadius.circular(radius)),
          width: width,
          height: loadingHeight,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset('images/error.png',
                  width: 100, height: 100, color: Colors.white),
              const SizedBox(height: 20),
              const Text("数据加载异常",
                  style: TextStyle(color: Colors.white, fontSize: 20))
            ],
          ));
    }

    Widget timeoutLayout() {
      return Container(
          decoration: BoxDecoration(
              color: Colors.blue, borderRadius: BorderRadius.circular(radius)),
          width: width,
          height: loadingHeight,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset('images/timeout.png',
                  width: 100, height: 100, color: Colors.white),
              const SizedBox(height: 20),
              const Text("请求数据超时",
                  style: TextStyle(color: Colors.white, fontSize: 20))
            ],
          ));
    }

    Widget loadingLayout() {
      return Container(
        decoration: BoxDecoration(
            color: Colors.blue, borderRadius: BorderRadius.circular(radius)),
        width: width,
        height: loadingHeight,
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                RotationImageWidget(
                    child: SvgPicture.asset("images/loading.svg",
                        width: 100, height: 100, color: Colors.white)),
                const SizedBox(height: 20),
                const Text("数据加载中...",
                    style: TextStyle(color: Colors.white, fontSize: 20))
              ],
            ),
          ),
        ),
      );
    }

    return MultipleStatusWidget(
      loadingSize: WrapperSize(height: 200, width: 200),
      successSize: WrapperSize(height: 300, width: 300),
      stateController: _stateController,
      // 异步任务
      asyncTask: _getFutureData,
      // 超时时间
      overtimeDuration: overtimeDuration,
      // 正常布局
      successLayoutBuilder: successLayoutBuilder,
      // 初始化布局
      idleLayout: initLayout(),
      // 加载中布局
      loadingLayout: loadingLayout(),
      // 错误布局
      errLayout: errLayout(),
      // 超时布局
      timeoutLayout: timeoutLayout(),
    );
  }

  Widget _buildButtons() {
    return SingleChildScrollView(
        child: Center(
      child: Column(children: [
        ElevatedButton(
            onPressed: () async {
              _stateController.changeState(Status.loading);
              DataWrapper dataWrapper = await _getFutureData();
              debugPrint("控制器改变数据 ${dataWrapper.data}");
              _stateController.changeState(Status.success,
                  dataWrapper: dataWrapper);
            },
            child: const Text('模拟加载成功')),
        const SizedBox(width: 10),
        ElevatedButton(
            onPressed: () async {
              _stateController.changeState(Status.loading);
              var dataWrapper = await _getFutureFailed();
              _stateController.changeState(Status.error,
                  dataWrapper: dataWrapper);
            },
            child: const Text('模拟加载失败')),
        const SizedBox(width: 10),
        ElevatedButton(
            onPressed: () async {
              _stateController.changeState(Status.loading);
              await Future.delayed(const Duration(milliseconds: 1800));

              _stateController.changeState(Status.timeout);
            },
            child: const Text('模拟加载超时')),
      ]),
    ));
  }
}
