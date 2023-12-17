import 'dart:io';

import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:desktop_window/desktop_window.dart';
import 'package:flutter/material.dart';
import 'package:hank_pack_master/info_page.dart';
import 'package:process_run/process_run.dart';

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

  @override
  Widget build(BuildContext context) {
    return Container(
        color: sidebarColor,
        width: 200,
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
                    children: [
                      _getBtn(),
                      Text(
                        _executeResult,
                        style: const TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ))
              ],
            )
          ],
        ));
  }

  Widget _getBtn() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ElevatedButton(
        onPressed: () async {
          setState(() {
            _executeResult = "";
          });

          List<ProcessResult>? list;
          try {
            list = await run('''
              git --version
              
              dir
              
              flutter --version
              
            ''', workingDirectory: "E:\\util");
          } on ShellException catch (e) {
            setState(() {
              _executeResult = e.result?.stderr;
            });
          }

          if (list == null) return;

          for (var r in list) {
            setState(() {
              if (r.exitCode == 0) {
                _executeResult += "${r.outText}\n";
              } else {
                _executeResult += "${r.errText}\n";
              }
            });
          }
        },
        child: const Text('git'),
      ),
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
