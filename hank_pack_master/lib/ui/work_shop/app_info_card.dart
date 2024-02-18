import 'package:cached_network_image/cached_network_image.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/material.dart' as m;
import 'package:hank_pack_master/comm/upload_platforms.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../comm/pgy/pgy_entity.dart';

/// 流水线最终成果展示卡片
class AppInfoCard extends StatelessWidget {
  final MyAppInfo appInfo;

  const AppInfoCard({super.key, required this.appInfo});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _line('App名称', "${appInfo.buildName}"),
          _line('App版本', "${appInfo.buildVersion}"),
          _line('编译版本', "${appInfo.buildVersionNo}"),
          _line('上传批次', "${appInfo.buildBuildVersion}"),
          _line('App包名', "${appInfo.buildIdentifier}"),
          _line('应用描述', "${appInfo.buildDescription}"),
          _line('更新日志', "${appInfo.buildUpdateDescription}"),
          _line('更新时间', "${appInfo.buildUpdated}"),
          if (appInfo.uploadPlatform == '${UploadPlatform.pgy.index}') ...[
            Center(
              child: Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: CachedNetworkImage(
                  width: 260,
                  height: 260,
                  imageUrl: "${appInfo.buildQRCodeURL}",
                  placeholder: (context, url) => const Center(
                      child: m.CircularProgressIndicator(
                    strokeWidth: 2,
                  )),
                  errorWidget: (context, url, error) =>
                      const Icon(m.Icons.error_outline),
                ),
              ),
            ),
          ] else ...[
            Center(
              child: QrImageView(
                data: '${appInfo.buildQRCodeURL}',
                size: 260,
                version: QrVersions.auto,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _line(String title, String value) {
    if (value.isEmpty || "null" == value.trim()) {
      return const SizedBox();
    }

    var fontSize = 15.0;

    return Padding(
      padding: const EdgeInsets.all(3.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
                fontSize: fontSize,
                color: Colors.black,
                fontWeight: FontWeight.w600),
          ),
          const SizedBox(width: 5),
          Text(":", style: TextStyle(fontSize: fontSize, color: Colors.black)),
          const SizedBox(width: 5),
          Flexible(
            child: Text(
              value,
              style: TextStyle(
                  fontSize: fontSize,
                  color: Colors.black,
                  fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
    );
  }
}
