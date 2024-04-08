import 'package:fluent_ui/fluent_ui.dart';
import 'package:hank_pack_master/comm/comm_font.dart';
import 'package:hank_pack_master/ui/comm/vm/env_param_vm.dart';
import 'package:provider/provider.dart';

/// XGate状态监听
class NetworkStateWidget extends StatefulWidget {
  const NetworkStateWidget({super.key});

  @override
  State<NetworkStateWidget> createState() => _NetworkStateWidgetState();
}

class _NetworkStateWidgetState extends State<NetworkStateWidget> {
  late EnvParamVm envParamVm;

  @override
  void initState() {
    super.initState();
  }

  Widget xGateWidget() {
    String text = envParamVm.xGateState ? "XGate已连接" : "XGate未连接";
    Color bg = envParamVm.xGateState ? Colors.green : Colors.red;

    // 如果尝试连接内网成功，就说明此tag需要显示，否则不需要显示
    if (!envParamVm.needShowXGateTag) {
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
            fontFamily: commFontFamily),
      ),
    );
  }

  Widget _netNameWidget() {
    if (envParamVm.networkName.isEmpty) {
      return const SizedBox();
    }
    return Card(
      borderRadius: BorderRadius.circular(5),
      backgroundColor: envParamVm.networkColor,
      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 8),
      child: Text(
        envParamVm.networkName,
        style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
            fontFamily: commFontFamily),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    envParamVm = context.watch<EnvParamVm>();

    return Row(
      children: [
        _netNameWidget(),
        const SizedBox(width: 10),
        xGateWidget(),
      ],
    );
  }
}
