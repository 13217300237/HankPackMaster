import 'package:fluent_ui/fluent_ui.dart';

import '../comm_font.dart';

class EnvErrWidget extends StatelessWidget {
  final List<String> errList;

  const EnvErrWidget({super.key, required this.errList});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ...errList.map((e) => Padding(
                padding: const EdgeInsets.all(10),
                child: Row(
                  children: [
                    Icon(FluentIcons.warning, color: Colors.red),
                    const SizedBox(width: 5),
                    Text(
                      e,
                      style: const TextStyle(
                          fontSize: 20,
                          fontFamily: commFontFamily,
                          fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ))
        ],
      ),
    );
  }
}
