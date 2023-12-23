import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:desktop_window/desktop_window.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hank_pack_master/info_page.dart';
import 'package:jiffy/jiffy.dart';

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
    return MaterialApp(
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
    );
  }
}

const sidebarColor = Colors.lightGreen;

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

  String flutterPath =
      "D:/env/flutterSDK/flutter_windows_3.3.8-stable/flutter/bin/";

  @override
  Widget build(BuildContext context) {
    return Container(
        color: sidebarColor,
        width: 600,
        padding: const EdgeInsets.all(20),
        child: Stack(
          children: [
            Column(mainAxisAlignment: MainAxisAlignment.start, children: [
              Center(
                  child: Text(_windowSize,
                      style: const TextStyle(color: Colors.white)))
            ]),
            Column(
              children: [
                WindowTitleBarBox(child: MoveWindow()),
                Expanded(
                    child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          _getBtn(cmd: "git", params: [
                            "clone",
                            "git@github.com:18598925736/HankPackMaster.git"
                          ]),
                          _getBtn(
                              binRoot: flutterPath,
                              cmd: "flutter.bat",
                              params: ["doctor"]),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Text(_executeResult,
                          style: const TextStyle(color: Colors.white)),
                    ],
                  ),
                ))
              ],
            )
          ],
        ));
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
      {required String cmd,
      required List<String> params,
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
          child: Text(cmd)),
    );
  }
}

const backgroundStartColor = Color(0xFFFFD500);
const backgroundEndColor = Color(0xFFF6A00C);

class RightSide extends StatelessWidget {
  const RightSide({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [backgroundStartColor, backgroundEndColor],
              stops: [0.0, 1.0]),
        ),
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
