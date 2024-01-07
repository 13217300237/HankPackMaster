import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/material.dart' as m;
import 'package:provider/provider.dart';

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

  Future<String> getReady() async {
    var s = await envParamModel.isAndroidEnvOk();
    if (s) {
      return "android SDK env ready!";
    } else {
      throw "AndroidSDK not ok!!!";
    }
  }

  @override
  Widget build(BuildContext context) {
    envParamModel = context.watch<EnvParamVm>();
    return FutureBuilder(
        future: getReady(),
        builder: (context, snapShot) {
          if (ConnectionState.waiting == snapShot.connectionState) {
            return const Center(child: ProgressRing());
          } else if (snapShot.hasError) {
            return Center(
              child: FilledButton(
                child: Text("Error :${snapShot.error}",
                    style: const TextStyle(color: m.Colors.white)),
                onPressed: () => debugPrint('pressed button'),
              ),
            );
          } else {
            return Center(
              child: _mainLayout(),
            );
          }
        });
  }

  Widget _mainLayout(){
    return Column(children: [
      InfoLabel(
        label: '工程名',
        child: const TextBox(
          placeholder: 'Name',
          expands: false,
        ),
      )
    ],);
  }

  Future<void> _showInfo(String title, String content) async {
    await displayInfoBar(context, builder: (context, close) {
      return InfoBar(
          title: Text(title),
          content: Text(content),
          action: IconButton(
              icon: const Icon(FluentIcons.chrome_close), onPressed: close),
          severity: InfoBarSeverity.warning);
    });
  }
}
