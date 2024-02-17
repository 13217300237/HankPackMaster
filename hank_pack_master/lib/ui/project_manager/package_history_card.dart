import 'package:fluent_ui/fluent_ui.dart';
import 'package:hank_pack_master/comm/pgy/pgy_entity.dart';

import '../../comm/dialog_util.dart';
import '../work_shop/app_info_card.dart';

class PackageHistoryCard extends StatelessWidget {
  final MyAppInfo myAppInfo;

  const PackageHistoryCard({
    super.key,
    required this.myAppInfo,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(4),
      borderColor: Colors.green,
      borderRadius: BorderRadius.circular(2),
      child: GestureDetector(
          child: Text("打包时间: ${myAppInfo.buildUpdated}"),
          onTap: () => showMyAppInfo(myAppInfo, context)),
    );
  }

  void showMyAppInfo(MyAppInfo s, BuildContext context) {
    var card = AppInfoCard(appInfo: s);

    DialogUtil.showCustomDialog(
        context: context,
        content: card,
        title: '流程结束',
        showCancel: false,
        confirmText: "关闭");
  }
}
