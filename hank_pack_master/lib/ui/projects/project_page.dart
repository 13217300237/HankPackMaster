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
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(children: [
        Expanded(
            child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 19),
                ),
                if (suffix != null) ...[suffix]
              ],
            ),
            const SizedBox(height: 5),
            TextBox(
                style: const TextStyle(decoration: TextDecoration.none),
                decoration:
                    BoxDecoration(color: _appTheme.bgColor.withOpacity(.2)),
                placeholder: placeholder,
                expands: false,
                enabled: !_projectTaskVm.jobRunning,
                controller: controller)
          ],
        ))
      ]),
    );
  }

  Widget _mainLayout() {
    var left = Card(
        margin: const EdgeInsets.only(top: 30, left: 10, right: 10, bottom: 20),
        padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 15),
        borderRadius: BorderRadius.circular(10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: ScrollConfiguration(
                behavior:
                    ScrollConfiguration.of(context).copyWith(scrollbars: false),
                child: SingleChildScrollView(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _input("git地址", "输入git地址",
                            _projectTaskVm.gitUrlController),
                        _gitErrorText(),
                        _input("工程位置", "输入工程名",
                            _projectTaskVm.projectPathController,
                            suffix: Tooltip(
                              message: '点击打开目录',
                              child: IconButton(
                                  icon: const Icon(FluentIcons.open_enrollment,
                                      size: 18),
                                  onPressed: () async {
                                    String dir = _projectTaskVm
                                        .projectPathController.text;
                                    await launchUrl(
                                        Uri.parse(dir)); // 通过资源管理器打开该目录
                                  }),
                            )),
                        _input("分支名称", "输入分支名称",
                            _projectTaskVm.gitBranchController),
                        _input("应用描述", "输入应用描述...",
                            _projectTaskVm.projectAppDescController),
                        _input("更新日志", "输入更新日志...",
                            _projectTaskVm.updateLogController),
                        _input("打包命令", "输入打包命令...",
                            _projectTaskVm.assembleTaskNameController),
                      ]),
                ),
              ),
            ),
            _actionButton(
                title: "项目激活测试",
                bgColor: Colors.purple.normal,
                action: () {
                  DialogUtil.showConfirmDialog(
                      context: context,
                      content: "项目的首次打包都必须先进行激活测试，以确保该项目可用，主要包括，检测可用分支，检测可用打包指令，是否继续？",
                      title: '提示',onConfirm: (){
                        start(showApkNotExistInfo);
                  });
                }),
            _actionButton(
                title: "正式开始打包",
                bgColor: Colors.orange.lighter,
                action: actionButtonDisabled
                    ? null
                    : () => start(showApkNotExistInfo)),
          ],
        ));

    // TODO 打包前需要设定的参数有，
    // 强制更改 工程的gradleWrapper版本
    // 工程克隆阶段的 每次最大可执行时间，可重试次数，和clone失败后每次重试间隔时间。如果超过时间没clone成功，就提示任务失败
    // 可用指令查询阶段 每次最大可执行时间，可重试次数，和clone失败后每次重试间隔时间。如果超过时间没执行成功，就提示任务失败
    // 打包的版本号和版本名，如不指定，就用工程自己默认的
    // pgy的_api_key
    // pgy上传成功之后查询结果的最大查询次数，每次查询间隔时间，如果超过次数还没查询成功，则认为任务失败

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

  Widget _actionButton({
    required String title,
    required Color bgColor,
    required Function()? action,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Expanded(
              child: FilledButton(
            style: ButtonStyle(
                backgroundColor: ButtonState.resolveWith((states) => bgColor)),
            onPressed: action,
            child: SizedBox(
                height: 60,
                child: Center(
                  child: Text(
                    title,
                    style: const TextStyle(fontSize: 30),
                  ),
                )),
          )),
        ],
      ),
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
