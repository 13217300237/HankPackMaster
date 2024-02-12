import 'dart:async';
import 'dart:io';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/material.dart' as m;
import 'package:hank_pack_master/comm/dialog_util.dart';
import 'package:hank_pack_master/comm/pgy/pgy_entity.dart';
import 'package:hank_pack_master/ui/work_shop/work_shop_vm.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../comm/ui/pretty_3d_button.dart';
import '../comm/theme.dart';
import '../env/env_param_vm.dart';
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
  late EnvParamVm envParamModel;
  late ProjectTaskVm _projectTaskVm;
  late AppTheme _appTheme;

  Widget _mainTitleWidget(String title) {
    return Text(title, style: const TextStyle(fontSize: 22));
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      // 在绘制的第一帧之后执行初始化动作
      if (!envParamModel.isAndroidEnvOk()) {
        return;
      }
      _projectTaskVm.initPackageTaskList();
      _projectTaskVm.projectPathController.addListener(checkInput);
      _projectTaskVm.gitBranchController.addListener(checkInput);
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
          } else {
            _projectTaskVm.projectPathController.text = "";
            _projectTaskVm.gitBranchController.text = "";
          }
          // 直接赋值给 _projectNameController 就行了
        }

        checkInput();
      });

      // TODO 写死数据进行测试
      // _projectTaskVm.gitUrlController.text = "git@github.com:18598925736/MyApplication0016.git"; // 测试 Java17环境下的安卓工程
      _projectTaskVm.gitUrlController.text =
          "git@github.com:18598925736/MyApp20231224.git"; // 测试 Java17环境下的安卓工程
      // _projectTaskVm.gitUrlController.text =  "ssh://git@codehub-dg-g.huawei.com:2222/zWX1245985/test20240204_2.git"; // 公司电脑，测试内网git
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

    if (_projectTaskVm.jobRunning) {
      comboBox = Text(_projectTaskVm.selectedOrder ?? '');
    } else if (orderList.isEmpty) {
      comboBox = const SizedBox();
    } else {
      comboBox = ComboBox<String>(
        value: _projectTaskVm.selectedOrder,
        placeholder: const Text('你必须选择一个打包命令'),
        items: orderList.entries.map((e) {
          return ComboBoxItem(
            value: e.key,
            child: Text(e.key),
          );
        }).toList(),
        onChanged: (order) {
          if (order != null) {
            _projectTaskVm.setSelectedOrder(order);
          } else {
            _showInfoDialog(title, "你必须选择一个打包命令");
          }
        },
      );
    }

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
                List.generate(_projectTaskVm.uploadPlatforms.length, (index) {
              return Padding(
                padding: const EdgeInsets.only(right: 18.0),
                child: RadioButton(
                    checked: _projectTaskVm.selectedUploadPlatform?.value == index,
                    content: Text(_projectTaskVm.uploadPlatforms[index].name),
                    onChanged: (checked) {
                      if (checked) {
                        _projectTaskVm.setSelectedUploadPlatform(index);
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
                enabled: !_projectTaskVm.jobRunning && !alwaysDisable,
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
            String dir = _projectTaskVm.projectPathController.text;
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
    var leftTop = Card(
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
                        _projectTaskVm.gitUrlController,
                        must: true,
                      ),
                      _gitErrorText(),
                      _input(
                        "工程位置",
                        "输入工程名",
                        _projectTaskVm.projectPathController,
                        alwaysDisable: true,
                        suffix: _toolTip(),
                      ),
                      _input(
                        "分支名称",
                        "输入分支名称",
                        _projectTaskVm.gitBranchController,
                        must: true,
                      ),
                      _actionButton(
                          title: "项目激活测试",
                          bgColor: Colors.purple.normal,
                          enable: preCheckButtonEnable,
                          action: () async {
                            DialogUtil.showCustomDialog(
                                context: context,
                                content:
                                    "项目的首次打包都必须先进行激活测试，以确保该项目可用，主要包括，检测可用分支，检测可用打包指令，确定开始吗？",
                                title: '提示',
                                onConfirm: () {
                                  _projectTaskVm.initPreCheckTaskList();
                                  _projectTaskVm.startSchedule().then((value) {
                                    if (value == null) {
                                      return;
                                    }
                                    _showInfoDialog('激活结果', '${value.data}');
                                  });
                                });
                          }),
                    ]),
              ),
            ),
          ],
        ));

    var leftMiddle = Card(
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
                          _projectTaskVm.projectAppDescController,
                          maxLines: 5,
                        ),
                        _input(
                          "更新日志",
                          "输入更新日志...",
                          _projectTaskVm.updateLogController,
                          maxLines: 5,
                        ),
                        _choose('打包命令', _projectTaskVm.enableAssembleOrders),
                        const SizedBox(height: 5),
                        _input(
                          "apk路径",
                          "请输入apk预计路径，程序会根据此路径检测apk文件",
                          _projectTaskVm.apkLocationController,
                          maxLines: 1,
                        ),
                        _chooseRadio('上传方式'),
                      ]),
                ),
              ),
            ),
            _actionButton(
                title: "正式开始打包",
                enable: startPackageButtonEnable,
                bgColor: startPackageButtonEnable
                    ? Colors.orange.lighter
                    : Colors.grey.withOpacity(.2),
                action: startPackageButtonEnable ? startPackage : null),
          ],
        ));

    var middle = Padding(
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
              Expanded(
                child: ScrollConfiguration(
                  behavior: ScrollConfiguration.of(context)
                      .copyWith(scrollbars: false),
                  child: SingleChildScrollView(
                      scrollDirection: m.Axis.vertical,
                      child: buildStageColumn()),
                ),
              ),
            ],
          ),
        ));

    var right = Padding(
        padding:
            const EdgeInsets.only(top: 15, left: 10, right: 20, bottom: 20),
        child: Card(
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
        Expanded(
            flex: 5,
            child: Column(children: [
              leftTop,
              Expanded(child: leftMiddle),
            ])),
        Expanded(flex: 2, child: Column(children: [Expanded(child: middle)])),
        Expanded(flex: 4, child: Column(children: [Expanded(child: right)])),
      ],
    );
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
              (states) => _projectTaskVm.getStatueColor(stage))),
      child: SizedBox(
          width: double.infinity,
          child: Center(
              child: Column(
            children: [
              Text(stage.stageName),
              if (stage.stageCostTime != null &&
                  stage.stageCostTime!.isNotEmpty)
                Text(stage.stageCostTime!),
            ],
          ))),
    );
  }

  bool get preCheckButtonEnable {
    if (!envParamModel.isAndroidEnvOk()) {
      return false;
    }
    if (_projectTaskVm.jobRunning) {
      return false;
    }
    if (_projectTaskVm.gitUrlController.text.isEmpty) {
      return false;
    }
    if (_projectTaskVm.gitBranchController.text.isEmpty) {
      return false;
    }

    return true;
  }

  bool get startPackageButtonEnable {
    if (!envParamModel.isAndroidEnvOk()) {
      return false;
    }
    if (_projectTaskVm.jobRunning) {
      return false;
    }
    if (_projectTaskVm.selectedOrder == null ||
        _projectTaskVm.selectedOrder!.isEmpty) {
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
    _projectTaskVm.initPackageTaskList();
    var scheduleRes = await _projectTaskVm.startSchedule();

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
    return !isValidGitUrl(_projectTaskVm.gitUrlController.text) &&
        _projectTaskVm.gitUrlController.text.isNotEmpty;
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
