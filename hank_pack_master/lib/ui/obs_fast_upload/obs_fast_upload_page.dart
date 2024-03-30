import 'package:desktop_drop/desktop_drop.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/material.dart' as m;
import 'package:hank_pack_master/comm/dialog_util.dart';
import 'package:hank_pack_master/comm/gradients.dart';
import 'package:hank_pack_master/comm/text_util.dart';
import 'package:hank_pack_master/hive/fast_obs_upload/fast_obs_upload_operator.dart';
import 'package:hank_pack_master/ui/obs_fast_upload/vm/obs_fast_upload_vm.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../comm/ui/info_bar.dart';
import '../../comm/ui/text_on_arc.dart';

/// 文件快传，选中一个文件，并且
class ObsFastUploadPage extends StatefulWidget {
  const ObsFastUploadPage({super.key});

  @override
  State<ObsFastUploadPage> createState() => _ObsFastUploadPageState();
}

class _ObsFastUploadPageState extends State<ObsFastUploadPage> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      child: _mainBox(),
      create: (BuildContext context) => FastObsUploadVm(),
    );
  }

  Widget _mainBox() {
    return Consumer<FastObsUploadVm>(
      builder: (context, vm, child) {
        return DropTarget(
          onDragDone: vm.onDragDone,
          onDragEntered: vm.onDragEntered,
          onDragExited: vm.onDragExited,
          child: Container(
              decoration: BoxDecoration(gradient: mainPanelGradient),
              padding: const EdgeInsets.all(15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('OBS文件直传', style: vm.textStyle2),
                  const SizedBox(height: 12),
                  _toolTip(),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(flex: 5, child: fileSelectorWidget(vm)),
                      Expanded(flex: 1, child: actionBtnWidget(vm))
                    ],
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.only(top: 12.0, bottom: 12, right: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('上传历史', style: vm.textStyle2),
                        Text('总数 ${FastObsUploadOperator.findAll().length}',
                            style: vm.textStyle2.copyWith(fontSize: 18)),
                      ],
                    ),
                  ),
                  Expanded(
                      child: ListView.builder(
                          itemBuilder: (context, index) {
                            var cur = FastObsUploadOperator.findAll()
                                .reversed
                                .toList()[index];
                            bool hasExpired =
                                cur.expiredTime.isBefore(DateTime.now());

                            return Card(
                                padding: const EdgeInsets.all(8),
                                backgroundColor: !hasExpired
                                    ? Colors.green.withOpacity(.4)
                                    : Colors.grey.withOpacity(.4),
                                borderRadius: const BorderRadius.all(
                                    Radius.circular(10.0)),
                                margin:
                                    const EdgeInsets.only(bottom: 5, right: 20),
                                child: Expander(
                                  initiallyExpanded: false,
                                  header: Text(cur.filePath,
                                      style: style.copyWith(fontSize: 20)),
                                  content: Stack(
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  hisCardText('文件大小',
                                                      ' ${cur.fileSize.toMb()}'),
                                                  hisCardText(
                                                      '最后修改时间',
                                                      cur.fileLastModify
                                                          .formatYYYMMDDHHmmSS()),
                                                  hisCardText(
                                                      '上传时间',
                                                      cur.uploadTime
                                                          .formatYYYMMDDHHmmSS()),
                                                  hisCardText('有效天数',
                                                      '${cur.expiredDays}'),
                                                  hisCardText(
                                                      '下载地址', cur.downloadUrl),
                                                  hisCardText(
                                                      '过期时间',
                                                      cur.expiredTime
                                                          .formatYYYMMDDHHmmSS()),
                                                ]),
                                          ),
                                          QrImageView(
                                            data: cur.downloadUrl,
                                            size: 160,
                                            version: QrVersions.auto,
                                          )
                                        ],
                                      ),
                                      Visibility(
                                        visible: true,
                                        child: Positioned(
                                          right: 120,
                                          top: 0,
                                          child: TextOnArcWidget(
                                            arcStyle: ArcStyle(
                                                text: '文件已过期',
                                                strokeWidth: 4,
                                                radius: 80,
                                                textSize: 20,
                                                sweepDegrees: 190,
                                                textColor: Colors.red,
                                                arcColor: Colors.red,
                                                padding: 18),
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                ));
                          },
                          itemCount: FastObsUploadOperator.findAll().length)),
                ],
              )),
        );
      },
    );
  }

  var style = const TextStyle(
    fontSize: 16,
    fontWeight: m.FontWeight.w600,
    fontFamily: 'STKAITI',
  );

  Widget hisCardText(String title, String content) {
    return Padding(
        padding: const EdgeInsets.all(4.0),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text("$title:", style: style),
          const SizedBox(width: 10),
          Expanded(
            child: TextSelectionTheme(
              data: TextSelectionThemeData(
                selectionColor: Colors.green.withOpacity(.3),
                // 修改选中文本的背景颜色
                selectionHandleColor: Colors.red, // 修改选中文本的选择手柄颜色
              ),
              child: SelectableText(
                content,
                style: style.copyWith(fontWeight: FontWeight.w900),
              ),
            ),
          )
        ]));
  }

  Widget actionBtnWidget(FastObsUploadVm vm) {
    return MouseRegion(
      onExit: (e) => vm.onMouseExit(),
      onEnter: (e) => vm.onMouseEnter(),
      child: GestureDetector(
        onTap: () async {
          if (vm.selectedFile == null) {
            return;
          }
          if (vm.uploading) {
            return;
          }
          vm.doUpload(
            showFailedDialog: showFailedDialog,
            showSuccessDialog: showSuccessDialog,
          );
        },
        child: m.Card(
            color: vm.btnColor,
            child: Container(
              padding: const EdgeInsets.all(15),
              height: 200,
              child: Center(child: uploadBtnContent(vm)),
            )),
      ),
    );
  }

  Widget uploadBtnContent(FastObsUploadVm vm) {
    if (vm.uploading) {
      return const ProgressRing();
    } else {
      return Text("开始上传", style: vm.textStyle2);
    }
  }

  // 每次仅仅支持一个文件
  Widget fileSelectorWidget(FastObsUploadVm vm) {
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
                                            vertical: 2.0),
                                        child: Text(
                                          e,
                                          style: vm.textStyle1,
                                        ),
                                      ))
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
    return expandedInfoBar('''支持任意单个文件上传到OBS平台，前提是 OBS设置必须正确''');
  }

  void showFailedDialog(String errMsg, TextStyle textStyle) {
    DialogUtil.showCustomDialog(
        context: context,
        maxHeight: 550,
        title: '上传失败',
        showCancel: false,
        content: SingleChildScrollView(
          child: Column(children: [
            SelectableText(errMsg, style: textStyle.copyWith(fontSize: 18))
          ]),
        ));
  }

  void showSuccessDialog(String obsDownloadUrl, TextStyle textStyle) {
    var qrCode = QrImageView(
      data: obsDownloadUrl,
      size: 260,
      version: QrVersions.auto,
    );
    DialogUtil.showCustomDialog(
        maxHeight: 550,
        context: context,
        title: '上传成功',
        showCancel: false,
        showXGate: true,
        content: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '下载地址(可拷贝)：',
              style: textStyle.copyWith(fontSize: 18),
            ),
            SelectableText(obsDownloadUrl,
                style: textStyle.copyWith(
                    fontSize: 18, decoration: m.TextDecoration.underline)),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.center,
              child: qrCode,
            ),
          ],
        ));
  }
}
