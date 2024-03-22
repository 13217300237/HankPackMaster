import 'package:fluent_ui/fluent_ui.dart';
import 'package:hank_pack_master/comm/ui/text_on_arc.dart';
import 'package:jiffy/jiffy.dart';

import '../../hive/project_record/job_history_entity.dart';
import '../../hive/project_record/project_record_operator.dart';
import '../../ui/project_manager/grid_datasource.dart';
import '../../ui/project_manager/job_setting_card.dart';
import '../../ui/work_shop/app_info_card.dart';
import '../pgy/pgy_entity.dart';
import '../text_util.dart';

class HistoryCard extends StatelessWidget {
  final JobHistoryEntity entity;
  final double maxHeight;

  const HistoryCard({
    super.key,
    required this.entity,
    required this.maxHeight,
  });

  final TextStyle _style = const TextStyle(
    fontSize: 15,
    color: Colors.black,
    fontWeight: FontWeight.w600,
    fontFamily: 'STKAITI',
  );

  @override
  Widget build(BuildContext context) {
    MyAppInfo myAppInfo;
    try {
      myAppInfo = MyAppInfo.fromJsonString(entity.historyContent!);
    } catch (ex) {
      myAppInfo = MyAppInfo(errMessage: entity.historyContent); // 针对激活成功，这里要做判断
    }

    var color = const Color(0xffe0e0e0);

    return MouseRegion(
      onEnter: (event) {
        ProjectRecordOperator.setReadV2(jobHistoryEntity: entity);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
        child: Stack(
          children: [
            Column(children: [
              _title(entity, color),
              Card(
                  borderColor: Colors.transparent,
                  backgroundColor: color,
                  borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(10),
                      bottomRight: Radius.circular(10)),
                  child: Stack(children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _text("git地址", entity.gitUrl ?? ''),
                        _text("分支名", entity.branchName ?? ''),
                        _text(
                            "构建时间",
                            Jiffy.parseFromDateTime(
                                    DateTime.fromMillisecondsSinceEpoch(
                                        entity.buildTime ?? 0))
                                .format(pattern: "yyyy-MM-dd HH:mm:ss")),
                        const SizedBox(height: 10),
                        JobSettingCard(entity.jobSetting),
                        const SizedBox(height: 10),
                        AppInfoCard(
                          appInfo: myAppInfo,
                          initiallyExpanded: false,
                          maxHeight: maxHeight,
                        ),
                        const SizedBox(height: 10),
                        _stageListCard(entity),
                      ],
                    ),
                    Positioned(
                        right: 10,
                        top: 10,
                        child: Visibility(
                            visible: entity.hasRead != true,
                            child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Card(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 5, horizontal: 15),
                                      backgroundColor: Colors.red,
                                      borderRadius: BorderRadius.circular(7),
                                      child: const Text(
                                        "NEW",
                                        style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 16,
                                            color: Colors.white),
                                      )),
                                ])))
                  ]))
            ]),
            Positioned(
              right: 10,
              top: 10,
              child: _tag(),
            ),
          ],
        ),
      ),
    );
  }

  /// 要根据任务的成功和失败来确定印章的内容
  Widget _tag() {
    String text() {
      return entity.success == true ? "执行成功" : "执行失败";
    }

    Color color() {
      return entity.success == true ? Colors.green.darkest : Colors.red.darkest;
    }

    return TextOnArcWidget(
      arcStyle: ArcStyle(
          text: text(),
          strokeWidth: 4,
          radius: 60,
          textSize: 20,
          textColor: color(),
          arcColor: color(),
          padding: 18),
    );
  }

  Widget _title(JobHistoryEntity e, Color color) {
    return Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
        decoration: BoxDecoration(
            color: color,
            borderRadius: const BorderRadius.only(
                topRight: Radius.circular(10), topLeft: Radius.circular(10))),
        width: double.infinity,
        child: Text("${e.projectName}",
            style: const TextStyle(
              fontSize: 25,
              color: Colors.black,
              fontWeight: FontWeight.w600,
            )));
  }

  Widget _text(String title, String content) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 5),
      child: Row(
        children: [
          Text("$title : ", style: gridTextStyle2),
          Text(
            content,
            style: gridTextStyle3,
          )
        ],
      ),
    );
  }

  _stageListCard(JobHistoryEntity e) {
    if (e.stageRecordList == null || e.stageRecordList!.isEmpty) {
      return const SizedBox();
    }

    Color bg(bool? success) {
      return (success ?? false)
          ? Colors.green.withOpacity(.1)
          : Colors.red.withOpacity(.1);
    }

    return Expander(
      initiallyExpanded: !(e.success ?? false),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ...?e.stageRecordList
              ?.map((stageRecord) => Padding(
                    padding: const EdgeInsets.only(bottom: 10.0),
                    child: Expander(
                      initiallyExpanded: false,
                      headerBackgroundColor: ButtonState.resolveWith(
                          (states) => bg(stageRecord.success)),
                      header: RichText(
                          text: TextSpan(children: [
                        TextSpan(
                            text: "${stageRecord.name}     ",
                            style: _style.copyWith(fontSize: 16)),
                        TextSpan(
                            text: formatSeconds(stageRecord.costTime ?? 0),
                            style: _style.copyWith(color: Colors.blue)),
                      ])),
                      content: Container(
                        width: double.infinity,
                        constraints: const BoxConstraints(maxHeight: 300),
                        margin: const EdgeInsets.symmetric(vertical: 5.0),
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Card(
                                child: SizedBox(
                                  width: double.infinity,
                                  child: TextSelectionTheme(
                                    data: TextSelectionThemeData(
                                      selectionColor:
                                          Colors.green.withOpacity(.3),
                                      // 修改选中文本的背景颜色
                                      selectionHandleColor:
                                          Colors.red, // 修改选中文本的选择手柄颜色
                                    ),
                                    child: SelectableText(
                                        "${stageRecord.resultStr?.formatJson()}",
                                        style: _style),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 15),
                              Text("${stageRecord.fullLog}", style: _style)
                            ],
                          ),
                        ),
                      ),
                    ),
                  ))
              .toList()
        ],
      ),
      header: Text("阶段日志详情", style: _style),
    );
  }
}
