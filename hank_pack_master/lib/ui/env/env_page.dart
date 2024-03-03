import 'dart:io';
import 'dart:math';

import 'package:file_picker/file_picker.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:hank_pack_master/comm/dialog_util.dart';
import 'package:hank_pack_master/comm/no_scroll_bar_ext.dart';
import 'package:hank_pack_master/comm/toast_util.dart';
import 'package:hank_pack_master/comm/url_check_util.dart';
import 'package:hank_pack_master/hive/env_group/env_group_operator.dart';
import 'package:hank_pack_master/hive/env_group/env_check_result_entity.dart';
import 'package:hank_pack_master/hive/env_group/env_group_entity.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/command_util.dart';
import '../comm/theme.dart';
import '../comm/vm/env_param_vm.dart';
import 'env_card.dart';

///
/// 环境参数检测页面
///
class EnvPage extends StatefulWidget {
  const EnvPage({super.key});

  @override
  State<EnvPage> createState() => _EnvPageState();
}

class _EnvPageState extends State<EnvPage> {
  late AppTheme _appTheme;
  late EnvParamVm _envParamModel;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _envParamModel.init();
    });
  }

  Widget _envChooseWidget(
      {required String title,
      required String Function() init,
      required Function(String r) action}) {
    return _card(
        title,
        [
          if (!_envParamModel.isEnvEmpty(title)) ...[
            Padding(
              padding: const EdgeInsets.only(bottom: 0),
              child: Tooltip(
                message: init(),
                child: Text(
                  init(),
                  maxLines: 1,
                  style: const TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 29),
                ),
              ),
            )
          ],
        ],
        action: action);
  }

  @override
  Widget build(BuildContext context) {
    _envParamModel = context.watch<EnvParamVm>();
    _appTheme = context.watch<AppTheme>();

    return Container(
        color: _appTheme.bgColor,
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text("自动环境检测", style: TextStyle(fontSize: 30)),
          const EnvGroupCard(
            order: "java",
            downloadUrl: "https://www.oracle.com/java/technologies/downloads",
          ),
          const EnvGroupCard(
            order: "git",
            downloadUrl: "https://git-scm.com/download/win",
          ),
          const EnvGroupCard(order: "adb"),
          const EnvGroupCard(
            order: "flutter",
            downloadUrl: "https://docs.flutter.dev/release/archive?tab=windows",
          ),
          const SizedBox(height: 20),
          _manualSpecifyEnvTitle(),
          Row(children: [
            Expanded(child: _workspaceChoose()),
            Expanded(child: _androidSdkChoose()),
          ]),
          Row(children: [Expanded(child: _stageTaskExecuteSetting())]),
          Row(children: [Expanded(child: _pgySetting())]),
          Row(children: [Expanded(child: _hwobsSetting())]),
        ])).hideScrollbar(context));
  }

  /// 这是为了解决 context可变的问题
  showMyInfo({
    required String title,
    required String content,
    InfoBarSeverity severity = InfoBarSeverity.success,
  }) {
    DialogUtil.showInfo(
        context: context, title: title, content: content, severity: severity);
  }

  bool _checkAllFoldersExist(String directoryPath, List<String> targetFolders) {
    Directory directory = Directory(directoryPath);

    for (String folder in targetFolders) {
      bool exists = false;
      directory.listSync().forEach((FileSystemEntity entity) {
        if (entity is Directory &&
            entity.path.endsWith('${Platform.pathSeparator}$folder')) {
          exists = true;
        }
      });

      if (!exists) {
        return false;
      }
    }

    return true;
  }

  Future<bool> _checkAndroidSdkEnable(String selectedDirectory) async {
    Directory dir = Directory(selectedDirectory);
    // 路径实际上不存在时
    if (!(await dir.exists())) {
      return false;
    }
    // C:\Users\zwx1245985\AppData\Local\Android\Sdk
    List<String> mustHave = ['build-tools', 'platforms', 'platform-tools'];
    return _checkAllFoldersExist(selectedDirectory, mustHave);
  }

  @override
  void dispose() {
    super.dispose();
    debugPrint("envPage dispose");
  }

  Widget envErrWidget(String title) {
    if (_envParamModel.isEnvEmpty(title)) {
      return Text("${_envParamModel.envGuide[title]}",
          style: TextStyle(fontSize: 20, color: Colors.red));
    } else {
      return const SizedBox();
    }
  }

  Widget _card(String title, List<Widget> muEnv,
      {required Function(String r) action}) {
    return Row(mainAxisSize: MainAxisSize.max, children: [
      Expanded(
          child: Container(
              padding: const EdgeInsets.all(20),
              margin: const EdgeInsets.all(10),
              decoration: _boxBorder(title),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(title, style: const TextStyle(fontSize: 30)),
                        Row(
                          children: [
                            FilledButton(
                                child: const Text("更换路径"),
                                onPressed: () async {
                                  String? selectedDirectory = await FilePicker
                                      .platform
                                      .getDirectoryPath();
                                  if (selectedDirectory != null) {
                                    action(selectedDirectory);
                                  }
                                }),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    ...muEnv,
                    const SizedBox(height: 5),
                    envErrWidget(title),
                    const SizedBox(height: 5),
                  ])))
    ]);
  }

  BoxDecoration _boxBorder(String title) {
    var boxColor = _appTheme.bgColorErr;
    if (!_envParamModel.isEnvEmpty(title)) {
      boxColor = _appTheme.bgColorSucc;
    }

    return BoxDecoration(
        color: boxColor,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.grey[50], width: .5));
  }

  void showCmdResultDialog(String res) {
    DialogUtil.showEnvCheckDialog(
      context: context,
      onConfirm: null,
      content: res,
      title: "测试结果",
    );
  }

  Widget _manualSpecifyEnvTitle() {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text("手动环境指定", style: TextStyle(fontSize: 30)),
          Row(
            children: [
              FilledButton(
                  child: Text("设置环境变量A为随机值", style: _cTextStyle),
                  onPressed: () async {
                    var random = Random.secure().nextInt(100);
                    ExecuteResult res = await CommandUtil.getInstance()
                        .setSystemEnvVar("A", "$random");
                    if (res.exitCode == 0) {
                      showMyInfo(
                          title: "提示",
                          content: "设置环境变量A的值为 $random 成功",
                          severity: InfoBarSeverity.success);
                    } else {
                      showMyInfo(
                          title: "提示",
                          content: "设置环境变量A失败",
                          severity: InfoBarSeverity.error);
                    }
                  }),
              const SizedBox(width: 10),
              Button(
                  child: Text("打开环境变量设置", style: _cTextStyle),
                  onPressed: () async {
                    var res = await CommandUtil.getInstance().openEnvSetting();
                    debugPrint("查询到的A的值为： $res  ");
                  }),
              const SizedBox(width: 10),
            ],
          ),
        ],
      ),
    );
  }

  Widget _workspaceChoose() {
    return _envChooseWidget(
        title: "工作空间",
        init: () => _envParamModel.workSpaceRoot,
        action: (selectedDirectory) {
          DialogUtil.showInfo(
              context: context, title: '选择了路径:', content: selectedDirectory);
          _envParamModel.workSpaceRoot = selectedDirectory;
        });
  }

  Widget _androidSdkChoose() {
    return _envChooseWidget(
        title: "Android SDK",
        init: () => _envParamModel.androidSdkRoot,
        action: (selectedDirectory) async {
          String envKey = "ANDROID_HOME";

          if (_envParamModel.androidSdkRoot == selectedDirectory) {
            // 当前路径相同
            showMyInfo(
              title: "选择的路径与当前路径相同 ",
              content: selectedDirectory,
              severity: InfoBarSeverity.warning,
            );
            return;
          }

          // 选择了 androidSDK之后，
          // 1. 检查SDK的可用性，不可用，终止，可用继续往下
          // 2. 检查 echo %ANDROID_HOME% 的值是不是和当前值相同，不同，设置 环境变量 ANDROID_HOME 为选择的路径，相同，结束
          bool enable = await _checkAndroidSdkEnable(selectedDirectory);
          if (!enable) {
            showMyInfo(
              title: '错误:',
              content: "Android SDK  $selectedDirectory 不可用，缺少必要组件",
              severity: InfoBarSeverity.warning,
            );
            return;
          }

          var executeResult = await CommandUtil.getInstance()
              .setSystemEnvVar(envKey, selectedDirectory);
          if (executeResult.exitCode == 0) {
            _envParamModel.androidSdkRoot = selectedDirectory;
            showMyInfo(
                title: "用户环境变量 $envKey设置成功: ", content: selectedDirectory);

            String echoAndroidHome = await CommandUtil.getInstance().echoCmd(
              order: "%$envKey%",
              action: (s) {},
            );

            debugPrint('echoAndroidHome -> $echoAndroidHome');
          } else {
            showMyInfo(
                title: "错误",
                content: "<3>环境变量设置失败 ${executeResult.res}",
                severity: InfoBarSeverity.warning);
          }
        });
  }

  /// 阶段任务执行设置
  _stageTaskExecuteSetting() {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 9),
      borderColor: Colors.transparent,
      backgroundColor: _appTheme.bgColorSucc,
      borderRadius: BorderRadius.circular(5),
      child: Row(children: [
        Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text("阶段任务执行参数设置", style: _cTextStyle),
          const SizedBox(height: 20),
          Row(children: [
            Expanded(
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                  Text("每次最大可执行时间", style: _cTextStyle),
                  const Spacer(),
                  ComboBox<String>(
                    value: _envParamModel.stageTaskExecuteMaxPeriod,
                    items: _envParamModel.executePeriodList
                        .map<ComboBoxItem<String>>((e) {
                      return ComboBoxItem<String>(
                          value: e, child: Text(e, style: _cTextStyle));
                    }).toList(),
                    onChanged: (c) => setState(
                        () => _envParamModel.stageTaskExecuteMaxPeriod = c!),
                  ),
                  const SizedBox(width: 20),
                  Text("分钟", style: _cTextStyle),
                ])),
            const SizedBox(width: 100),
            Expanded(
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                  Text("最大可执行次数", style: _cTextStyle),
                  const Spacer(),
                  ComboBox<String>(
                    value: _envParamModel.stageTaskExecuteMaxRetryTimes,
                    items: _envParamModel.executeTimes
                        .map<ComboBoxItem<String>>((e) {
                      return ComboBoxItem<String>(
                          value: e, child: Text(e, style: _cTextStyle));
                    }).toList(),
                    onChanged: (c) => setState(() =>
                        _envParamModel.stageTaskExecuteMaxRetryTimes = c!),
                  ),
                  const SizedBox(width: 20),
                  Text("次", style: _cTextStyle),
                ]))
          ])
        ]))
      ]),
    );
  }

  /// 阶段任务执行设置
  _pgySetting() {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 9),
      borderColor: Colors.transparent,
      backgroundColor: _appTheme.bgColorSucc,
      borderRadius: BorderRadius.circular(5),
      child: Row(children: [
        Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text("蒲公英平台设置", style: _cTextStyle),
          const SizedBox(height: 20),
          _textInput('_api_key', _envParamModel.pgyApiKeyController),
        ]))
      ]),
    );
  }

  Widget _textInput(String label, TextEditingController controller,
      {bool judgeHttpsReg = false}) {
    var dataCorrect = true;
    if (judgeHttpsReg) {
      dataCorrect = isHttpsUrl(controller.text);
    }
    return Row(children: [
      Expanded(
          child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
            SizedBox(width: 150, child: Text(label, style: _cTextStyle)),
            const Spacer(),
            Expanded(
              child: TextBox(
                decoration: BoxDecoration(
                    border: Border.all(
                        color: dataCorrect ? Colors.white : Colors.red,
                        width: 1)),
                unfocusedColor: Colors.transparent,
                highlightColor: Colors.transparent,
                controller: controller,
                textAlign: TextAlign.end,
                style: _cTextStyle,
              ),
            )
          ])),
    ]);
  }

  _hwobsSetting() {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 9),
      borderColor: Colors.transparent,
      backgroundColor: _appTheme.bgColorSucc,
      borderRadius: BorderRadius.circular(5),
      child: Row(children: [
        Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text("华为OBS平台设置", style: _cTextStyle),
          const SizedBox(height: 20),
          _textInput('end point ', _envParamModel.obsEndPointController,
              judgeHttpsReg: true),
          const SizedBox(height: 10),
          _textInput('access key', _envParamModel.obsAccessKeyController),
          const SizedBox(height: 10),
          _textInput('secret key', _envParamModel.obsSecretKeyController),
          const SizedBox(height: 10),
          _textInput('bucket name', _envParamModel.obsBucketNameController),
        ]))
      ]),
    );
  }

  final _cTextStyle =
      const TextStyle(fontSize: 19, fontWeight: FontWeight.w600);
}
