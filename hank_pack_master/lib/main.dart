import 'dart:async';
import 'dart:io';

import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:desktop_window/desktop_window.dart';
import 'package:flutter/material.dart';
import 'package:hank_pack_master/info_page.dart';
import 'package:hank_pack_master/toast_util.dart';
import 'package:jiffy/jiffy.dart';
import 'package:oktoast/oktoast.dart';
import 'package:provider/provider.dart';

import 'command_util.dart';
import 'models.dart';

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
      child: ChangeNotifierProvider(
        create: (BuildContext context) => ExecutorModel(),
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

  late ExecutorModel executorModel;

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
    executorModel = context.read<ExecutorModel>();
  }

  @override
  Widget build(BuildContext context) {
    var windowSizeWidget = Center(
        child: Text(_windowSize, style: const TextStyle(color: Colors.white)));

    var gitBtn = _getBtn(
        btnName: "git clone",
        cmd: "git",
        params: ["clone", "git@github.com:18598925736/HankPackMaster.git"]);

    var gradlewVersion = _getBtn(
        btnName: "gradlew -version",
        cmd: "gradlew.bat",
        binRoot: "E:\\MyApplication\\",
        workDir: "E:\\MyApplication\\",
        params: ["-version"]); // 执行打包命令还必须将工作目录和可执行目录都设置为 工程主目录

    var gradlew = _getBtn(
        btnName: "gradlew assembleDebug",
        cmd: "gradlew.bat",
        binRoot: "E:\\MyApplication\\",
        workDir: "E:\\MyApplication\\",
        params: ["clean", "assembleDebug"]); // 执行打包命令还必须将工作目录和可执行目录都设置为 工程主目录

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

    var toastTest = Padding(
      padding: const EdgeInsets.all(8.0),
      child: ElevatedButton(
          onPressed: () async {
            // 带有渐变背景和动画的 toast
            ToastUtil.showPrettyToast("我是一个兵！");
          },
          child: const Text("Toast test!")),
    );

    var actionButtons = Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(children: [
          toastTest,
          gitBtn,
          gradlewVersion,
          gradlew,
          flutterDoctorBtn,
          flutterDartBtn,
          adbDevicesBtn,
          adbLogcatBtn,
          monkeyrunner,
          Padding(
            padding: EdgeInsets.all(8),
            child: ElevatedButton(
                onPressed: () {
                  makePack();
                },
                child: const Text("Make Pack")),
          )
        ]),
      ],
    );

    return Container(
        color: sidebarColor,
        width: 400,
        padding: const EdgeInsets.all(20),
        child: Stack(children: [
          Column(children: [windowSizeWidget]),
          Column(children: [
            WindowTitleBarBox(child: MoveWindow()),
            actionButtons,
            const SizedBox(height: 20),
          ]),
        ]));
  }

  void addRes(String res) {
    executorModel.append(
        "${Jiffy.now().format(pattern: "yyyy-MM-dd HH:mm:ss")} : ${res.trim()}");
  }

  void reset() {
    executorModel.reset();
  }

  Future createAndWriteFile(String filePath, String content) async {
    debugPrint("准备写入环境参数");
    File file = File(filePath);
    debugPrint("1");
    // 创建文件
    file.createSync(recursive: true);
    debugPrint("2");
    // 写入内容
    await file.writeAsString(content);
    debugPrint("3");
  }

  ///
  /// 打包动作
  ///
  void makePack() async {
    reset();

    // 检查当前环境变量即可
    var echoAndroidHome = await CommandUtil.execute(
      workDir: "E:\\packTest",
      cmd: "cmd",
      params: ['/c', "echo", "%ANDROID_HOME%"],
      onLoadRes: addRes,
    );

    var exitCode = await echoAndroidHome?.exitCode;
    if (0 != exitCode) {
      String failedStr = "echoAndroidHome 执行失败.$exitCode";
      addRes(failedStr);
      return;
    } else {
      addRes("echoAndroidHome执行 完毕");
    }

    // clone
    var gitClone = await CommandUtil.execute(
      workDir: "E:\\packTest",
      cmd: "git",
      params: ["clone", "git@github.com:18598925736/MyApp20231224.git"],
      onLoadRes: addRes,
    );

    exitCode = await gitClone?.exitCode;
    if (0 != exitCode) {
      String failedStr = "clone 执行失败.$exitCode";
      ToastUtil.showPrettyToast(failedStr);
      addRes(failedStr);
      return;
    } else {
      addRes("clone完毕");
    }

    // assemble
    var assemble = await CommandUtil.execute(
        cmd: "gradlew.bat",
        binRoot: "E:\\packTest\\MyApp20231224\\",
        workDir: "E:\\packTest\\MyApp20231224\\",
        params: ["clean", "assembleDebug", "--stacktrace"],
        onLoadRes: addRes);

    // 检查打包结果
    exitCode = await assemble?.exitCode;
    if (0 != exitCode) {
      String failedStr = "assemble 执行失败.$exitCode";
      ToastUtil.showPrettyToast(failedStr);
      addRes(failedStr);
      return;
    } else {
      addRes("assemble完毕");
    }
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
            var process = await CommandUtil.execute(
              binRoot: binRoot,
              cmd: cmd,
              params: params,
              workDir: workDir,
              onLoadRes: addRes,
            );

            // 等待命令执行完成
            var exitCode = await process?.exitCode;
            ToastUtil.showPrettyToast("$btnName  执行完成，exitCode = $exitCode");
          },
          child: Text(btnName)),
    );
  }
}

const backgroundStartColor = Color(0x00cccccc);
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
                  child: Row(children: [
                Expanded(child: MoveWindow()),
                const WindowButtons()
              ])),
              Expanded(
                child: Consumer<ExecutorModel>(
                    builder: (context, value, child) =>
                        InfoPage(content: value.getRes)),
              )
            ])));
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
