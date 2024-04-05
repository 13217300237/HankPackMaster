import 'dart:ui';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/material.dart' as m;
import 'package:hank_pack_master/comm/ui/xGate_widget.dart';

import '../comm_font.dart';

class BlurAlertDialog extends StatelessWidget {
  final String title;
  final dynamic content;
  final Function? onConfirm;
  final bool Function()? judgePop;
  final bool showCancel;
  final bool showActions;
  final String confirmText;
  final String cancelText;
  final double maxWidth;
  final double maxHeight;
  final bool showXGate;

  const BlurAlertDialog({
    Key? key,
    required this.title,
    required this.content,
    this.onConfirm,
    this.judgePop,
    this.showCancel = true,
    this.showActions = true,
    this.confirmText = "我知道了!",
    this.cancelText = "取消",
    this.maxWidth = 500,
    this.maxHeight = 700,
    this.showXGate = false,
  }) : super(key: key);

  final _titleStyle =  const TextStyle(
      fontSize: 23, fontFamily: commFontFamily, fontWeight: FontWeight.w600);

  @override
  Widget build(BuildContext context) {
    return m.Dialog(
      backgroundColor: m.Colors.transparent,
      elevation: 0,
      child: Container(
        constraints: BoxConstraints(maxWidth: maxWidth, maxHeight: maxHeight),
        child: Stack(
          children: <Widget>[
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
              child: Container(
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.all(Radius.circular(10)),
                    color: Colors.black.withOpacity(0.5),
                  ),
                  width: double.infinity,
                  height: double.infinity),
            ),
            Container(
              width: double.infinity,
              height: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(10)),
                color: Color(0xFFF6EFE9),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(title, style: _titleStyle),
                      showXGate ? const NetworkStateWidget() : const SizedBox(),
                    ],
                  ),
                  const SizedBox(height: 20),
                  if (content is String) Text(content) else content,
                  const Spacer(),
                  if (showActions)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if (showCancel)
                          Button(
                            onPressed: () => Navigator.of(context).pop(),
                            child: Text(cancelText),
                          ),
                        const SizedBox(width: 10),
                        Button(
                          style: ButtonStyle(backgroundColor:
                              ButtonState.resolveWith((states) {
                            return Colors.blue;
                          })),
                          onPressed: () {
                            if (judgePop == null || judgePop!()) {
                              Navigator.pop(context);
                            }
                            onConfirm?.call();
                          },
                          child: Text(confirmText,style: _titleStyle.copyWith(fontSize: 18,color: Colors.white),),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
