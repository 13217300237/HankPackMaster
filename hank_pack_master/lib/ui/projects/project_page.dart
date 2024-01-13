import 'dart:io';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/material.dart' as m;
import 'package:hank_pack_master/ui/projects/project_task_vm.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

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

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      // 在绘制的第一帧之后执行初始化动作
      projectTaskVm.projectPathController.addListener(checkInput);
      projectTaskVm.gitUrlController.addListener(() {
        var gitText = projectTaskVm.gitUrlController.text;
        if (gitText.isNotEmpty) {
          try {
            var parse = Uri.parse(gitText);
            var lastSepIndex = parse.path.lastIndexOf("/");
            var endIndex = parse.path.length - 4;
            if (lastSepIndex > 0) {
              String projectName =
                  parse.path.substring(lastSepIndex + 1, endIndex);
              projectTaskVm.projectPathController.text =
                  envParamModel.workSpaceRoot +
                      Platform.pathSeparator +
                      projectName;
              projectTaskVm.gitBranchController.text = "dev"; // 测试代码
            } else {
              projectTaskVm.projectPathController.text = "";
              projectTaskVm.gitBranchController.text = ""; // 测试代码
            }
            // 直接赋值给 _projectNameController 就行了
          } catch (e, r) {}
        }

        checkInput();
      });

      // TODO 写死数据进行测试
      projectTaskVm.gitUrlController.text =
          "https://github.com/18598925736/MyApp20231224.git";
    });
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
    projectTaskVm.projectPathController.removeListener(checkInput);
    projectTaskVm.gitUrlController.removeListener(checkInput);
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
        _input("git地址", "输入git地址", projectTaskVm.gitUrlController),
        _gitErrorText(),
        _input("工程位置", "输入工程名", projectTaskVm.projectPathController,
            suffix: Tooltip(
              message: '点击打开目录',
              child: IconButton(
                  icon: const Icon(FluentIcons.open_enrollment, size: 18),
                  onPressed: () async {
                    String dir = projectTaskVm.projectPathController.text;
                    await launchUrl(Uri.parse(dir)); // 通过资源管理器打开该目录
                  }),
            )),
        _input("分支名称", "输入分支名称", projectTaskVm.gitBranchController),
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
    if (projectTaskVm.projectPathController.text.isEmpty) {
      return true;
    }
    if (projectTaskVm.gitUrlController.text.isEmpty) {
      return true;
    }
    if (projectTaskVm.gitBranchController.text.isEmpty) {
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
    projectTaskVm.startSchedule();
  }

  bool get gitErrVisible {
    return !isValidGitUrl(projectTaskVm.gitUrlController.text) &&
        projectTaskVm.gitUrlController.text.isNotEmpty;
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
