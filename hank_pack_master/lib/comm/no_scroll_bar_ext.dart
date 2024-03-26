import 'package:fluent_ui/fluent_ui.dart';

extension ScrollConfigurationExtension on Widget {
  Widget hideScrollbar(BuildContext context) {
    return ScrollConfiguration(
      behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
      child: this,
    );
  }
}
