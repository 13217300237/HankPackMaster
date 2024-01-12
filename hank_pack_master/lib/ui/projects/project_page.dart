import 'dart:io';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/material.dart' as m;
import 'package:hank_pack_master/ui/projects/project_task_vm.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/command_util.dart';
import '../../test/env_param_vm.dart';

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
  late ProjectTaskVm projectTaskVm;
  final TextStyle _labelStyle =
      const TextStyle(fontWeight: FontWeight.w200, fontSize: 22);
  final _projectGitController = TextEditingController();
  final _projectPathController = TextEditingController();
  final _projectBranchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _projectPathController.addListener(checkInput);
    _projectGitController.addListener(() {
      var gitText = _projectGitController.text;
      if (gitText.isNotEmpty) {
        try {
          var parse = Uri.parse(gitText);
          var lastSepIndex = parse.path.lastIndexOf("/");
          var endIndex = parse.path.length - 4;
          if (lastSepIndex > 0) {
            String projectName =
                parse.path.substring(lastSepIndex + 1, endIndex);
            _projectPathController.text = envParamModel.workSpaceRoot +
                Platform.pathSeparator +
                projectName;
            _projectBranchController.text = "dev"; // 测试代码
          } else {
            _projectPathController.text = "";
            _projectBranchController.text = ""; // 测试代码
          }
          // 直接赋值给 _projectNameController 就行了
        } catch (e, r) {}
      }

      checkInput();
    });

    // TODO 写死数据进行测试
    _projectGitController.text =
        "https://github.com/18598925736/MyApp20231224.git";
  }

  bool isValidGitUrl(String url) {
    RegExp regex = RegExp(
      r'^((git|ssh|http(s)?)|(git@[\w\.]+))(:(\/\/)?)([\w\.@\:\/\-~]+)(\.git)(\/)?$',
      caseSensitive: false,
      multiLine: false,
    );
    return regex.hasMatch(url);
  }

  void checkInput() {
    setState(() {});
  }

  @override
  void dispose() {
    super.dispose();
    _projectPathController.removeListener(checkInput);
    _projectGitController.removeListener(checkInput);
  }

  @override
  Widget build(BuildContext context) {
    envParamModel = context.watch<EnvParamVm>();

    if (envParamModel.isAndroidEnvOk()) {
      return ChangeNotifierProvider(
        create: (context) => ProjectTaskVm(),
        builder: (context, child) {
          projectTaskVm = context.watch<ProjectTaskVm>();
          return _mainLayout();
        },
      );
    } else {
      return Center(
          child: Text("请先准备好环境参数", style: TextStyle(color: Colors.red)));
    }
  }

  Widget _input(
      String title, String placeholder, TextEditingController controller,
      {Widget? suffix}) {
    return Padding(
        padding: const EdgeInsets.only(top: 15.0, bottom: 15),
        child: InfoLabel(
          label: title,
          labelStyle: _labelStyle,
          child: TextBox(
              placeholder: placeholder,
              expands: false,
              enabled: true,
              suffix: suffix,
              controller: controller),
        ));
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
        _input("git地址", "输入git地址", _projectGitController),
        _gitErrorText(),
        _input("工程位置", "输入工程名", _projectPathController,
            suffix: Tooltip(
              message: '点击打开目录',
              child: IconButton(
                  icon: const Icon(FluentIcons.open_enrollment, size: 18),
                  onPressed: () async {
                    String dir = _projectPathController.text;
                    await launchUrl(Uri.parse(dir)); // 通过资源管理器打开该目录
                  }),
            )),
        _input("分支名称", "输入分支名称", _projectBranchController),
        Button(
          onPressed: actionButtonDisabled ? null : start,
          child: const Text('START'),
        ),
        const SizedBox(height: 20),
        buildStageRow(),
        const SizedBox(height: 20),
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
            decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.black,
                ),
                borderRadius: BorderRadius.circular(6)),
            child: ListView.builder(
              itemBuilder: (context, index) {
                return Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 1.0, horizontal: 15),
                  child: Text(
                    projectTaskVm.cmdExecLog[index],
                    style: const TextStyle(color: Colors.black, fontSize: 16),
                  ),
                );
              },
              itemCount: projectTaskVm.cmdExecLog.length,
            ),
          ),
        )
      ]),
    );
  }

  Widget _stageBtn({required TaskState stage, required int index}) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: m.ElevatedButton(
        onPressed: () {},
        style: m.ElevatedButton.styleFrom(
          backgroundColor: projectTaskVm.getStatueColor(stage), // 设置按钮背景颜色
          foregroundColor: Colors.white, // 设置按钮文本颜色
        ),
        child: Text(stage.stageName),
      ),
    );
  }

  bool get actionButtonDisabled {
    if (_projectPathController.text.isEmpty) {
      return true;
    }
    if (_projectGitController.text.isEmpty) {
      return true;
    }
    if (_projectBranchController.text.isEmpty) {
      return true;
    }

    if (!envParamModel.isAndroidEnvOk()) {
      return true;
    }

    if (gitErrVisible) {
      return true;
    }

    return false;
  }

  Future<void> start() async {
    projectTaskVm.init();
    projectTaskVm.cleanLog();
    _start(
        cmdLogCallback: (r) => projectTaskVm.addNewLogLine(r),
        stageCallback: (int stageIndex, StageStatue statue) =>
            projectTaskVm.updateStatue(stageIndex, statue));
  }

  waitOneSec() async {
    await Future.delayed(const Duration(milliseconds: 1000));
  }

  ///
  /// 打包动作
  ///
  Future<String> _start(
      {required Function(String s) cmdLogCallback,
      required Function(int stageIndex, StageStatue statue)
          stageCallback}) async {
    cmdLogCallback("开始流程...");
    // 阶段0
    // 参数准备
    // git地址
    await waitOneSec();
    stageCallback.call(0, StageStatue.executing);
    String clonePath = envParamModel.workSpaceRoot + Platform.pathSeparator;
    cmdLogCallback("clonePath-> $clonePath");
    // 参数：工程本地位置
    String projectRoot = _projectPathController.text + Platform.pathSeparator;
    cmdLogCallback("projectRoot-> $projectRoot...");
    stageCallback.call(0, StageStatue.finished);

    // =========================================================================
    // clone 阶段
    await waitOneSec();
    stageCallback.call(1, StageStatue.executing);
    cmdLogCallback("clone开始...");

    ExecuteResult gitCloneRes = await CommandUtil.getInstance()
        .gitClone(clonePath, _projectGitController.text, cmdLogCallback);
    cmdLogCallback("clone完毕，结果是  $gitCloneRes");

    if (gitCloneRes.exitCode != 0) {
      cmdLogCallback("clone失败，具体问题请看日志...");
      stageCallback.call(1, StageStatue.error);
      return gitCloneRes.res;
    }
    stageCallback.call(1, StageStatue.finished);
    // =========================================================================
    // checkout 阶段
    await waitOneSec();
    stageCallback.call(2, StageStatue.executing);
    cmdLogCallback("checkout 开始...");

    ExecuteResult gitCheckoutRes = await CommandUtil.getInstance()
        .gitCheckout(_projectPathController.text, _projectBranchController.text, cmdLogCallback);
    cmdLogCallback("checkout 完毕，结果是  $gitCheckoutRes");

    if (gitCheckoutRes.exitCode != 0) {
      cmdLogCallback("checkout  失败，具体问题请看日志...");
      stageCallback.call(2, StageStatue.error);
      return gitCheckoutRes.res;
    }
    stageCallback.call(2, StageStatue.finished);
    // =========================================================================
    await waitOneSec();
    stageCallback.call(3, StageStatue.executing);
    cmdLogCallback("开始检查工程目录结构...");
    // 阶段2，工程结构检查
    // 检查目录下是否有 gradlew.bat 文件
    File gradlewFile = File("${projectRoot}gradlew.bat");
    if (!gradlewFile.existsSync()) {
      String er = "工程目录下没找到 gradlew 命令文件，流程终止!";
      cmdLogCallback(er);
      stageCallback.call(3, StageStatue.error);
      return er;
    }
    cmdLogCallback("工程目录检测成功，工程结构正常，现在开始打包");
    stageCallback.call(3, StageStatue.finished);

    // =========================================================================
    await waitOneSec();
    stageCallback.call(4, StageStatue.executing);
    // 阶段3，执行打包命令
    ExecuteResult gradleAssembleRes = await CommandUtil.getInstance()
        .gradleAssemble(projectRoot, cmdLogCallback);
    cmdLogCallback("打包 完毕，结果是-> $gradleAssembleRes");

    if (gradleAssembleRes.exitCode != 0) {
      String er = "打包失败，详情请看日志";
      cmdLogCallback(er);
      stageCallback.call(4, StageStatue.error);
      return er;
    }
    stageCallback.call(4, StageStatue.finished);
    // =========================================================================

    return "流程结束";
  }

  bool get gitErrVisible {
    return !isValidGitUrl(_projectGitController.text) &&
        _projectGitController.text.isNotEmpty;
  }

  Widget _gitErrorText() {
    return Visibility(
        visible: gitErrVisible,
        child: Text("这不是一个正确的git地址",
            style: TextStyle(color: Colors.red, fontSize: 20)));
  }

  buildStageRow() {
    List<Widget> listWidget = [];

    for (int i = 0; i < projectTaskVm.taskStateList.length; i++) {
      var e = projectTaskVm.taskStateList[i];
      listWidget.add(_stageBtn(stage: e, index: i));
    }

    return Row(children: [...listWidget]);
  }
}
