import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:file_picker/file_picker.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/material.dart' as m;
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:hank_pack_master/comm/datetime_util.dart';
import 'package:hank_pack_master/comm/dialog_util.dart';
import 'package:hank_pack_master/comm/pdf/pdf_util.dart';
import 'package:hank_pack_master/comm/selected_text_ext.dart';
import 'package:hank_pack_master/comm/text_util.dart';
import 'package:hank_pack_master/hive/env_config/env_config_operator.dart';
import 'package:hank_pack_master/hive/project_record/upload_platforms.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../comm/comm_font.dart';
import '../../comm/str_const.dart';
import '../../comm/ui/text_on_arc.dart';
import '../../hive/project_record/job_result_entity.dart';

/// 流水线最终成果展示卡片
class JobResultCard extends StatefulWidget {
  final JobResultEntity jobResult;
  final double maxHeight;
  final bool initiallyExpanded;
  final String? md5; // 文件上传后的md5值
  final String? projectName;

  const JobResultCard({
    super.key,
    required this.jobResult,
    required this.initiallyExpanded,
    required this.maxHeight,
    this.md5,
    this.projectName,
  });

  @override
  State<JobResultCard> createState() => _JobResultCardState();
}

class _JobResultCardState extends State<JobResultCard> {
  String get pdfFileName {
    return "${widget.projectName}_${DateTimeUtil.nowFormat2()}.pdf";
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.jobResult.errMessage.empty()) {
      // 这里有问题，上传失败时，这个errMessage是空的.
      return msgWidget();
    } else if (widget.jobResult.assembleOrders != null &&
        widget.jobResult.assembleOrders!.isNotEmpty) {
      return _assembleOrderWidget(widget.jobResult.assembleOrders);
    } else {
      bool hasExpired =
          widget.jobResult.expiredTime?.isBefore(DateTime.now()) ?? false;
      return Card(
        backgroundColor: Colors.blue.withOpacity(.1),
        borderRadius: BorderRadius.circular(10),
        margin: const EdgeInsets.symmetric(vertical: 10),
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        child: Stack(
          children: [
            _buildResWidget(widget.jobResult),
            Visibility(
              visible: hasExpired,
              child: Positioned(
                right: 40,
                top: 10,
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
      );
    }
  }

  Widget _buildResWidget(JobResultEntity jobResult) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Text('构建结果', style: _style.copyWith(fontSize: 28))),
            _line('App名称', "${jobResult.buildName}"),
            _line('App版本', "${jobResult.buildVersion}"),
            _line('编译版本', "${jobResult.buildVersionNo}"),
            _line('上传批次', "${jobResult.buildBuildVersion}"),
            _line('App包名', "${jobResult.buildIdentifier}"),
            _line('应用描述', "${jobResult.buildDescription}"),
            _line('更新日志', "${jobResult.buildUpdateDescription}"),
            _line('更新时间', "${jobResult.buildUpdated}"),
            _line('下载地址', "${jobResult.buildQRCodeURL}"),
            _line('过期时间', "${jobResult.expiredTime?.formatYYYMMDDHHmmSS()}"),
            _line('md5', '${widget.md5}'),
          ],
        ),
        Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            qrCode(),
            const SizedBox(height: 20),
            Row(children: [
              Tooltip(
                message: '打开默认浏览器预览PDF内容',
                child: FilledButton(
                    child: Text('预览PDF',
                        style: _style.copyWith(color: Colors.white)),
                    onPressed: () async {
                      String file =
                          "${EnvConfigOperator.searchEnvValue(Const.envWorkspaceRootKey)}${Platform.pathSeparator}temp${Platform.pathSeparator}$pdfFileName";
                      EasyLoading.show(status: "正在生成文件");

                      var f = File(file);
                      f.parent.createSync(recursive: true);

                      await PdfUtil.savePdf(
                        saveFile: File(file),
                        jobResult: jobResult,
                        md5: widget.md5!,
                      );
                      EasyLoading.dismiss();
                      try {
                        await launchUrl(Uri.parse(file)); // 通过资源管理器打开该目录
                      } catch (e) {
                        debugPrint("e->$e");
                        _showErr(file);
                      }
                    }),
              ),
              const SizedBox(width: 10),
              Tooltip(
                message: '保存PDF到本地磁盘',
                child: FilledButton(
                    child: Text('保存PDF',
                        style: _style.copyWith(color: Colors.white)),
                    onPressed: () async {
                      String? selectedDirectory =
                          await FilePicker.platform.getDirectoryPath();
                      if (selectedDirectory == null) {
                        return;
                      }

                      String file =
                          "$selectedDirectory${Platform.pathSeparator}$pdfFileName";
                      EasyLoading.show(status: "正在保存");
                      await PdfUtil.savePdf(
                        saveFile: File(file),
                        jobResult: jobResult,
                        md5: widget.md5!,
                      );
                      EasyLoading.dismiss();
                      showSaveRes(file);
                    }),
              ),
            ]),
          ],
        ),
      ],
    );
  }

  _showErr(pdfFilePath) {
    DialogUtil.showInfo(
        context: context,
        content: "预览 $pdfFilePath 失败",
        severity: InfoBarSeverity.error);
  }

  showSaveRes(String file) {
    DialogUtil.showBlurDialog(
        context: context,
        title: "保存成功",
        content: Row(
          children: [
            Expanded(
              child: m.SelectableText(
                file,
                style: _style.copyWith(color: Colors.blue),
              ).style1(),
            )
          ],
        ),
        maxHeight: 200,
        showCancel: false);
  }

  Widget msgWidget() {
    if (widget.jobResult.errMessage != null &&
        widget.jobResult.errMessage!.isNotEmpty) {
      List<String> listString = widget.jobResult.errMessage!.split("\n");
      var ex = ListView.builder(
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(right: 15.0),
            child: Text(
              listString[index],
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          );
        },
        itemCount: listString.length,
      );
      return Expander(
        initiallyExpanded: widget.initiallyExpanded,
        headerBackgroundColor:
            ButtonState.resolveWith((states) => Colors.red.withOpacity(.1)),
        header: Text('查看错误详情', style: _style),
        content: Container(
          constraints: const BoxConstraints(maxHeight: 350),
          child: ex,
        ),
      );
    }
    return const SizedBox(
      child: Text('错误详情'),
    );
  }

  Widget qrCode() {
    if (widget.jobResult.errMessage != null &&
        widget.jobResult.errMessage!.isNotEmpty) {
      return const SizedBox();
    } else if (widget.jobResult.buildQRCodeURL.empty()) {
      return const SizedBox();
    } else {
      if (widget.jobResult.uploadPlatform == '${UploadPlatform.pgy.index}') {
        return Center(
          child: CachedNetworkImage(
            width: qrCodeSize,
            height: qrCodeSize,
            imageUrl: "${widget.jobResult.buildQRCodeURL}",
            placeholder: (context, url) => const Center(
                child: m.CircularProgressIndicator(
              strokeWidth: 2,
            )),
            errorWidget: (context, url, error) =>
                const Icon(m.Icons.error_outline),
          ),
        );
      } else {
        return Center(
          child: Column(
            children: [
              QrImageView(
                data: '${widget.jobResult.buildQRCodeURL}',
                size: qrCodeSize,
                version: QrVersions.auto,
              ),
              const SizedBox(height: 5),
              OutlinedButton(
                onPressed: () {
                  launchUrl(Uri.parse(widget.jobResult.buildQRCodeURL!));
                },
                style: ButtonStyle(
                    backgroundColor:
                        ButtonState.resolveWith((states) => Colors.green),
                    foregroundColor:
                        ButtonState.resolveWith((states) => Colors.blue)),
                child: Tooltip(
                  message: '马上下载文件 ${widget.jobResult.buildQRCodeURL!}',
                  child: const Text(
                    '马上下载',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      }
    }
  }

  Widget _assembleOrderWidget(List<String>? assembleOrders) {
    if (assembleOrders == null || assembleOrders.isEmpty) {
      return const SizedBox();
    }

    return Expander(
      initiallyExpanded: widget.initiallyExpanded,
      headerBackgroundColor:
          ButtonState.resolveWith((states) => Colors.green.withOpacity(.1)),
      header: Text('可用变体', style: _style),
      content: SizedBox(
        height: widget.maxHeight - 229,
        child: SingleChildScrollView(
          child: Wrap(
            children: [
              ...assembleOrders
                  .map((e) => Card(
                        backgroundColor: Colors.green.withOpacity(.4),
                        margin: const EdgeInsets.symmetric(
                            vertical: 2, horizontal: 3),
                        child: Text(
                          e.replaceAll("assemble", ""),
                          style:
                              _style.copyWith(color: const Color(0xff24292E)),
                        ),
                      ))
                  .toList()
            ],
          ),
        ),
      ),
    );
  }

  Widget _line(String title, String value) {
    if (value.empty() || value == '[]' || value == 'null') {
      return const SizedBox();
    }

    return Padding(
      padding: const EdgeInsets.all(3.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 70, child: Text(title, style: _style)),
          Text(":", style: _style),
          const SizedBox(width: 5),
          SizedBox(
            width: 400,
            child: Text(
              value,
              style: _style.copyWith(color: const Color(0xff24292E)),
            ),
          ),
        ],
      ),
    );
  }

  final qrCodeSize = 160.0;

  final TextStyle _style = const TextStyle(
    fontSize: 16,
    color: Colors.black,
    fontWeight: FontWeight.w600,
    fontFamily: commFontFamily,
  );
}
