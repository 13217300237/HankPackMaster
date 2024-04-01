import 'package:desktop_drop/desktop_drop.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/material.dart' as m;
import 'package:hank_pack_master/comm/gradients.dart';
import 'package:hank_pack_master/ui/apk_trace/vm/apk_trace_vm.dart';
import 'package:provider/provider.dart';

import '../../comm/dialog_util.dart';
import '../../comm/file_ext.dart';
import '../../comm/ui/history_card.dart';
import '../../comm/ui/info_bar.dart';
import '../../hive/project_record/job_history_entity.dart';

/// 文件快传，选中一个文件，并且
class ApkTracePage extends StatefulWidget {
  const ApkTracePage({super.key});

  @override
  State<ApkTracePage> createState() => _ApkTracePageState();
}

class _ApkTracePageState extends State<ApkTracePage> {
  @override
  void initState() {
    super.initState();
  }

  Widget traceResultWidget({
    required double maxHeight,
    required List<JobHistoryEntity> list,
  }) {
    return ListView.builder(
      itemBuilder: (context, index) {
        var e = list[index];
        return HistoryCard(
          historyEntity: e,
          maxHeight: maxHeight,
          projectRecordEntity: e.parentRecord,
        );
      },
      itemCount: list.length,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      child: _mainBox(),
      create: (BuildContext context) => ApkTraceVm(
        func: (List<JobHistoryEntity> list) {
          DialogUtil.showCustomDialog(
              context: context,
              title: '回溯結果',
              maxWidth: 1200,
              content: traceResultWidget(maxHeight: 700, list: list),
              showCancel: false);
        },
      ),
    );
  }

  Widget _mainBox() {
    return Consumer<ApkTraceVm>(
      builder: (context, vm, child) {
        return Stack(
          children: [
            DropTarget(
              onDragDone: vm.onDragDone,
              onDragEntered: vm.onDragEntered,
              onDragExited: vm.onDragExited,
              child: Container(
                  decoration: BoxDecoration(gradient: mainPanelGradient),
                  padding: const EdgeInsets.all(15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('APK回溯', style: vm.textStyle2),
                      const SizedBox(height: 12),
                      _toolTip(),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(flex: 5, child: _fileSelectorWidget(vm)),
                        ],
                      ),
                    ],
                  )),
            ),
            vm.tracing ? _loadingDialog() : const SizedBox()
          ],
        );
      },
    );
  }

  _loadingDialog() {
    return Container(
      color: Colors.grey.withOpacity(.5),
      width: double.infinity,
      height: double.infinity,
      child: const Center(
          child: Card(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 29),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ProgressRing(
                activeColor: m.Colors.blue,
              ),
              SizedBox(height: 20),
              Text(
                '回溯检索中...',
                style: TextStyle(fontSize: 20, color: m.Colors.blue),
              ),
            ],
          ),
        ),
      )),
    );
  }

  var style = const TextStyle(
      fontSize: 16, fontWeight: m.FontWeight.w600, fontFamily: 'STKAITI');

  // 每次仅仅支持一个文件
  Widget _fileSelectorWidget(ApkTraceVm vm) {
    var toChooseWidget = GestureDetector(
      onTap: () async => vm.doFileChoose(),
      child: Container(
        color: Colors.transparent,
        width: double.infinity,
        height: double.infinity,
        child: Center(
            child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("拖拽文件放置到这里", style: vm.textStyle2),
            Text('或者', style: vm.textStyle2.copyWith(fontSize: 17)),
            Text('浏览文件来选择', style: vm.textStyle2)
          ],
        )),
      ),
    );

    var choseWidget = FutureBuilder(
        future: vm.selectedFile?.detail(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Text('读取xFile错误');
          } else {
            if (snapshot.data == null) {
              return const SizedBox();
            }

            return Padding(
                padding: const EdgeInsets.all(15),
                child: Row(
                  children: [
                    Expanded(
                        flex: 8,
                        child: SingleChildScrollView(
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                              ...snapshot.data!
                                  .map((e) => Padding(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 2.0,
                                      ),
                                      child: Text(e, style: vm.textStyle1)))
                                  .toList()
                            ]))),
                    const SizedBox(width: 10),
                    Expanded(
                        flex: 1,
                        child: GestureDetector(
                            onTap: () => vm.clearFile(),
                            child: Tooltip(
                                message: '重新选择',
                                child: Card(
                                    backgroundColor: Colors.red.withOpacity(.5),
                                    child: const SizedBox(
                                        height: double.infinity,
                                        child: Icon(
                                          FluentIcons.cancel,
                                          size: 50,
                                          color: Colors.white,
                                        ))))))
                  ],
                ));
          }
        });

    var text = vm.selectedFile == null ? toChooseWidget : choseWidget;

    return m.Card(
      color: vm.dragging ? Colors.teal : Colors.teal.withOpacity(.2),
      child: SizedBox(
          width: double.infinity, height: 200, child: Center(child: text)),
    );
  }

  Widget _toolTip() {
    return expandedInfoBar('''支持单个apk文件的溯源，
如果是你本机通过安小助生成的apk产物，
并且上传到了OBS平台 或者 蒲公英平台，则会通过apk文件的MD5值找到该文次作业记录。
找到的记录可能是0条，1条，或者多条。''');
  }
}
