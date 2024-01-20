import 'dart:io';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/material.dart' as m;
import 'package:hank_pack_master/comm/dialog_util.dart';
import 'package:hank_pack_master/comm/pgy/pgy_entity.dart';
import 'package:hank_pack_master/ui/projects/app_info_card.dart';
import 'package:hank_pack_master/ui/projects/project_task_vm.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../comm/theme.dart';
import '../env/env_param_vm.dart';

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
  late ProjectTaskVm _projectTaskVm;
  late AppTheme _appTheme;

  final TextStyle _labelStyle =
      const TextStyle(fontWeight: FontWeight.w200, fontSize: 18);

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      // 在绘制的第一帧之后执行初始化动作
      if (!envParamModel.isAndroidEnvOk()) {
        return;
      }
      _projectTaskVm.init();
      _projectTaskVm.projectPathController.addListener(checkInput);
      _projectTaskVm.projectAppDescController.addListener(checkInput);
      _projectTaskVm.gitUrlController.addListener(() {
        var gitText = _projectTaskVm.gitUrlController.text;
        if (gitText.isNotEmpty) {
          if (!isValidGitUrl(gitText)) {
            // 只要是可用的git源，那就直接解析
            checkInput();
            return;
          }

          var lastSepIndex = gitText.lastIndexOf("/");
          var endIndex = gitText.length - 4;
          if (lastSepIndex > 0) {
            String projectName = gitText.substring(lastSepIndex + 1, endIndex);
            _projectTaskVm.projectPathController.text =
                envParamModel.workSpaceRoot +
                    Platform.pathSeparator +
                    projectName;
            _projectTaskVm.gitBranchController.text = "dev"; // 测试代码
            _projectTaskVm.projectAppDescController.text =
                "测试用的app，你懂的！"; // 测试代码
          } else {
            _projectTaskVm.projectPathController.text = "";
            _projectTaskVm.gitBranchController.text = ""; // 测试代码
          }
          // 直接赋值给 _projectNameController 就行了
        }

        checkInput();
      });

      // TODO 写死数据进行测试
      _projectTaskVm.gitUrlController.text =
          "git@github.com:18598925736/MyApp20231224.git";
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
    _projectTaskVm.projectPathController.removeListener(checkInput);
    _projectTaskVm.gitUrlController.removeListener(checkInput);
  }

  @override
  Widget build(BuildContext context) {
    envParamModel = context.watch<EnvParamVm>();
    _appTheme = context.watch<AppTheme>();

    if (envParamModel.isAndroidEnvOk()) {
      return ChangeNotifierProvider(
        create: (context) => ProjectTaskVm(),
        builder: (context, child) {
          _projectTaskVm = context.watch<ProjectTaskVm>();
          return Container(color: _appTheme.bgColor, child: _mainLayout());
        },
      );
    } else {
      return Center(
          child: Text("请先准备好环境参数",
              style: TextStyle(color: Colors.red, fontSize: 45)));
    }
  }

  Widget _input(
      String title, String placeholder, TextEditingController controller,
      {Widget? suffix}) {
    return Row(children: [
      Expanded(
          child: Card(
              borderRadius: BorderRadius.circular(10),
              margin: const EdgeInsets.only(bottom: 5),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(fontSize: 25),
                      ),
                      if (suffix != null) ...[suffix]
                    ],
                  ),
                  const SizedBox(height: 10),
                  TextBox(
                      style: const TextStyle(decoration: TextDecoration.none),
                      decoration: BoxDecoration(
                          color: _appTheme.bgColor.withOpacity(.2)),
                      placeholder: placeholder,
                      expands: false,
                      enabled: !_projectTaskVm.jobRunning,
                      controller: controller)
                ],
              )))
    ]);
  }

  Widget _mainLayout() {
    var left = Container(
        margin: const EdgeInsets.symmetric(vertical: 10),
        padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 15),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              _input("git地址", "输入git地址", _projectTaskVm.gitUrlController),
              _gitErrorText(),
              _input("工程位置", "输入工程名", _projectTaskVm.projectPathController,
                  suffix: Tooltip(
                    message: '点击打开目录',
                    child: IconButton(
                        icon: const Icon(FluentIcons.open_enrollment, size: 18),
                        onPressed: () async {
                          String dir =
                              _projectTaskVm.projectPathController.text;
                          await launchUrl(Uri.parse(dir)); // 通过资源管理器打开该目录
                        }),
                  )),
              _input("分支名称", "输入分支名称", _projectTaskVm.gitBranchController),
              _input(
                  "应用描述", "输入应用描述...", _projectTaskVm.projectAppDescController),
            ]),
            Row(
              children: [
                Expanded(
                    child: FilledButton(
                  onPressed: actionButtonDisabled
                      ? null
                      : () => start(showApkNotExistInfo),
                  child: const SizedBox(
                      height: 80,
                      child: Center(
                        child: Text(
                          '开始流水线工作',
                          style: TextStyle(fontSize: 30),
                        ),
                      )),
                )),
              ],
            ),
          ],
        ));

    var middle = Padding(
        padding:
            const EdgeInsets.only(top: 30, left: 10, right: 10, bottom: 20),
        child: Card(
          borderRadius: BorderRadius.circular(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("任务阶段", style: TextStyle(fontSize: 22)),
              const SizedBox(height: 10),
              Expanded(
                child: SingleChildScrollView(
                    scrollDirection: m.Axis.vertical,
                    child: buildStageColumn()),
              ),
            ],
          ),
        ));

    var right = Padding(
        padding:
            const EdgeInsets.only(top: 30, left: 10, right: 20, bottom: 20),
        child: Card(
            padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
            borderRadius: BorderRadius.circular(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("执行日志", style: TextStyle(fontSize: 22)),
                const SizedBox(height: 10),
                Expanded(
                  child: ScrollConfiguration(
                      behavior: ScrollConfiguration.of(context)
                          .copyWith(scrollbars: false),
                      child: ListView.builder(
                        controller: _projectTaskVm.logListViewScrollController,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 1.0, horizontal: 4),
                            child: Text(
                              _projectTaskVm.cmdExecLog[index],
                              style: const TextStyle(fontSize: 16),
                            ),
                          );
                        },
                        itemCount: _projectTaskVm.cmdExecLog.length,
                      )),
                ),
              ],
            )));

    return Row(
      children: [
        Expanded(flex: 6, child: Column(children: [Expanded(child: left)])),
        Expanded(flex: 2, child: Column(children: [Expanded(child: middle)])),
        Expanded(flex: 4, child: Column(children: [Expanded(child: right)])),
      ],
    );
  }

  Widget _stageBtn({required TaskState stage, required int index}) {
    return FilledButton(
      onPressed: () {
        if (stage.stageStatue == StageStatue.finished &&
            index == _projectTaskVm.taskStateList.length - 1) {
          dealWithScheduleResultByApkUpload(myAppInfo!);
        }
      },
      style: ButtonStyle(
          backgroundColor: ButtonState.resolveWith(
              (states) => _projectTaskVm.getStatueColor(stage))),
      child: SizedBox(
          width: double.infinity, child: Center(child: Text(stage.stageName))),
    );
  }

  bool get actionButtonDisabled {
    if (_projectTaskVm.jobRunning) {
      return true;
    }
    if (_projectTaskVm.projectPathController.text.isEmpty) {
      return true;
    }
    if (_projectTaskVm.gitUrlController.text.isEmpty) {
      return true;
    }
    if (_projectTaskVm.gitBranchController.text.isEmpty) {
      return true;
    }

    if (_projectTaskVm.projectAppDescController.text.isEmpty) {
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

  void dealWithScheduleResultByApkGenerate(PackageSuccessEntity s) {
    onConfirm() async {
      var apkFile = File(s.apkPath);
      if (await apkFile.exists()) {
        await launchUrl(Uri.parse(apkFile.parent.path));
      } else {
        showApkNotExistInfo();
      }
    }

    String? confirmText = "打开文件位置";
    DialogUtil.showConfirmDialog(
      context: context,
      title: "流程结束",
      content: s.toString(),
      onConfirm: onConfirm,
      confirmText: confirmText,
    );
  }

  void dealWithScheduleResultByApkUpload(MyAppInfo s) {
    var card = AppInfoCard(appInfo: s);

    DialogUtil.showConfirmDialog(
      context: context,
      content: card,
      title: '流程结束',
    );
  }

  void dealWithScheduleResultByOthers() {}

  MyAppInfo? myAppInfo;

  Future<void> start(Function showApkNotExistInfo) async {
    _projectTaskVm.cleanLog();
    _projectTaskVm.startSchedule((s) {
      if (s is PackageSuccessEntity) {
        dealWithScheduleResultByApkGenerate(s);
      } else if (s is MyAppInfo) {
        myAppInfo = s;
        dealWithScheduleResultByApkUpload(s);
      } else {
        DialogUtil.showConfirmDialog(
          context: context,
          title: "流程结束",
          content: s.toString(),
          confirmText: "知道了...",
        );
      }
    });
  }

  bool get gitErrVisible {
    return !isValidGitUrl(_projectTaskVm.gitUrlController.text) &&
        _projectTaskVm.gitUrlController.text.isNotEmpty;
  }

  Widget _gitErrorText() {
    return Visibility(
        visible: gitErrVisible,
        child: Text("这不是一个正确的git地址",
            style: TextStyle(color: Colors.red, fontSize: 20)));
  }

  Widget buildStageColumn() {
    List<Widget> listWidget = [];

    for (int i = 0; i < _projectTaskVm.taskStateList.length; i++) {
      var e = _projectTaskVm.taskStateList[i];
      listWidget.add(Padding(
        padding: const EdgeInsets.all(8.0),
        child: _stageBtn(stage: e, index: i),
      ));
    }

    return Padding(
      padding: const EdgeInsets.only(top: 15.0, bottom: 5.0),
      child: Column(mainAxisSize: MainAxisSize.min, children: [...listWidget]),
    );
  }

  void showApkNotExistInfo() {
    DialogUtil.showInfo(context: context, content: "出现错误，apk文件不存在");
  }
}
