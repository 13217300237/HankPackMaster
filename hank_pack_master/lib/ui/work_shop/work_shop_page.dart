import 'dart:async';
import 'dart:io';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/material.dart' as m;
import 'package:hank_pack_master/comm/dialog_util.dart';
import 'package:hank_pack_master/comm/pgy/pgy_entity.dart';
import 'package:hank_pack_master/hive/project_record/project_record_entity.dart';
import 'package:hank_pack_master/ui/work_shop/work_shop_vm.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../comm/ui/pretty_3d_button.dart';
import '../../comm/ui/form_input.dart';
import '../../comm/url_check_util.dart';
import '../comm/theme.dart';
import '../comm/vm/env_param_vm.dart';
import 'app_info_card.dart';

///
/// 打包工坊
///
/// 表单操作
///
class WorkShopPage extends StatefulWidget {
  const WorkShopPage({super.key});

  @override
  State<WorkShopPage> createState() => _WorkShopPageState();
}

class _WorkShopPageState extends State<WorkShopPage> {
  late EnvParamVm _envParamModel;
  late WorkShopVm _workShopVm;
  late AppTheme _appTheme;

  bool postFrameFinished = false;

  Widget _mainTitleWidget(String title) {
    return Text(title, style: const TextStyle(fontSize: 22));
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      postFrameFinished = true;
      // 在绘制的第一帧之后执行初始化动作
      if (!_envParamModel.isAndroidEnvOk()) {
        return;
      }
      _workShopVm.projectPathController.addListener(checkInput);
      _workShopVm.gitBranchController.addListener(checkInput);
      _workShopVm.projectAppDescController.addListener(checkInput);
      _workShopVm.gitUrlController.addListener(() {
        var gitText = _workShopVm.gitUrlController.text;
        if (gitText.isNotEmpty) {
          if (!isValidGitUrl(gitText)) {
            // 只要是可用的git源，那就直接解析
            checkInput();
            return;
          }

          // 直接赋值给 _projectNameController 就行了
        }

        checkInput();
      });
    });
  }

  void checkInput() {
    setState(() {});
  }

  @override
  void dispose() {
    super.dispose();
    _workShopVm.projectPathController.removeListener(checkInput);
    _workShopVm.gitUrlController.removeListener(checkInput);
  }

  @override
  Widget build(BuildContext context) {
    _envParamModel = context.watch<EnvParamVm>();
    _appTheme = context.watch<AppTheme>();
    _workShopVm = context.watch<WorkShopVm>();

    if (_envParamModel.isAndroidEnvOk()) {
      return Container(color: _appTheme.bgColor, child: _mainLayout());
    } else {
      return Center(
          child: Text("请先准备好环境参数",
              style: TextStyle(color: Colors.red, fontSize: 45)));
    }
  }

  _toolTip() {
    return Tooltip(
      message: '点击打开目录',
      child: IconButton(
          icon: const Icon(FluentIcons.open_enrollment, size: 18),
          onPressed: () async {
            String dir = _workShopVm.projectPathController.text;
            try {
              await launchUrl(Uri.parse(dir)); // 通过资源管理器打开该目录
            } catch (e) {
              _showErr();
            }
          }),
    );
  }

  _showInfoDialog(
    String title,
    String msg,
  ) {
    DialogUtil.showCustomDialog(
        context: context,
        content: msg,
        title: title,
        showCancel: false,
        confirmText: '我知道了...');
  }

  _showErr() {
    DialogUtil.showInfo(
        context: context,
        content: "打开资源浏览器失败，目录可能不存在...",
        severity: InfoBarSeverity.error);
  }

  Widget _mainLayout() {
    var projectConfigWidget = Card(
        margin: const EdgeInsets.only(top: 15, left: 15, right: 10, bottom: 10),
        padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 15),
        borderRadius: BorderRadius.circular(10),
        backgroundColor: _appTheme.bgColorSucc.withOpacity(.1),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _mainTitleWidget("项目配置"),
            const SizedBox(height: 20),
            ScrollConfiguration(
              behavior:
                  ScrollConfiguration.of(context).copyWith(scrollbars: false),
              child: SingleChildScrollView(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      input("git地址 ", "输入git地址", _workShopVm.gitUrlController,
                          must: true, enable: false),
                      _gitErrorText(),
                      input("工程位置", "输入工程名", _workShopVm.projectPathController,
                          suffix: _toolTip(), enable: false),
                      input("分支名称", "输入分支名称", _workShopVm.gitBranchController,
                          must: true, enable: false),
                    ]),
              ),
            ),
          ],
        ));

    var packageConfigWidget = Card(
        margin: const EdgeInsets.only(top: 0, left: 15, right: 10, bottom: 20),
        padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 15),
        borderRadius: BorderRadius.circular(10),
        backgroundColor: _appTheme.bgColorSucc.withOpacity(.1),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _mainTitleWidget("打包参数设置"),
            const SizedBox(height: 20),
            Expanded(
              child: ScrollConfiguration(
                behavior:
                    ScrollConfiguration.of(context).copyWith(scrollbars: false),
                child: SingleChildScrollView(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        input(
                          "应用描述",
                          "输入应用描述...",
                          _workShopVm.projectAppDescController,
                          maxLines: 5,
                          enable: false,
                        ),
                        input("更新日志", "输入更新日志...",
                            _workShopVm.updateLogController,
                            maxLines: 5, enable: false),
                        input('打包命令', "必须选择一个打包命令",
                            _workShopVm.selectedOrderController,
                            enable: false),
                        const SizedBox(height: 5),
                        input(
                          "apk路径",
                          "请输入apk预计路径，程序会根据此路径检测apk文件",
                          _workShopVm.apkLocationController,
                          maxLines: 1,
                          enable: false,
                        ),
                        input('上传方式', "必须选择一个上传平台",
                            _workShopVm.selectedUploadPlatformController,
                            enable: false),
                      ]),
                ),
              ),
            ),
            // _actionButton(
            //     title: "正式开始打包",
            //     enable: false,
            //     bgColor: startPackageButtonEnable
            //         ? Colors.orange.lighter
            //         : Colors.grey.withOpacity(.2),
            //     action: startPackageButtonEnable ? startPackage : null),
          ],
        ));

    var taskStagesWidget = Padding(
        padding:
            const EdgeInsets.only(top: 15, left: 10, right: 10, bottom: 20),
        child: Card(
          borderRadius: BorderRadius.circular(10),
          backgroundColor: _appTheme.bgColorSucc.withOpacity(.1),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _mainTitleWidget("任务阶段"),
              const SizedBox(height: 10),
              ScrollConfiguration(
                behavior:
                    ScrollConfiguration.of(context).copyWith(scrollbars: false),
                child: SingleChildScrollView(
                    scrollDirection: m.Axis.horizontal,
                    child: buildStageColumn()),
              ),
            ],
          ),
        ));

    var stageLogWidget = Expanded(
      child: Row(
        children: [
          Expanded(
            child: Card(
              margin: const EdgeInsets.only(bottom: 20, left: 10, right: 10),
              padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
              borderRadius: BorderRadius.circular(10),
              backgroundColor: _appTheme.bgColorSucc.withOpacity(.1),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _mainTitleWidget("执行日志"),
                  const SizedBox(height: 10),
                  Expanded(
                    child: ScrollConfiguration(
                      behavior: ScrollConfiguration.of(context)
                          .copyWith(scrollbars: false),
                      child: ListView.builder(
                        controller: _workShopVm.logListViewScrollController,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 1.0, horizontal: 4),
                            child: Text(
                              _workShopVm.cmdExecLog[index],
                              style: const TextStyle(fontSize: 16),
                            ),
                          );
                        },
                        itemCount: _workShopVm.cmdExecLog.length,
                      ),
                    ),
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );

    Widget taskCard(ProjectRecordEntity? e, {bool running = false}) {
      if (e == null) {
        return const SizedBox();
      }

      var statueWidget = !running
          ? Row(children: [
              const Text("状态: "),
              Text(e.preCheckOk ? "已激活" : "未激活")
            ])
          : Row(children: [
              const Text("状态: "),
              Text(e.preCheckOk ? "打包中" : "激活中")
            ]);

      return Card(
        borderRadius: BorderRadius.circular(5),
        padding: const EdgeInsets.all(10),
        margin: const EdgeInsets.symmetric(vertical: 5),
        backgroundColor:
            running ? Colors.teal : _appTheme.bgColorSucc.withOpacity(.2),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "任务名称：${e.projectName}",
              style: const TextStyle(fontWeight: FontWeight.w600),
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
            const SizedBox(height: 5),
            statueWidget
          ],
        ),
      );
    }

    var taskCardList = _workShopVm.getQueueList().map((e) {
      return Row(children: [Expanded(child: taskCard(e))]);
    }).toList();

    var taskQueue = Card(
      borderRadius: BorderRadius.circular(10),
      padding: const EdgeInsets.all(15),
      margin: const EdgeInsets.only(top: 15, bottom: 15, left: 15),
      backgroundColor: _appTheme.bgColorSucc.withOpacity(.1),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _mainTitleWidget("任务队列"),
        const SizedBox(height: 15),
        Expanded(
          flex: 5,
          child: ScrollConfiguration(
            behavior:
                ScrollConfiguration.of(context).copyWith(scrollbars: false),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [...taskCardList],
              ),
            ),
          ),
        ),
        _mainTitleWidget("正在执行"),
        Expanded(
            flex: 2, child: taskCard(_workShopVm.runningTask, running: true)),
        const SizedBox(height: 15),
      ]),
    );
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Expanded(flex: 3, child: taskQueue),
      Expanded(
          flex: 8,
          child: Column(children: [
            projectConfigWidget,
            Expanded(child: packageConfigWidget)
          ])),
      Expanded(
          flex: 6,
          child: Column(
            children: [
              Row(children: [Expanded(child: taskStagesWidget)]),
              stageLogWidget,
            ],
          ))
    ]);
  }

  Widget _actionButton({
    required String title,
    required Color bgColor,
    required Function()? action,
    required bool enable,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Pretty3DButton(
          text: title,
          blurRadius: 0,
          offset: .5,
          spreadRadius: .2,
          onTap: action,
          enable: enable,
        ),
      ],
    );
  }

  Widget _stageBtn({required TaskState stage, required int index}) {
    return FilledButton(
      onPressed: () {
        // 按下之后，打开当前阶段的执行结果弹窗
        _showInfoDialog(stage.stageName, '${stage.executeResultData}');
      },
      style: ButtonStyle(
          backgroundColor: ButtonState.resolveWith(
              (states) => _workShopVm.getStatueColor(stage))),
      child: Center(
          child: Column(
        children: [
          Text(stage.stageName),
          if (stage.stageCostTime != null && stage.stageCostTime!.isNotEmpty)
            Text(stage.stageCostTime!),
        ],
      )),
    );
  }

  bool get preCheckButtonEnable {
    if (!_envParamModel.isAndroidEnvOk()) {
      return false;
    }
    if (_workShopVm.jobRunning) {
      return false;
    }
    if (_workShopVm.gitUrlController.text.isEmpty) {
      return false;
    }
    if (_workShopVm.gitBranchController.text.isEmpty) {
      return false;
    }

    return true;
  }

  bool get startPackageButtonEnable {
    if (!_envParamModel.isAndroidEnvOk()) {
      return false;
    }
    if (_workShopVm.jobRunning) {
      return false;
    }
    if (_workShopVm.selectedOrder == null ||
        _workShopVm.selectedOrder!.isEmpty) {
      return false;
    }

    if (_workShopVm.selectedUploadPlatform == null) {
      return false;
    }

    return true;
  }

  bool get gitErrVisible {
    return !isValidGitUrl(_workShopVm.gitUrlController.text) &&
        _workShopVm.gitUrlController.text.isNotEmpty;
  }

  Widget _gitErrorText() {
    return Visibility(
        visible: gitErrVisible,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text("这不是一个正确的git地址",
                  style: TextStyle(color: Colors.red, fontSize: 16)),
            ],
          ),
        ));
  }

  Widget buildStageColumn() {
    List<Widget> listWidget = [];

    for (int i = 0; i < _workShopVm.taskStateList.length; i++) {
      var e = _workShopVm.taskStateList[i];
      listWidget.add(Padding(
        padding: const EdgeInsets.all(8.0),
        child: _stageBtn(stage: e, index: i),
      ));
    }

    return Padding(
      padding: const EdgeInsets.only(top: 15.0, bottom: 5.0),
      child: Row(mainAxisSize: MainAxisSize.min, children: [...listWidget]),
    );
  }
}
