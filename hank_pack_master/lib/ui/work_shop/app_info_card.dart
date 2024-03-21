import 'package:cached_network_image/cached_network_image.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/material.dart' as m;
import 'package:hank_pack_master/comm/text_util.dart';
import 'package:hank_pack_master/hive/project_record/upload_platforms.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../comm/pgy/pgy_entity.dart';

/// 流水线最终成果展示卡片
class AppInfoCard extends StatelessWidget {
  final MyAppInfo appInfo;
  final bool initiallyExpanded;

  const AppInfoCard(
      {super.key, required this.appInfo, required this.initiallyExpanded});

  @override
  Widget build(BuildContext context) {
    if (!appInfo.errMessage.empty()) {
      return msgWidget();
    } else {
      return Card(
        backgroundColor: Colors.blue.withOpacity(.1),
        borderRadius: BorderRadius.circular(10),
        margin: const EdgeInsets.symmetric(vertical: 10),
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
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
                _assembleOrderWidget("${appInfo.assembleOrders}"),
              ],
            ),
            qrCode(),
          ],
        ),
      );
    }
  }

  Widget msgWidget() {
    if (appInfo.errMessage != null && appInfo.errMessage!.isNotEmpty) {
      List<String> listString = appInfo.errMessage!.split("\n");
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
        initiallyExpanded: initiallyExpanded,
        headerBackgroundColor:
            ButtonState.resolveWith((states) => Colors.red.withOpacity(.1)),
        header: Text('查看错误详情', style: _style),
        content: SizedBox(
          height: 500,
          child: ex,
        ),
      );
    }
    return const SizedBox();
  }

  Widget qrCode() {
    if (appInfo.errMessage != null && appInfo.errMessage!.isNotEmpty) {
      return const SizedBox();
    } else if (appInfo.buildQRCodeURL.empty()) {
      return const SizedBox();
    } else {
      if (appInfo.uploadPlatform == '${UploadPlatform.pgy.index}') {
        return Center(
          child: CachedNetworkImage(
            width: qrCodeSize,
            height: qrCodeSize,
            imageUrl: "${appInfo.buildQRCodeURL}",
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
          child: QrImageView(
            data: '${appInfo.buildQRCodeURL}',
            size: qrCodeSize,
            version: QrVersions.auto,
          ),
        );
      }
    }
  }

  Widget _assembleOrderWidget(String assembleOrders) {
    if (assembleOrders == '[]') {
      return const SizedBox();
    }
    return Padding(
      padding: const EdgeInsets.all(3.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 70, child: Text("可用变体", style: _style)),
          Text(":", style: _style),
          const SizedBox(width: 5),
          Container(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Text(
              assembleOrders,
              style: _style.copyWith(color: const Color(0xff24292E)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _line(String title, String value) {
    if (value.empty() || value == '[]') {
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
    fontFamily: 'STKAITI',
  );
}
