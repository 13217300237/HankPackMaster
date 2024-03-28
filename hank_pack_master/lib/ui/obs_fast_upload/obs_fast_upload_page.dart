import 'dart:io';

import 'package:cross_file/cross_file.dart';
import 'package:desktop_drop/desktop_drop.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/material.dart' as m;
import 'package:hank_pack_master/comm/dialog_util.dart';
import 'package:hank_pack_master/comm/gradients.dart';
import 'package:hank_pack_master/comm/hwobs/obs_client.dart';
import 'package:hank_pack_master/comm/toast_util.dart';
import 'package:jiffy/jiffy.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../comm/ui/info_bar.dart';

/// 文件快传，选中一个文件，并且
class ObsFastUploadPage extends StatefulWidget {
  const ObsFastUploadPage({super.key});

  @override
  State<ObsFastUploadPage> createState() => _ObsFastUploadPageState();
}

class _ObsFastUploadPageState extends State<ObsFastUploadPage> {
  XFile? _selectedFile;

  bool _dragging = false;

  final _textStyle1 = const TextStyle(
      fontSize: 22, fontWeight: FontWeight.w600, fontFamily: 'STKAITI');

  final _textStyle2 = const TextStyle(
    fontSize: 30,
    fontWeight: FontWeight.w600,
    fontFamily: 'STKAITI',
  );

  @override
  Widget build(BuildContext context) {
    return DropTarget(
      onDragDone: (detail) {
        setState(() {
          if (detail.files.isEmpty) {
            ToastUtil.showPrettyToast('没有选择任何文件', success: false);
          } else if (detail.files.length > 1) {
            ToastUtil.showPrettyToast('仅支持选择单个文件', success: false);
          } else {
            _selectedFile = detail.files[0];
          }
        });
      },
      onDragEntered: (detail) {
        setState(() {
          _dragging = true;
        });
      },
      onDragExited: (detail) {
        setState(() {
          _dragging = false;
        });
      },
      child: Container(
          decoration: BoxDecoration(gradient: mainPanelGradient),
          padding: const EdgeInsets.all(15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('OBS文件直传',
                  style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'STKAITI')),
              const SizedBox(height: 12),
              _toolTip(),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    flex: 5,
                    child: fileSelectorWidget(),
                  ),
                  Expanded(
                    flex: 1,
                    child: actionBtnWidget(),
                  )
                ],
              )
            ],
          )),
    );
  }

  Color _btnColor = Colors.orange;

  Widget actionBtnWidget() {
    return MouseRegion(
      onExit: (e) {
        setState(() {
          _btnColor = Colors.orange;
        });
      },
      onEnter: (e) {
        setState(() {
          _btnColor = m.Colors.orange.shade400;
        });
      },
      child: GestureDetector(
        onTap: () async {
          if (_selectedFile == null) {
            return;
          }
          if (_uploading) {
            return;
          }
          _doUpload();
        },
        child: m.Card(
            color: _btnColor,
            child: Container(
              padding: const EdgeInsets.all(15),
              height: 200,
              child: Center(child: uploadBtnContent()),
            )),
      ),
    );
  }

  Widget uploadBtnContent() {
    if (_uploading) {
      return const ProgressRing();
    } else {
      return Text("开始上传", style: _textStyle2);
    }
  }

  // 每次仅仅支持一个文件
  Widget fileSelectorWidget() {
    var text = _selectedFile == null
        ? Center(child: Text("拖拽文件放置到这里", style: _textStyle2))
        : FutureBuilder(
            future: _selectedFile?.detail(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return const Text('读取xFile错误');
              } else {
                if (snapshot.data == null) {
                  return const SizedBox();
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ...snapshot.data!
                        .map((e) => Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 2.0),
                              child: Text(
                                e,
                                style: _textStyle1,
                              ),
                            ))
                        .toList(),
                  ],
                );
              }
            });

    return m.Card(
      color: _dragging ? Colors.teal : Colors.teal.withOpacity(.2),
      child: Container(
          padding: const EdgeInsets.all(15),
          width: double.infinity,
          height: 200,
          child: Center(child: text)),
    );
  }

  _toolTip() {
    return expandedInfoBar('支持任意单个文件上传到OBS平台，前提是 OBS设置必须正确');
  }

  bool _uploading = false;

  void _doUpload() async {
    setState(() {
      _uploading = true;
    });
    // 执行上传动作
    OBSResponse? oBSResponse = await OBSClient.putFile(
      objectName:
          "${OBSClient.commonUploadFolder}/fastUpload/${Jiffy.now().format(pattern: "yyyyMMdd_HHmmss")}/${_selectedFile!.name}",
      file: File(_selectedFile!.path),
    );

    setState(() {
      _uploading = false;
    });

    String? obsDownloadUrl = oBSResponse?.url;

    if (obsDownloadUrl == null || obsDownloadUrl.isEmpty) {
      showFailedDialog('${oBSResponse!.errMsg}');
    } else {
      // 弹窗，显示上传结果的二维码
      showSuccessDialog(obsDownloadUrl);
    }
  }

  void showFailedDialog(String errMsg) {
    DialogUtil.showCustomDialog(
        context: context,
        title: '上传失败',
        content: Column(
          children: [
            Text(
              errMsg,
              style: _textStyle1,
            )
          ],
        ));
  }

  void showSuccessDialog(String obsDownloadUrl) {
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
              style: _textStyle1.copyWith(fontSize: 18),
            ),
            SelectableText(obsDownloadUrl,style: _textStyle1.copyWith(fontSize: 18,decoration:m.TextDecoration.underline)),
            const SizedBox(height: 12),
            Align(alignment: Alignment.center,child: qrCode,),
          ],
        ));
  }
}

extension XFileExt on XFile {
  Future<List<String>> detail() async {
    List<String> res = [];

    res.add('文件路径： $path ');
    res.add('文件名：$name');
    res.add('文件大小：${(await length() / 1024 / 1024).toStringAsFixed(2)} MB');
    res.add(
        '最后修改时间：${Jiffy.parseFromDateTime(await lastModified()).format(pattern: 'yyyy-MM-dd HH:mm:ss')}');

    return res;
  }
}
