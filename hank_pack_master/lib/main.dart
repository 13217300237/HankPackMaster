import 'dart:async';
import 'dart:io';

import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:desktop_window/desktop_window.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hank_pack_master/info_page.dart';
import 'package:hank_pack_master/toast_util.dart';
import 'package:jiffy/jiffy.dart';
import 'package:oktoast/oktoast.dart';
import 'package:provider/provider.dart';

import 'command_util.dart';
import 'models.dart';

/// Checks if the current environment is a desktop environment.
bool get isDesktop {
  if (kIsWeb) return false;
  return [
    TargetPlatform.windows,
    TargetPlatform.linux,
    TargetPlatform.macOS,
  ].contains(defaultTargetPlatform);
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());

  if (isDesktop) {
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

  void alertErr(String r) {
    debugPrint("弹出错误 $r");
  }

  @override
  void initState() {
    super.initState();
    _getWindowSize();
    executorModel = context.read<ExecutorModel>();

    CommandUtil.getInstance().onError = (String r) {
      alertErr(r);
    };
  }

  List<Widget> _flutterGroup() {
    String? rootPath = EnvParams.flutterRoot.distinctAndFirst();

    if (rootPath == null || rootPath.isEmpty) return [];

    var flutterVersionBtn = _getCmdBtn(
        btnName: "flutter version",
        binRoot: rootPath,
        cmd: "flutter.bat",
        params: ["--version"],
        workDir: EnvParams.workRoot,
        btnColor: Colors.tealAccent);

    var flutterDoctorBtn = _getCmdBtn(
        btnName: "flutter doctor",
        binRoot: rootPath,
        cmd: "flutter.bat",
        params: ["doctor"],
        workDir: EnvParams.workRoot,
        btnColor: Colors.tealAccent);

    var flutterDartBtn = _getCmdBtn(
        btnName: "dart -version",
        binRoot: rootPath,
        cmd: "dart.bat",
        workDir: EnvParams.workRoot,
        btnColor: Colors.tealAccent);

    return [flutterVersionBtn, flutterDoctorBtn, flutterDartBtn];
  }

  List<Widget> _gitGroup() {
    String? rootPath = EnvParams.gitRoot.distinctAndFirst();
    if (rootPath == null || rootPath.isEmpty) return [];

    var gitCloneBtn = _getCmdBtn(
        btnName: "git clone",
        workDir: EnvParams.workRoot,
        cmd: "git",
        params: ["clone", "git@github.com:18598925736/HankPackMaster.git"],
        btnColor: Colors.blue);

    var gitVersionBtn = _getCmdBtn(
        btnName: "git version",
        workDir: EnvParams.workRoot,
        cmd: "git",
        params: ["--version"],
        btnColor: Colors.blue);

    return [gitCloneBtn, gitVersionBtn];
  }

  List<Widget> _adbGroup() {
    String? rootPath = EnvParams.gitRoot.distinctAndFirst();
    if (rootPath == null || rootPath.isEmpty) return [];
    var adbDevicesBtn = _getCmdBtn(
        workDir: EnvParams.workRoot,
        btnName: "adb devices",
        cmd: "adb",
        params: ["devices"],
        btnColor: Colors.amber);

    var adbLogcatBtn = _getCmdBtn(
        btnName: "adb logcat",
        cmd: "adb",
        workDir: EnvParams.workRoot,
        params: ["logcat", "|", "findStr", "com.kbzbank.kpaycustomer.uat"],
        btnColor: Colors.amber);
    return [adbDevicesBtn, adbLogcatBtn];
  }

  List<Widget> _gradlewBtns() {
    var gradlewVersion = _getCmdBtn(
        btnName: "gradlew -version",
        cmd: "gradlew.bat",
        binRoot: "E:\\MyApplication\\",
        workDir: "E:\\MyApplication\\",
        params: ["-version"],
        btnColor: Colors.greenAccent); // 执行打包命令还必须将工作目录和可执行目录都设置为 工程主目录

    var gradlew = _getCmdBtn(
        btnName: "gradlew assembleDebug",
        cmd: "gradlew.bat",
        binRoot: "E:\\MyApplication\\",
        workDir: "E:\\MyApplication\\",
        params: ["clean", "assembleDebug"],
        btnColor: Colors.greenAccent); // 执行打包命令还必须将工作目录和可执行目录都设置为 工程主目录
    return [gradlewVersion, gradlew];
  }

  @override
  Widget build(BuildContext context) {
    var windowSizeWidget = Center(
        child: Text(_windowSize, style: const TextStyle(color: Colors.white)));

    var monkeyrunner = _getCmdBtn(
        btnName: "monkeyrunner",
        binRoot: "D:\\env\\sdk\\tools\\bin\\",
        cmd: "monkeyrunner.bat",
        workDir: EnvParams.workRoot,
        btnColor: Colors.white60);

    var envInitBtn = Padding(
      padding: const EdgeInsets.all(8),
      child: ElevatedButton(
          onPressed: () async {
            reset();
            await CommandUtil.getInstance().initEnvParam(action: addRes);
            setState(() {});
          },
          child: const Text("initEnvParam")),
    );

    var actionButtons = Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(children: [
          envInitBtn,
          ..._gitGroup(),
          ..._adbGroup(),
          ..._gradlewBtns(),
          ..._flutterGroup(),
          monkeyrunner,
          Padding(
            padding: const EdgeInsets.all(8),
            child:
                ElevatedButton(onPressed: makePack, child: const Text("完整打包")),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: ElevatedButton(
                onPressed: () {
                  CommandUtil.getInstance().stopAllExec();
                },
                child: const Text("停止所有指令")),
          ),
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
    if (res.trim().isEmpty) return;
    executorModel.append(
        "${Jiffy.now().format(pattern: "yyyy-MM-dd HH:mm:ss")} : ${res.trim()}");
  }

  void reset() {
    executorModel.reset();
  }

  ///
  /// 打包动作
  ///
  void makePack() async {
    reset();

    // 检查当前环境变量即可
    var echoAndroidHome = await CommandUtil.getInstance().execute(
      workDir: EnvParams.workRoot,
      cmd: "cmd",
      params: ['/c', "echo", "%ANDROID_HOME%"],
      action: addRes,
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
    var gitClone = await CommandUtil.getInstance().execute(
      workDir: EnvParams.workRoot,
      cmd: "git",
      params: ["clone", "git@github.com:18598925736/MyApp20231224.git"],
      action: addRes,
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
    var assemble = await CommandUtil.getInstance().execute(
        cmd: "gradlew.bat",
        binRoot: "${EnvParams.workRoot}\\MyApp20231224\\",
        workDir: "${EnvParams.workRoot}\\MyApp20231224\\",
        params: ["clean", "assembleDebug", "--stacktrace"],
        action: addRes);

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

  _getCmdBtn(
      {required String btnName,
      required String cmd,
      List<String> params = const [],
      String binRoot = "",
      required String workDir,
      Color btnColor = Colors.green}) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ElevatedButton(
          style: ButtonStyle(
              backgroundColor: ButtonStyleButton.allOrNull<Color>(btnColor),
              foregroundColor:
                  ButtonStyleButton.allOrNull<Color>(Colors.white)),
          onPressed: () async {
            reset();
            var process = await CommandUtil.getInstance().execute(
              binRoot: binRoot,
              cmd: cmd,
              params: params,
              workDir: workDir,
              action: addRes,
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

class RightSide extends StatefulWidget {
  const RightSide({Key? key}) : super(key: key);

  @override
  State<RightSide> createState() => _RightSideState();
}

class _RightSideState extends State<RightSide> {
  late ExecutorModel executorModel;

  @override
  void initState() {
    super.initState();
    executorModel = context.read<ExecutorModel>();
  }

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
                    builder: (context, value, child) => InfoPage(
                          content: value.getRes,
                          scrollController: executorModel.scrollController,
                        )),
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
