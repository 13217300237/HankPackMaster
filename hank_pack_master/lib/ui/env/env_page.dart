import 'package:file_picker/file_picker.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:hank_pack_master/comm/dialog_util.dart';
import 'package:oktoast/oktoast.dart';
import 'package:provider/provider.dart';

import '../../core/command_util.dart';
import 'env_param_vm.dart';
import '../comm/theme.dart';

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

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _envParamModel.checkAction(showLoading: false);
    });
  }

  void showWrongInfo(String content) {
    DialogUtil.showInfo(context: context, content: content);
  }

  @override
  Widget build(BuildContext context) {
    _envParamModel = context.watch<EnvParamVm>();
    _appTheme = context.watch<AppTheme>();

    List<Widget> envWidgets = [];

    _envParamModel.envs.forEach((key, value) {
      envWidgets.add(_buildEnvTile(key, value));
    });

    // 工作空间路径设置
    var workspaceRoot = _card("workSpaceRoot", [
      if (!_envParamModel.isEnvEmpty("workSpaceRoot")) ...[
        Padding(
          padding: const EdgeInsets.only(bottom: 20),
          child: Text(
            "当前路径: ${_envParamModel.workSpaceRoot}",
            style: const TextStyle(
                fontFamily: "STKAITI",
                fontWeight: FontWeight.w600,
                fontSize: 29),
          ),
        )
      ],
      Button(
        child: const Text("Click here to set workspaceRoot"),
        onPressed: () async {
          String? selectedDirectory =
              await FilePicker.platform.getDirectoryPath();

          if (selectedDirectory == null) {
            showWrongInfo("选择了空路径");
          } else {
            showWrongInfo(selectedDirectory);
            _envParamModel.workSpaceRoot = selectedDirectory;
          }
        },
      )
    ]);

    return Container(
        padding: const EdgeInsets.all(30),
        child: ScrollConfiguration(
            // 隐藏scrollBar
            behavior:
                ScrollConfiguration.of(context).copyWith(scrollbars: false),
            child: SingleChildScrollView(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        Button(
                          onPressed: _envParamModel.checkAction,
                          child: const Text("重新检测"),
                        ),
                        const SizedBox(width: 20),
                        Button(
                            onPressed: () {
                              _envParamModel.resetEnv(() {
                                DialogUtil.showInfo(
                                    context: context, content: "环境参数已清空");
                              });
                            },
                            child: const Text("清空当前环境")),
                      ],
                    ),
                  ),
                  workspaceRoot,
                  ...envWidgets,
                ]))));
  }

  @override
  void dispose() {
    super.dispose();
    debugPrint("envPage dispose");
  }

  Widget _buildEnvTile(String title, Set<String> content) {
    List<Widget> muEnv = [];
    for (var binRoot in content) {
      muEnv.add(
        Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: RadioButton(
              checked: _envParamModel.judgeEnv(title, binRoot),
              onChanged: (v) => _envParamModel.setEnv(title, binRoot),
              content: Row(
                children: [
                  Text(binRoot, style: const TextStyle(fontSize: 16)),
                  const SizedBox(width: 20),
                  Button(
                    child: Text(
                      'Test',
                      style: TextStyle(color: _appTheme.accentColor),
                    ),
                    onPressed: () async {
                      EasyLoading.show(status: 'loading...');
                      var s = await CommandUtil.getInstance()
                          .checkEnv(title, binRoot);
                      EasyLoading.dismiss();

                      Future.delayed(const Duration(milliseconds: 200), () {
                        showCmdResultDialog(s);
                      });
                    },
                  )
                ],
              )),
        ),
      );
    }

    return _card(title, muEnv);
  }

  Widget _card(String title, List<Widget> muEnv) {
    return Row(mainAxisSize: MainAxisSize.max, children: [
      Expanded(
          child: Container(
              padding: const EdgeInsets.all(20),
              margin: const EdgeInsets.all(10),
              decoration: _boxBorder(title),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(fontSize: 30),
                    ),
                    const SizedBox(height: 15),
                    ...muEnv,
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
        boxShadow: [
          BoxShadow(
            color: boxColor,
            blurRadius: 2, // 控制卡片的模糊程度
            offset: const Offset(0, 2), // 控制卡片的偏移量
          ),
        ],
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.grey[200], width: .5));
  }

  void showCmdResultDialog(String res) {
    DialogUtil.showEnvCheckDialog(
      context: context,
      onConfirm: null,
      content: res,
      title: "测试结果",
    );
  }
}
