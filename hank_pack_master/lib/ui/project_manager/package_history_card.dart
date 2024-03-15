import 'package:fluent_ui/fluent_ui.dart';
import 'package:hank_pack_master/comm/pgy/pgy_entity.dart';
import 'package:hank_pack_master/comm/text_util.dart';

import '../../comm/dialog_util.dart';
import '../../hive/project_record/upload_platforms.dart';
import '../work_shop/app_info_card.dart';

class PackageHistoryCard extends StatelessWidget {
  final MyAppInfo myAppInfo;
  final Function(String apkPath)? doFastUpload;

  const PackageHistoryCard({
    super.key,
    required this.myAppInfo,
    this.doFastUpload,
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
      return Container(
        constraints: const BoxConstraints(maxHeight: 300),
        child: Text(
          errMsg.sub(100),
          style: _style,
          maxLines: 4,
          overflow: TextOverflow.clip,
        ),
      );
    } else {
      return const SizedBox();
    }
  }

  final _style = const TextStyle(fontWeight: FontWeight.w600, fontSize: 16);

  @override
  Widget build(BuildContext context) {
    Widget fastUploadBtn;
    // 如果显示的内容里包含了 []，那就提取出[]中的内容，并且启用强制上传策略
    if (myAppInfo.errMessage != null &&
        myAppInfo.errMessage!.contains("[") &&
        myAppInfo.errMessage!.contains("]")) {
      // 那就提炼出中括号中的内容

      var apkPath = myAppInfo.errMessage!.substring(
          myAppInfo.errMessage!.indexOf("[") + 1,
          myAppInfo.errMessage!.indexOf("]"));
      fastUploadBtn = FilledButton(
        child: const Text("快速上传"),
        onPressed: () {
          Navigator.pop(context);
          doFastUpload?.call(apkPath);
        },
      );
    } else {
      fastUploadBtn = const SizedBox();
    }

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
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  fastUploadBtn,
                ],
              ),
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
    var card = AppInfoCard(appInfo: s,initiallyExpanded: true,);

    double maxHeight = s.errMessage.empty() ? 400 : 900;

    DialogUtil.showCustomDialog(
      context: context,
      content: card,
      title: '历史查看',
      showActions: true,
      showCancel: false,
      confirmText: '我知道了！',
      maxWidth: 800,
      maxHeight: maxHeight,
    );
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
