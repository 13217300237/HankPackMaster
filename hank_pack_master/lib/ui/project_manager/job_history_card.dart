import 'package:fluent_ui/fluent_ui.dart';
import 'package:hank_pack_master/comm/pgy/pgy_entity.dart';
import 'package:hank_pack_master/comm/text_util.dart';
import 'package:hank_pack_master/hive/project_record/job_history_entity.dart';
import 'package:hank_pack_master/hive/project_record/package_setting_entity.dart';
import 'package:hank_pack_master/hive/project_record/project_record_entity.dart';

import '../../comm/dialog_util.dart';
import '../../hive/project_record/upload_platforms.dart';
import '../work_shop/app_info_card.dart';
import 'job_setting_card.dart';

/// 作业历史弹窗
class JobHistoryCard extends StatefulWidget {
  final ProjectRecordEntity projectRecordEntity;
  final JobHistoryEntity jobHistoryEntity;
  final MyAppInfo myAppInfo;
  final Function(String apkPath)? doFastUpload;
  final Function() onRead;

  const JobHistoryCard({
    super.key,
    required this.myAppInfo,
    this.doFastUpload,
    required this.projectRecordEntity,
    required this.jobHistoryEntity,
    required this.onRead,
  });

  @override
  State<JobHistoryCard> createState() => _JobHistoryCardState();
}

class _JobHistoryCardState extends State<JobHistoryCard> {
  Color _bgColor() {
    String? errMsg = widget.myAppInfo.errMessage;
    if (errMsg != null && errMsg.isNotEmpty) {
      return Colors.red.withOpacity(.2);
    } else {
      return Colors.green.withOpacity(.2);
    }
  }

  Widget errWidget() {
    String? errMsg = widget.myAppInfo.errMessage;
    if (errMsg != null && errMsg.isNotEmpty) {
      return Expander(
        initiallyExpanded: true,
        headerBackgroundColor:
            ButtonState.resolveWith((states) => Colors.orange.withOpacity(.1)),
        header: Text("错误详情", style: _style),
        content: Container(
          constraints: const BoxConstraints(maxHeight: 300),
          child: Text(
            errMsg.sub(600),
            style: _style,
            maxLines: 4,
            overflow: TextOverflow.clip,
          ),
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
    if (widget.myAppInfo.errMessage != null &&
        widget.myAppInfo.errMessage!.contains("[") &&
        widget.myAppInfo.errMessage!.contains("]")) {
      // 那就提炼出中括号中的内容

      var apkPath = widget.myAppInfo.errMessage!.substring(
          widget.myAppInfo.errMessage!.indexOf("[") + 1,
          widget.myAppInfo.errMessage!.indexOf("]"));
      fastUploadBtn = FilledButton(
        child: const Text("快速上传"),
        onPressed: () {
          Navigator.pop(context);
          widget.doFastUpload?.call(apkPath);
        },
      );
    } else {
      fastUploadBtn = const SizedBox();
    }

    var hasRead = (widget.jobHistoryEntity.hasRead ?? false);
    var jobSetting = widget.jobHistoryEntity.jobSetting;

    return GestureDetector(
        onTap: () {
          widget.onRead();
          showMyAppInfo(widget.myAppInfo, context);
          setState(() {});
        },
        child: Stack(
          children: [
            Card(
                margin: const EdgeInsets.all(4),
                backgroundColor: _bgColor(),
                borderColor: _bgColor(),
                borderRadius: BorderRadius.circular(10),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _timeWidget(),
                      JobSettingCard(jobSetting),
                      Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: errWidget()),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [fastUploadBtn],
                      ),
                    ])),
            Positioned(
              right: 10,
              top: 10,
              child: Visibility(
                visible: !hasRead,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Card(
                        padding: const EdgeInsets.symmetric(
                            vertical: 5, horizontal: 15),
                        backgroundColor: Colors.red,
                        borderRadius: BorderRadius.circular(7),
                        child: Text(
                          "NEW",
                          style: _style.copyWith(color: Colors.white),
                        )),
                  ],
                ),
              ),
            ),
          ],
        ));
  }

  Widget _timeWidget() {
    if (widget.myAppInfo.buildUpdated == null ||
        widget.myAppInfo.buildUpdated!.isEmpty) {
      return const SizedBox();
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Text("作业时间: ${widget.myAppInfo.buildUpdated}", style: _style),
    );
  }

  void showMyAppInfo(MyAppInfo s, BuildContext context) {
    var card = AppInfoCard(appInfo: s, initiallyExpanded: true);
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
}
