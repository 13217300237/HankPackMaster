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

  Widget _choose(String title, Map<String, String> orderList,
      {bool must = true}) {
    Widget comboBox;

    Widget mustSpace;

    if (must) {
      mustSpace = SizedBox(
          width: 20,
          child: Center(
              child: Text('*',
                  style: TextStyle(fontSize: 18, color: Colors.red))));
    } else {
      mustSpace = const SizedBox(width: 20);
    }

    if (_workShopVm.jobRunning) {
      comboBox = Text(_workShopVm.selectedOrder ?? '');
    } else if (orderList.isEmpty) {
      comboBox = const SizedBox();
    } else {
      comboBox = ComboBox<String>(
        value: _workShopVm.selectedOrder,
        placeholder: const Text('你必须选择一个打包命令'),
        items: orderList.entries.map((e) {
          return ComboBoxItem(
            value: e.key,
            child: Text(e.key),
          );
        }).toList(),
        onChanged: (order) {
          if (order != null) {
            _workShopVm.setSelectedOrder(order);
          } else {
            _showInfoDialog(title, "你必须选择一个打包命令");
          }
        },
      );
    }

    comboBox = Text(_workShopVm.selectedOrder ?? '');

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 0),
      child: Row(children: [
        SizedBox(
          width: 100,
          child: Row(
            children: [
              Text(title, style: const TextStyle(fontSize: 18)),
              mustSpace
            ],
          ),
        ),
        comboBox
      ]),
    );
  }

  Widget _chooseRadio(String title, {bool must = true}) {
    Widget mustSpace;

    if (must) {
      mustSpace = SizedBox(
          width: 20,
          child: Center(
              child: Text('*',
                  style: TextStyle(fontSize: 18, color: Colors.red))));
    } else {
      mustSpace = const SizedBox(width: 20);
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 0),
      child: Row(children: [
        SizedBox(
          width: 100,
          child: Row(
            children: [
              Text(title, style: const TextStyle(fontSize: 18)),
              mustSpace,
            ],
          ),
        ),
        Expanded(
          child: Row(
            children:
                List.generate(_workShopVm.uploadPlatforms.length, (index) {
              return Padding(
                padding: const EdgeInsets.only(right: 18.0),
                child: RadioButton(
                    checked: _workShopVm.selectedUploadPlatform?.value == index,
                    content: Text(_workShopVm.uploadPlatforms[index].name),
                    onChanged: (checked) {
                      if (_workShopVm.jobRunning) {
                        _showInfoDialog("提示", "任务正在执行，请稍后操作");
                        return;
                      }
                      if (checked) {
                        _workShopVm.setSelectedUploadPlatform(index);
                      }
                    }),
              );
            }),
          ),
        )
      ]),
    );
  }

  /// 输入框
  Widget _input(
    String title,
    String placeholder,
    TextEditingController controller, {
    Widget? suffix,
    bool alwaysDisable = false,
    int maxLines = 1,
    int? maxLength,
    bool must = false,
  }) {
    Widget mustSpace;

    if (must) {
      mustSpace = SizedBox(
          width: 20,
          child: Center(
              child: Text('*',
                  style: TextStyle(fontSize: 18, color: Colors.red))));
    } else {
      mustSpace = const SizedBox(width: 20);
    }

    var textStyle =
        const TextStyle(decoration: TextDecoration.none, fontSize: 16);

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Row(
              children: [
                Text(title, style: const TextStyle(fontSize: 18)),
                mustSpace
              ],
            ),
          ),
          Expanded(
            child: TextBox(
                decoration:
                    BoxDecoration(borderRadius: BorderRadius.circular(5)),
                unfocusedColor: Colors.transparent,
                highlightColor: Colors.transparent,
                style: textStyle,
                placeholder: placeholder,
                placeholderStyle: textStyle,
                expands: false,
                maxLines: maxLines,
                maxLength: maxLength,
                enabled: false,
                controller: controller),
          ),
          if (suffix != null) ...[suffix]
        ],
      ),
    );
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
                      _input(
                        "git地址 ",
                        "输入git地址",
                        _workShopVm.gitUrlController,
                        must: true,
                      ),
                      _gitErrorText(),
                      _input(
                        "工程位置",
                        "输入工程名",
                        _workShopVm.projectPathController,
                        alwaysDisable: true,
                        suffix: _toolTip(),
                      ),
                      _input(
                        "分支名称",
                        "输入分支名称",
                        _workShopVm.gitBranchController,
                        must: true,
                      ),
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
                        _input(
                          "应用描述",
                          "输入应用描述...",
                          _workShopVm.projectAppDescController,
                          maxLines: 5,
                        ),
                        _input(
                          "更新日志",
                          "输入更新日志...",
                          _workShopVm.updateLogController,
                          maxLines: 5,
                        ),
                        _choose('打包命令', _workShopVm.enableAssembleOrders),
                        const SizedBox(height: 5),
                        _input(
                          "apk路径",
                          "请输入apk预计路径，程序会根据此路径检测apk文件",
                          _workShopVm.apkLocationController,
                          maxLines: 1,
                        ),
                        _chooseRadio('上传方式'),
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
    DialogUtil.showCustomDialog(
      context: context,
      title: "流程结束",
      content: s.toString(),
      onConfirm: onConfirm,
      confirmText: confirmText,
    );
  }

  void dealWithScheduleResultByApkUpload(MyAppInfo s) {
    var card = AppInfoCard(appInfo: s);

    DialogUtil.showCustomDialog(
      context: context,
      content: card,
      title: '流程结束',
    );
  }

  MyAppInfo? myAppInfo;

  Future<void> startPackage() async {
    _workShopVm.initPackageTaskList();
    var scheduleRes = await _workShopVm.startSchedule();

    if (scheduleRes == null) {
      return;
    }
    if (scheduleRes.data is PackageSuccessEntity) {
      dealWithScheduleResultByApkGenerate(scheduleRes.data);
    } else if (scheduleRes.data is MyAppInfo) {
      myAppInfo = scheduleRes.data;
      dealWithScheduleResultByApkUpload(scheduleRes.data);
    } else {
      _showInfoDialog('打包结果', scheduleRes.toString());
    }
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

  void showApkNotExistInfo() {
    DialogUtil.showInfo(context: context, content: "出现错误，apk文件不存在");
  }
}
