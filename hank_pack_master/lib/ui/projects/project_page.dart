import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/material.dart' as m;
import 'package:provider/provider.dart';

import '../../core/command_util.dart';
import '../../test/env_param_vm.dart';

class ProjectPage extends StatefulWidget {
  const ProjectPage({super.key});

  @override
  State<ProjectPage> createState() => _ProjectPageState();
}

class _ProjectPageState extends State<ProjectPage> {
  late EnvParamVm envParamModel;

  Future<String> getReady() async {
    await Future.delayed(const Duration(milliseconds: 500));
    if (envParamModel.androidSdkRoot.isNotEmpty) {
      return "环境就绪";
    } else {
      throw "环境存在问题";
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
            return Text("Error :${snapShot.error}",
                style: const TextStyle(color: m.Colors.red));
          } else {
            return Center(
              child: Button(
                onPressed: () {
                  _showInfo("提示", "环境已就绪，随时可以打包");
                },
                child: const Text("环境就绪"),
              ),
            );
          }
        });
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
