import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart' as m;
import 'package:hank_pack_master/comm/text_util.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart';
import 'package:printing/printing.dart';

import '../../hive/project_record/job_result_entity.dart';

class PdfUtil {
  static final TextStyle _style = TextStyle(
    fontSize: 16,
    color: PdfColors.black,
    fontWeight: FontWeight.bold,
  );

  /// 只能这样
  /// 将数据传进来，在这里构建布局
  static Future addBuildResWidget({
    required File saveFile,
    required JobResultEntity jobResult,
    required String md5,
  }) async {
    final ttf = await fontFromAssetBundle('fonts/STKAITI.TTF');
    final doc = Document();
    doc.addPage(Page(
        pageFormat: PdfPageFormat.a4,
        build: (context) => _buildResWidget(jobResult, md5, ttf))); //
    await saveFile.writeAsBytes(await doc.save());
    m.debugPrint("保存在：${saveFile.path}");
  }

  static Widget _buildResWidget(
      JobResultEntity jobResult, String md5, TtfFont ttfFont) {
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
                child: Text('构建结果',
                    style: _style.copyWith(fontSize: 28, font: ttfFont))),
            _line('App名称', "${jobResult.buildName}", ttfFont),
            _line('App版本', "${jobResult.buildVersion}", ttfFont),
            _line('编译版本', "${jobResult.buildVersionNo}", ttfFont),
            _line('上传批次', "${jobResult.buildBuildVersion}", ttfFont),
            _line('App包名', "${jobResult.buildIdentifier}", ttfFont),
            _line('应用描述', "${jobResult.buildDescription}", ttfFont),
            _line('更新日志', "${jobResult.buildUpdateDescription}", ttfFont),
            _line('更新时间', "${jobResult.buildUpdated}", ttfFont),
            _line('下载地址', "${jobResult.buildQRCodeURL}", ttfFont),
            _line('过期时间', "${jobResult.expiredTime?.formatYYYMMDDHHmmSS()}",
                ttfFont),
            _line('md5', md5, ttfFont),
          ],
        ),
        // qrCode(),
      ],
    );
  }

  static Widget _line(String title, String value, TtfFont ttfFont) {
    if (value.empty() || value == '[]' || value == 'null') {
      return SizedBox();
    }

    return Padding(
      padding: const EdgeInsets.all(3.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
              width: 70,
              child: Text(title, style: _style.copyWith(font: ttfFont))),
          Text(":", style: _style.copyWith(font: ttfFont)),
          SizedBox(width: 5),
          SizedBox(
            width: 400,
            child: Text(
              value,
              style: _style.copyWith(
                  color: PdfColor.fromHex('24292E'), font: ttfFont),
            ),
          ),
        ],
      ),
    );
  }
}
