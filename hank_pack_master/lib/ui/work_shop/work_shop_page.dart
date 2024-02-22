import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/material.dart' as m;
import 'package:hank_pack_master/comm/dialog_util.dart';
import 'package:hank_pack_master/comm/no_scroll_bar_ext.dart';
import 'package:hank_pack_master/comm/order_execute_result.dart';
import 'package:hank_pack_master/comm/pgy/pgy_entity.dart';
import 'package:hank_pack_master/hive/project_record/project_record_entity.dart';
import 'package:hank_pack_master/ui/work_shop/work_shop_vm.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../comm/ui/form_input.dart';
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

  Widget _mainTitleWidget(String title) {
    return Text(title, style: const TextStyle(fontSize: 22,fontWeight: FontWeight.w600));
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

  void showMyAppInfo(MyAppInfo s) {
    var card = AppInfoCard(appInfo: s);

    DialogUtil.showCustomDialog(
      context: context,
      content: card,
      title: '流程结束',
    );
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
            SingleChildScrollView(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    input("工程名称 ", "输入工程名称", _workShopVm.projectNameController,
                        must: true, enable: false),
                    input("git地址 ", "输入git地址", _workShopVm.gitUrlController,
                        must: true, enable: false),
                    input("工程位置", "输入工程名", _workShopVm.projectPathController,
                        suffix: _toolTip(), enable: false),
                    input("分支名称", "输入分支名称", _workShopVm.gitBranchController,
                        must: true, enable: false),
                    input(
                      "应用描述",
                      "输入应用描述...",
                      _workShopVm.projectAppDescController,
                      maxLines: 5,
                      enable: false,
                    ),
                  ]),
            ).hideScrollbar(context),
          ],
        ));

    var packageConfigWidget = Card(
        margin: const EdgeInsets.only(top: 0, left: 15, right: 10, bottom: 20),
        padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 15),
        borderRadius: BorderRadius.circular(10),
        backgroundColor: _appTheme.bgColorSucc.withOpacity(.1),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _mainTitleWidget("打包参数设置"),
          const SizedBox(height: 20),
          Expanded(
              child: SingleChildScrollView(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                input("更新日志", "输入更新日志...", _workShopVm.updateLogController,
                    maxLines: 5, enable: false),
                input('打包命令', "必须选择一个打包命令", _workShopVm.selectedOrderController,
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
              ])).hideScrollbar(context))
        ]));

    var taskStagesWidget = Padding(
        padding:
            const EdgeInsets.only(top: 15, left: 10, right: 10, bottom: 20),
        child: Card(
          borderRadius: BorderRadius.circular(10),
          backgroundColor: _appTheme.bgColorSucc.withOpacity(.1),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            _mainTitleWidget("任务阶段"),
            const SizedBox(height: 10),
            SizedBox(
              height: 120,
              child: ListView.builder(
                controller: _workShopVm.stageScrollerController,
                itemBuilder: (context, index) {
                  var e = _workShopVm.taskStateList[index];
                  return _stageBtn(stage: e, index: index);
                },
                itemCount: _workShopVm.taskStateList.length,
                scrollDirection: m.Axis.horizontal,
              ),
            )
          ]),
        ));

    var stageLogWidget = Expanded(
        child: Row(children: [
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
                        child: ListView.builder(
                      controller: _workShopVm.logListViewScrollController,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 1.0, horizontal: 4),
                          child: Text(
                            _workShopVm.cmdExecLog[index],
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w600),
                          ),
                        );
                      },
                      itemCount: _workShopVm.cmdExecLog.length,
                    ).hideScrollbar(context))
                  ])))
    ]));

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
            child: SingleChildScrollView(
                child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [...taskCardList],
            )).hideScrollbar(context)),
        // _mainTitleWidget("正在执行"), // 感觉这个没必要了
        // Expanded(
        //     flex: 2, child: taskCard(_workShopVm.runningTask, running: true)),
        const SizedBox(height: 15)
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
          flex: 7,
          child: Column(children: [
            Row(children: [Expanded(child: taskStagesWidget)]),
            stageLogWidget
          ]))
    ]);
  }

  Widget _stageBtn({required TaskState stage, required int index}) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SizedBox(
        width: 100,
        child: FilledButton(
          onPressed: () {
            // 按下之后，打开当前阶段的执行结果弹窗
            var result = stage.executeResultData;
            if (result is OrderExecuteResult) {
              var data = result.data;
              if (data is MyAppInfo) {
                showMyAppInfo(data);
              } else {
                _showInfoDialog(stage.stageName, '${stage.executeResultData}');
              }
            }
          },
          style: ButtonStyle(
              backgroundColor: ButtonState.resolveWith(
                  (states) => _workShopVm.getStatueColor(stage))),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  stage.stageName,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                if (stage.stageCostTime != null &&
                    stage.stageCostTime!.isNotEmpty)
                  Text(
                    stage.stageCostTime!,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
