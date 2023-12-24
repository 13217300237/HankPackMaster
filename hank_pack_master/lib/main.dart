import 'dart:async';
import 'dart:convert';

import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:desktop_window/desktop_window.dart';
import 'package:flutter/material.dart';
import 'package:hank_pack_master/info_page.dart';
import 'package:hank_pack_master/toast_util.dart';
import 'package:jiffy/jiffy.dart';
import 'package:oktoast/oktoast.dart';

import 'command_util.dart';

void main() {
  runApp(const MyApp());

  doWhenWindowReady(() {
    final win = appWindow;

    DesktopWindow.getWindowSize().then((size) {
      Size initialSize = Size(size.width * .9, size.height * .8);
      win.minSize = initialSize;
      win.size = initialSize;
      win.alignment = Alignment.center;
      win.title = "Custom window with Flutter";
      win.show();
    });
  });
}

const borderColor = Color(0xFF805306);

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return OKToast(
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          body: WindowBorder(
            color: borderColor,
            width: 1,
            child: const Row(
              children: [
                LeftSide(),
                RightSide(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

const sidebarColor = Colors.blueGrey;

class LeftSide extends StatefulWidget {
  const LeftSide({Key? key}) : super(key: key);

  @override
  State<LeftSide> createState() => _LeftSideState();
}

class _LeftSideState extends State<LeftSide> {
  String _windowSize = 'Unknown';

  String _executeResult = "";

  Future _getWindowSize() async {
    var size = await DesktopWindow.getWindowSize();
    setState(() {
      _windowSize = '${size.width} x ${size.height}';
    });
  }

  @override
  void initState() {
    super.initState();
    _getWindowSize();
  }

  @override
  Widget build(BuildContext context) {
    var windowSizeWidget = Center(
        child: Text(_windowSize, style: const TextStyle(color: Colors.white)));

    var gitBtn = _getBtn(
        btnName: "git clone",
        cmd: "git",
        params: ["clone", "git@github.com:18598925736/HankPackMaster.git"]);

    var gradlew = _getBtn(
        btnName: "gradlew -version",
        cmd: "gradlew.bat",
        binRoot: "E:\\MyApplication\\",
        params: ["-version"]);

    String flutterPath =
        "D:\\env\\flutterSDK\\flutter_windows_3.3.8-stable\\flutter\\bin\\";

    var flutterDoctorBtn = _getBtn(
      btnName: "flutter doctor",
      binRoot: flutterPath,
      cmd: "flutter.bat",
      params: ["doctor"],
    );

    var flutterDartBtn = _getBtn(
      btnName: "dart -version",
      binRoot: flutterPath,
      cmd: "dart.bat",
    );

    var adbDevicesBtn = _getBtn(
      btnName: "adb devices",
      cmd: "adb",
      params: ["devices"],
    );

    var adbLogcatBtn = _getBtn(
      btnName: "adb logcat",
      cmd: "adb",
      params: ["logcat"],
    );
    var monkeyrunner = _getBtn(
      btnName: "monkeyrunner",
      binRoot: "D:\\env\\sdk\\tools\\bin\\",
      cmd: "monkeyrunner.bat",
    );

    var executeResWidget =
        Text(_executeResult, style: const TextStyle(color: Colors.white));

    var actionButtons = Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(children: [
          gitBtn,
          gradlew,
          flutterDoctorBtn,
          flutterDartBtn,
          adbDevicesBtn,
          adbLogcatBtn,
          monkeyrunner,
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
                onPressed: () async {
                  // 带有渐变背景和动画的 toast
                  ToastUtil.showPrettyToast("我是一个兵！");
                },
                child: const Text("Toast test!")),
          )
        ]),
      ],
    );

    return Container(
        color: sidebarColor,
        width: 700,
        padding: const EdgeInsets.all(20),
        child: Stack(children: [
          Column(children: [windowSizeWidget]),
          Column(children: [
            WindowTitleBarBox(child: MoveWindow()),
            actionButtons,
            const SizedBox(height: 20),
            Expanded(
              child: SingleChildScrollView(child: executeResWidget),
            ),
          ]),
        ]));
  }

  void addRes(String res) {
    setState(() {
      _executeResult +=
          "${Jiffy.now().format(pattern: "yyyy-MM-dd HH:mm:ss")} : ${res.trim()}\n";
    });
  }

  void reset() {
    setState(() {
      _executeResult = "";
    });
  }

  void syncData(data) {
    try {
      // 将字节数组解码为字符串(这种写法，如果结果中包含中文，则 无法识别)
      String str = utf8.decode(data);
      addRes(str);
    } on Exception catch (e) {
      printErr(e, data);
    }
  }

  void printErr(e, data) {
    debugPrint('$e');
    debugPrint('无法用utf8转化如下数组：$data');
  }

  _getBtn(
      {required String btnName,
      required String cmd,
      List<String> params = const [],
      String binRoot = "",
      String workDir = "E:\\packTest"}) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ElevatedButton(
          onPressed: () async {
            reset();
            CommandUtil.execute(
              binRoot: binRoot,
              cmd: cmd,
              params: params,
              workDir: workDir,
              onLoadRes: addRes,
            );
          },
          child: Text(btnName)),
    );
  }
}

const backgroundStartColor = Color(0xFFFFD500);
const backgroundEndColor = Color(0xFFF6A00C);

class RightSide extends StatelessWidget {
  const RightSide({Key? key}) : super(key: key);

  final BoxDecoration bg = const BoxDecoration(
    gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [backgroundStartColor, backgroundEndColor],
        stops: [0.0, 1.0]),
  );

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        decoration: bg,
        child: Column(children: [
          WindowTitleBarBox(
            child: Row(
              children: [Expanded(child: MoveWindow()), const WindowButtons()],
            ),
          ),
          const MyInfoPage(title: "title")
        ]),
      ),
    );
  }
}

final buttonColors = WindowButtonColors(
    iconNormal: const Color(0xFF805306),
    mouseOver: const Color(0xFFF6A00C),
    mouseDown: const Color(0xFF805306),
    iconMouseOver: const Color(0xFF805306),
    iconMouseDown: const Color(0xFFFFD500));

final closeButtonColors = WindowButtonColors(
    mouseOver: const Color(0xFFD32F2F),
    mouseDown: const Color(0xFFB71C1C),
    iconNormal: const Color(0xFF805306),
    iconMouseOver: Colors.white);

class WindowButtons extends StatefulWidget {
  const WindowButtons({Key? key}) : super(key: key);

  @override
  WindowButtonsState createState() => WindowButtonsState();
}

class WindowButtonsState extends State<WindowButtons> {
  void maximizeOrRestore() {
    setState(() {
      appWindow.maximizeOrRestore();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        MinimizeWindowButton(colors: buttonColors),
        appWindow.isMaximized
            ? RestoreWindowButton(
                colors: buttonColors,
                onPressed: maximizeOrRestore,
              )
            : MaximizeWindowButton(
                colors: buttonColors,
                onPressed: maximizeOrRestore,
              ),
        CloseWindowButton(colors: closeButtonColors),
      ],
    );
  }
}
