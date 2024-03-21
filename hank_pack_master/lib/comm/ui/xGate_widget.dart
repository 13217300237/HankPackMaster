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
    String text = envParamVm.xGateState ? "XGate已连接" : "XGate未连接";
    Color bg = envParamVm.xGateState ? Colors.green : Colors.red;

    // 如果尝试连接内网成功，就说明此tag需要显示，否则不需要显示
    if(!envParamVm.needShowXGateTag){
      return const SizedBox();
    }

    return Card(
      borderRadius: BorderRadius.circular(5),
      backgroundColor: bg,
      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 8),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return xGateWidget();
  }
}
