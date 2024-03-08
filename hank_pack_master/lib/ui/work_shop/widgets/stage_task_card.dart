import 'dart:async';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:provider/provider.dart';

import '../../../comm/dialog_util.dart';
import '../../../comm/order_execute_result.dart';
import '../../../comm/pgy/pgy_entity.dart';
import '../../../comm/text_util.dart';
import '../app_info_card.dart';
import '../task_stage.dart';
import 'package:flutter/material.dart' as m;

/// 每个阶段任务的卡片
class StageTaskCard extends StatefulWidget {
  final TaskStage stage;
  final int index;
  final Color statueColor;
  final TimerController controller;

  const StageTaskCard({
    super.key,
    required this.stage,
    required this.index,
    required this.statueColor,
    required this.controller,
  });

  @override
  State<StageTaskCard> createState() => _StageTaskCardState();
}

class _StageTaskCardState extends State<StageTaskCard> {
  void _showMyAppInfo(MyAppInfo s) {
    var card = AppInfoCard(appInfo: s);

    DialogUtil.showCustomDialog(
      context: context,
      content: card,
      title: '流程结束',
    );
  }

  void _showInfoDialog({
    required String title,
    required String msg,
    String? executeLog,
  }) {
    DialogUtil.showCustomDialog(
        context: context,
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              msg,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
            if (!executeLog.empty()) ...[
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 350,
                child: m.Card(
                  elevation: 3,
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: Text(
                        "$executeLog",
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
        title: title,
        showCancel: false,
        confirmText: '我知道了...');
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SizedBox(
        width: 150,
        child: FilledButton(
          onPressed: () {
            // 按下之后，打开当前阶段的执行结果弹窗
            var result = widget.stage.executeResultData;
            if (result is OrderExecuteResult) {
              debugPrint("啊啊啊啊啊啊啊啊啊：${result.executeLog}");
              var data = result.data;
              if (data is MyAppInfo) {
                // 最后阶段上传成功之后
                _showMyAppInfo(data);
              } else {
                // 其他阶段
                _showInfoDialog(
                    title: widget.stage.stageName,
                    msg: '${widget.stage.executeResultData}',
                    executeLog: "${result.executeLog}");
              }
            }
          },
          style: ButtonStyle(backgroundColor: ButtonState.resolveWith((states) {
            if (states.isHovering) {
              return widget.statueColor.withOpacity(.8);
            } else {
              return widget.statueColor.withOpacity(1);
            }
          })),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.stage.stageName,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                ChangeNotifierProvider.value(
                  value: widget.controller,
                  child: Consumer<TimerController>(
                    builder: (context, controller, _) {
                      if (controller.seconds > 0) {
                        return Text(
                            "执行耗时:${formatSeconds(controller.seconds)}");
                      } else {
                        return const SizedBox();
                      }
                    },
                  ),
                ),
                if (widget.stage.stageCostTime != null &&
                    widget.stage.stageCostTime!.isNotEmpty)
                  Text(
                    widget.stage.stageCostTime!,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class TimerController with ChangeNotifier {
  bool _isRunning = false;
  int _seconds = 0;
  Timer? _timer;

  bool get isRunning => _isRunning;

  int get seconds => _seconds;

  void start() {
    _isRunning = true;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _seconds++;
      notifyListeners();
    });
  }

  void stop() {
    _isRunning = false;
    _timer?.cancel();
    _timer = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
