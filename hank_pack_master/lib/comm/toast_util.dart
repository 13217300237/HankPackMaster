import 'package:fluent_ui/fluent_ui.dart';
import 'package:hank_pack_master/comm/gradients.dart';
import 'package:oktoast/oktoast.dart';

class CustomToast extends StatelessWidget {
  final String message;

  final bool success;

  const CustomToast({
    Key? key,
    required this.message,
    this.success = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
      decoration: BoxDecoration(
        gradient: cardGradient,
        borderRadius: BorderRadius.circular(25.0),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            success ? FluentIcons.message : FluentIcons.warning,
            color: success ? Colors.green : Colors.red,
          ),
          const SizedBox(width: 10.0),
          Text(
            message,
            style: const TextStyle(
              fontSize: 20,
              color: Colors.black,
              fontWeight: FontWeight.w600,
              fontFamily: 'STKAITI'
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class ToastUtil {
  static void showPrettyToast(String msg, {bool success = true}) {
    showToastWidget(CustomToast(
      message: msg,
      success: success,
    ));
  }
}
