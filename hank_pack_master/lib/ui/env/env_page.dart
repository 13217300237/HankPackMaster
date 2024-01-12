import 'package:file_picker/file_picker.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:hank_pack_master/comm/dialog_util.dart';
import 'package:oktoast/oktoast.dart';
import 'package:provider/provider.dart';

import '../../core/command_util.dart';
import '../../test/env_param_vm.dart';
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
  Map<String, Set<String>> envs = {};

  late AppTheme _appTheme;
  late EnvParamVm _envParamModel;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 500), () {
      checkAction(showLoading: false);
    });
  }

  @override
  Widget build(BuildContext context) {
    _envParamModel = context.watch<EnvParamVm>();
    _appTheme = context.watch<AppTheme>();

    List<Widget> envWidgets = [];

    envs.forEach((key, value) =>
        envWidgets.add(_buildEnvTile(key, value, _envParamModel)));

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
            showToast("选择了空路径");
          } else {
            showToast(selectedDirectory);
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
                    child: Button(
                        child: const Text("重新检测环境"),
                        onPressed: () {
                          checkAction();
                        }),
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

  Widget _buildEnvTile(
      String title, Set<String> content, EnvParamVm envParamModel) {
    List<Widget> muEnv = [];
    for (var binRoot in content) {
      muEnv.add(
        Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: RadioButton(
              checked: envParamModel.judgeEnv(title, binRoot),
              onChanged: (v) => envParamModel.setEnv(title, binRoot),
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

  checkAction({bool showLoading = true}) async {
    if (showLoading) {
      EasyLoading.show(
          status: '正在初始化环境参数...', maskType: EasyLoadingMaskType.clear);
    }
    envs = await CommandUtil.getInstance().initAllEnvParam(action: (r) {
      debugCmdPrint("环境检索的日志输出:$r");
    });
    if (showLoading) {
      EasyLoading.dismiss();
    }
    if (mounted) {
      setState(() {});
    }
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
