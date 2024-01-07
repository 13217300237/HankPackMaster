import 'dart:io';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/material.dart' as m;
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:oktoast/oktoast.dart';
import 'package:provider/provider.dart';

import '../../core/command_util.dart';
import '../../test/env_param_vm.dart';
import '../../utils/toast_util.dart';

///
/// 此模块用来添加新的安卓工程
///
/// 表单操作
///
class ProjectPage extends StatefulWidget {
  const ProjectPage({super.key});

  @override
  State<ProjectPage> createState() => _ProjectPageState();
}

class _ProjectPageState extends State<ProjectPage> {
  late EnvParamVm envParamModel;
  final TextStyle _labelStyle =
      const TextStyle(fontWeight: FontWeight.w200, fontSize: 22);
  final _projectNameController = TextEditingController();
  final _projectGitController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _projectNameController.addListener(checkInput);
    _projectGitController.addListener(checkInput);
  }

  void checkInput() {
    setState(() {});
  }

  @override
  void dispose() {
    super.dispose();
    _projectNameController.removeListener(checkInput);
    _projectGitController.removeListener(checkInput);
  }

  @override
  Widget build(BuildContext context) {
    envParamModel = context.watch<EnvParamVm>();

    if (envParamModel.isAndroidEnvOk()) {
      return _mainLayout();
    } else {
      return const Center(child: Text("请先准备好环境参数"));
    }
  }

  Widget _mainLayout() {
    return Padding(
      padding: const EdgeInsets.all(40.0),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        InfoLabel(
          label: "当前工作空间",
          labelStyle: _labelStyle,
          child: Padding(
            padding: const EdgeInsets.only(left: 2),
            child: Text(
              envParamModel.workSpaceRoot,
              style: const TextStyle(fontSize: 27, fontWeight: FontWeight.w700),
            ),
          ),
        ),
        const SizedBox(height: 30),
        InfoLabel(
          label: '工程名',
          labelStyle: _labelStyle,
          child: TextBox(
            placeholder: '输入工程名',
            expands: false,
            controller: _projectNameController,
          ),
        ),
        const SizedBox(height: 30),
        InfoLabel(
          label: 'git地址',
          labelStyle: _labelStyle,
          child: TextBox(
            placeholder: '输入git地址',
            expands: false,
            controller: _projectGitController,
          ),
        ),
        const SizedBox(height: 30),
        Button(
          onPressed: disabled
              ? null
              : () {
                  startPackageAction();
                },
          child: const Text('开始打包'),
        )
      ]),
    );
  }

  bool get disabled {
    if (_projectNameController.text.isEmpty) {
      return true;
    }
    if (_projectGitController.text.isEmpty) {
      return true;
    }

    if (!envParamModel.isAndroidEnvOk()) {
      return true;
    }

    return false;
  }

  Future<void> _showInfo({
    String title = "提示",
    required String content,
  }) async {
    await displayInfoBar(context, builder: (context, close) {
      return InfoBar(
          title: Text(title),
          content: Text(content),
          action: IconButton(
              icon: const Icon(FluentIcons.chrome_close), onPressed: close),
          severity: InfoBarSeverity.warning);
    });
  }

  void startPackageAction() {
    _showInfo(
        content:
            "已经开始打包...       ${_projectNameController.text} ${_projectGitController.text}");
    makePack();
  }

  ///
  /// 打包动作
  ///
  void makePack() async {
    String projectRoot = envParamModel.workSpaceRoot +
        Platform.pathSeparator +
        _projectNameController.text;

    debugPrint("开始打包...");

    var gitClone = await CommandUtil.getInstance().execute(
      workDir: envParamModel.gitRoot,
      cmd: "git",
      params: ["clone", _projectGitController.text],
      action: debugPrint,
    );

    var exitCode = await gitClone?.exitCode;
    if (0 != exitCode) {
      String failedStr = "clone 执行失败.$exitCode";
      ToastUtil.showPrettyToast(failedStr);
      debugPrint(failedStr);
      return;
    } else {
      debugPrint("clone完毕");
    }

    // assemble
    var assemble = await CommandUtil.getInstance().execute(
        cmd: "gradlew.bat",
        binRoot: "$projectRoot${Platform.pathSeparator}",
        workDir: "$projectRoot${Platform.pathSeparator}",
        params: ["clean", "assembleDebug", "--stacktrace"],
        action: debugPrint);

    // 检查打包结果
    exitCode = await assemble?.exitCode;
    if (0 != exitCode) {
      String failedStr = "assemble 执行失败.$exitCode";
      ToastUtil.showPrettyToast(failedStr);
      debugPrint(failedStr);
      return;
    } else {
      debugPrint("assemble完毕");
    }
  }
}
