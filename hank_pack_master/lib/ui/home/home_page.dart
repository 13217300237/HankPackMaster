import 'package:fluent_ui/fluent_ui.dart';
import 'package:provider/provider.dart';

import '../comm/theme.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    final appTheme = context.watch<AppTheme>();
    return Container(
      padding: const EdgeInsets.all(10),
      color: Colors.transparent,
      child: const Center(
          child: Text(
        "安卓小助手",
        style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
      )),
    );
  }
}
