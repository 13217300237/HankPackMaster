import 'package:fluent_ui/fluent_ui.dart';
import 'package:hank_pack_master/comm/pgy/pgy_entity.dart';

import '../../comm/dialog_util.dart';
import '../../comm/upload_platforms.dart';
import '../work_shop/app_info_card.dart';

class PackageHistoryCard extends StatelessWidget {
  final MyAppInfo myAppInfo;

  const PackageHistoryCard({
    super.key,
    required this.myAppInfo,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => showMyAppInfo(myAppInfo, context),
      child: Card(
        margin: const EdgeInsets.all(4),
        backgroundColor: Colors.green.withOpacity(.2),
        borderColor: Colors.green.withOpacity(.4),
        borderRadius: BorderRadius.circular(4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
                "上传方式: ${UploadPlatform.findNameByIndex('${myAppInfo.uploadPlatform}')}"),
            const SizedBox(height: 10),
            Text("打包时间: ${myAppInfo.buildUpdated}"),
          ],
        ),
      ),
    );
  }

  void showMyAppInfo(MyAppInfo s, BuildContext context) {
    var card = AppInfoCard(appInfo: s);

    DialogUtil.showCustomDialog(
        context: context,
        content: card,
        title: '历史查看',
        showCancel: false,
        confirmText: "关闭");
  }
}
