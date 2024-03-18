import 'package:fluent_ui/fluent_ui.dart';

import '../../hive/project_record/package_setting_entity.dart';

class JobSettingCard extends StatelessWidget {
  final PackageSetting? jobSetting;

  const JobSettingCard(this.jobSetting, {super.key});

  final _style = const TextStyle(fontWeight: FontWeight.w600, fontSize: 15);

  @override
  Widget build(BuildContext context) {
    return _jobSettingWidget();
  }

  _jobSettingWidget() {
    if (jobSetting == null) return const SizedBox();

    var s = jobSetting!;

    return Expander(
      headerBackgroundColor:
          ButtonState.resolveWith((states) => Colors.orange.withOpacity(.1)),
      header: Text('查看打包配置', style: _style),
      initiallyExpanded: true,
      content: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _tileText(title: "打包命令 :", content: s.selectedOrder ?? ''),
                _tileText(
                    title: "更新日志 :",
                    content: s.appUpdateLog ?? '',
                    maxLines: 3),
                _tileText(
                    title: " JDK路径 :", content: s.jdk?.envPath.trim() ?? ''),
                _tileText(
                    title: "上传平台 :",
                    content: s.selectedUploadPlatform?.name ?? ''),
                _tileText(title: "合并分支 :", content: s.mergedList),
                _tileText(title: "APK位置 :", content: s.apkLocation ?? ''),
              ],
            ),
          ),
        ],
      ),
    );
  }

  _tileText(
      {required String title, required String content, int maxLines = 1}) {
    if (content.isEmpty) return const SizedBox();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        SizedBox(width: 70, child: Text(title, style: _style)),
        const SizedBox(width: 10),
        Expanded(
          child: Tooltip(
            message: content,
            child: Text(content,
                style: _style,
                overflow: TextOverflow.ellipsis,
                maxLines: maxLines),
          ),
        )
      ]),
    );
  }
}
