import 'package:fluent_ui/fluent_ui.dart';

class EnvPage extends StatefulWidget {
  const EnvPage({super.key});

  @override
  State<EnvPage> createState() => _EnvPageState();
}

class _EnvPageState extends State<EnvPage> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Button(
            onPressed: () => debugPrint('pressed button'),
            child: const Text('Standard Button'),
          ),
        ],
      ),
    );
  }
}
