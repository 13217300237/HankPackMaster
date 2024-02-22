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

  Color _bgColor() {
    String? errMsg = myAppInfo.errMessage;
    if (errMsg != null && errMsg.isNotEmpty) {
      return Colors.red.withOpacity(.2);
    } else {
      return Colors.green.withOpacity(.2);
    }
  }

  Widget errWidget() {
    String? errMsg = myAppInfo.errMessage;
    if (errMsg != null && errMsg.isNotEmpty) {
      return Text(
        errMsg,
        style: _style,
      );
    } else {
      return const SizedBox();
    }
  }

  final _style = const TextStyle(fontWeight: FontWeight.w600, fontSize: 16);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () => showMyAppInfo(myAppInfo, context),
        child: Card(
            margin: const EdgeInsets.all(4),
            backgroundColor: _bgColor(),
            borderColor: _bgColor(),
            borderRadius: BorderRadius.circular(4),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              _uploadPlatformWidget(),
              _timeWidget(),
              errWidget(),
            ])));
  }

  Widget _timeWidget() {
    if (myAppInfo.buildUpdated == null || myAppInfo.buildUpdated!.isEmpty) {
      return const SizedBox();
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Text("打包时间: ${myAppInfo.buildUpdated}", style: _style),
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

  _uploadPlatformWidget() {
    if (myAppInfo.buildUpdated == null || myAppInfo.buildUpdated!.isEmpty) {
      return const SizedBox();
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Text(
        "上传方式: ${UploadPlatform.findNameByIndex('${myAppInfo.uploadPlatform}')}",
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
      ),
    );
  }
}
