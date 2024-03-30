import 'dart:io';

import 'package:desktop_drop/desktop_drop.dart';
import 'package:file_picker/file_picker.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/material.dart' as m;
import 'package:hank_pack_master/comm/dialog_util.dart';
import 'package:hank_pack_master/comm/gradients.dart';
import 'package:hank_pack_master/comm/hwobs/obs_client.dart';
import 'package:hank_pack_master/comm/text_util.dart';
import 'package:hank_pack_master/hive/fast_obs_upload/fast_obs_upload_operator.dart';
import 'package:hank_pack_master/ui/obs_fast_upload/vm/obs_fast_upload_vm.dart';
import 'package:jiffy/jiffy.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../comm/ui/info_bar.dart';

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
          _doUpload(vm);
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
      onTap: () async => _doFileChoose(vm),
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

  _toolTip() {
    return expandedInfoBar('''支持任意单个文件上传到OBS平台，前提是 OBS设置必须正确''');
  }

  void _doUpload(FastObsUploadVm vm) async {
    vm.showLoading();
    // 执行上传动作
    OBSResponse? oBSResponse = await OBSClient.putFile(
      objectName:
          "${OBSClient.commonUploadFolder}/fastUpload/${Jiffy.now().format(pattern: "yyyyMMdd_HHmmss")}/${Uri.encodeComponent(vm.selectedFile!.name)}",
      file: File(vm.selectedFile!.path),
      expiresDays: 1, // 设置过期时间(天)，超过了之后会被自动删除
    );

    vm.hideLoading();

    String? obsDownloadUrl = oBSResponse?.url;

    if (obsDownloadUrl == null || obsDownloadUrl.isEmpty) {
      showFailedDialog('${oBSResponse!.errMsg}', vm);
    } else {
      // 弹窗，显示上传结果的二维码
      showSuccessDialog(obsDownloadUrl, vm);
    }
  }

  void showFailedDialog(String errMsg, FastObsUploadVm vm) {
    DialogUtil.showCustomDialog(
        context: context,
        maxHeight: 550,
        title: '上传失败',
        showCancel: false,
        content: SingleChildScrollView(
          child: Column(
            children: [
              SelectableText(
                errMsg,
                style: vm.textStyle1.copyWith(fontSize: 18),
              )
            ],
          ),
        ));
  }

  void showSuccessDialog(String obsDownloadUrl, FastObsUploadVm vm) {
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
              style: vm.textStyle1.copyWith(fontSize: 18),
            ),
            SelectableText(obsDownloadUrl,
                style: vm.textStyle1.copyWith(
                    fontSize: 18, decoration: m.TextDecoration.underline)),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.center,
              child: qrCode,
            ),
          ],
        ));
  }

  void _doFileChoose(FastObsUploadVm vm) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['*'],
    );

    if (result != null) {
      var f = result.files.single;
      debugPrint('选择了 $f');
      if (!f.path.empty()) {
        vm.onFileSelected(f);
      }
    }
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
                  Expanded(
                      child: ListView.builder(
                          itemBuilder: (context, index) {
                            var cur = FastObsUploadOperator.findAll()[index];
                            return Text('${cur.fileName}');
                          },
                          itemCount: FastObsUploadOperator.findAll().length)),
                ],
              )),
        );
      },
    );
  }
}
