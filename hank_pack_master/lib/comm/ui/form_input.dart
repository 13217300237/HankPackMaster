import 'package:fluent_ui/fluent_ui.dart';
import 'package:hank_pack_master/comm/text_util.dart';
import 'package:hank_pack_master/comm/toast_util.dart';

import '../upload_platforms.dart';
import 'my_tool_tip_icon.dart';

/// 输入框
Widget input(
  String title,
  String placeholder,
  TextEditingController controller, {
  Widget? suffix,
  int maxLines = 1,
  int? maxLength,
  bool must = false,
  bool enable = true,
  String? toolTip,
  CrossAxisAlignment? crossAxisAlignment,
}) {
  Widget mustSpace;

  if (must) {
    mustSpace = SizedBox(
        width: 20,
        child: Center(
            child:
                Text('*', style: TextStyle(fontSize: 18, color: Colors.red))));
  } else {
    mustSpace = const SizedBox(width: 20);
  }

  var textStyle = const TextStyle(
      decoration: TextDecoration.none,
      fontSize: 15,
      height: 1.5,
      fontWeight: FontWeight.w600,
      fontFamily: 'STKAITI');

  return Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Row(
      crossAxisAlignment: crossAxisAlignment ?? CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Row(
            children: [
              Text(title,
                  style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'STKAITI')),
              mustSpace
            ],
          ),
        ),
        Expanded(
          child: TextBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
              ),
              unfocusedColor: Colors.transparent,
              highlightColor: Colors.transparent,
              style: textStyle,
              placeholder: placeholder,
              // 强制把placeHolder设置为-
              placeholderStyle: textStyle,
              expands: false,
              maxLines: maxLines,
              maxLength: maxLength,
              enabled: enable,
              controller: controller),
        ),
        if (suffix != null) ...[suffix],
        if (!toolTip.empty())
          toolTipIcon(msg: "$toolTip", iconColor: Colors.blue),
      ],
    ),
  );
}

Widget choose(String title, Map<String, String> orderList,
    {bool must = true,
    required Function(String) setSelectedOrder,
    required String? selected}) {
  Widget comboBox;

  Widget mustSpace;

  if (must) {
    mustSpace = SizedBox(
        width: 20,
        child: Center(
            child: Text('*',
                style: TextStyle(
                    fontSize: 18,
                    color: Colors.red,
                    fontWeight: FontWeight.w600))));
  } else {
    mustSpace = const SizedBox(width: 20);
  }

  comboBox = ComboBox<String>(
    value: selected,
    placeholder: const Text(
      '你必须选择一个打包命令',
      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
    ),
    items: orderList.entries
        .map((e) => ComboBoxItem(
            value: e.key,
            child: Text(e.key,
                style: const TextStyle(
                    fontWeight: FontWeight.w600, fontSize: 16))))
        .toList(),
    onChanged: (order) {
      if (order != null) {
        setSelectedOrder(order);
      } else {
        ToastUtil.showPrettyToast("你必须选择一个打包命令");
      }
    },
  );

  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 0),
    child: Row(children: [
      SizedBox(
        width: 100,
        child: Row(
          children: [
            Text(title,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            mustSpace
          ],
        ),
      ),
      comboBox,
      toolTipIcon(msg: "注意：如果选择的命令会打出多个apk包，会导致任务失败", iconColor: Colors.blue),
    ]),
  );
}

Widget chooseRadio(
  String title, {
  bool must = true,
  required UploadPlatform? selectedUploadPlatform,
  Function? setState,
}) {
  Widget mustSpace;

  if (must) {
    mustSpace = SizedBox(
        width: 20,
        child: Center(
            child:
                Text('*', style: TextStyle(fontSize: 18, color: Colors.red))));
  } else {
    mustSpace = const SizedBox(width: 20);
  }

  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 0),
    child: Row(children: [
      SizedBox(
          width: 100,
          child: Row(children: [
            Text(title, style: const TextStyle(fontSize: 18)),
            mustSpace
          ])),
      Expanded(
        child: Row(
          children: List.generate(uploadPlatforms.length, (index) {
            return Padding(
              padding: const EdgeInsets.only(right: 18.0),
              child: RadioButton(
                  checked: index == selectedUploadPlatform?.index,
                  content: Text(uploadPlatforms[index].name),
                  onChanged: (checked) {
                    selectedUploadPlatform = uploadPlatforms[index];
                    debugPrint(
                        "uploadPlatforms[index] = ${selectedUploadPlatform?.index}");
                    // setState?.call();
                  }),
            );
          }),
        ),
      )
    ]),
  );
}
