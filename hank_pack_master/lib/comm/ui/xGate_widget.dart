import 'package:fluent_ui/fluent_ui.dart';
import 'package:hank_pack_master/ui/comm/vm/env_param_vm.dart';
import 'package:provider/provider.dart';

/// XGate状态监听
class XGateWidget extends StatefulWidget {
  const XGateWidget({super.key});

  @override
  State<XGateWidget> createState() => _XGateWidgetState();
}

class _XGateWidgetState extends State<XGateWidget> {
  @override
  void initState() {
    super.initState();
  }

  Widget xGateWidget() {
    EnvParamVm envParamVm = context.watch<EnvParamVm>();
    String t = envParamVm.xGateState ? "XGate已连接" : "XGate未连接";
    Color bg = envParamVm.xGateState ? Colors.green : Colors.red;

    String toolTipMsg = envParamVm.xGateState
        ? '支持从codeHub同步代码，但是不支持上传apk'
        : '支持上传apk但是不支持从codeHub同步代码';

    return Tooltip(
      message: toolTipMsg,
      child: Card(
        borderRadius: BorderRadius.circular(5),
        backgroundColor: bg,
        padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 8),
        child: Text(
          t,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return xGateWidget();
  }
}
