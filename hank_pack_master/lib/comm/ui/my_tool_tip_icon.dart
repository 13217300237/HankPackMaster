import 'package:fluent_ui/fluent_ui.dart';

Widget toolTipIcon({
  required String msg,
  required Color iconColor,
  double marginLeft = 10,
}) {
  return Tooltip(
    excludeFromSemantics:true,
    message: msg,
    child: Padding(
      padding: EdgeInsets.only(left: marginLeft),
      child: Icon(FluentIcons.alert_solid, color: iconColor),
    ),
  );
}
