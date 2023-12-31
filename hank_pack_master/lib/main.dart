import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:desktop_window/desktop_window.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:hank_pack_master/ui/main_page.dart';

import 'comm/functions.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MainPage());

  if (isDesktop) {
    doWhenWindowReady(() {
      final win = appWindow;
      DesktopWindow.getWindowSize().then((size) {
        Size initialSize = Size(size.width * .9, size.height * .8);
        win.minSize = initialSize;
        win.size = initialSize;
        win.alignment = Alignment.center;
        win.title = "Custom window with Flutter";
        win.show();
      });
    });
  }
}


