import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:desktop_window/desktop_window.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' as m;
import 'package:hank_pack_master/test/test_page.dart';

/// Checks if the current environment is a desktop environment.
bool get isDesktop {
  if (kIsWeb) return false;
  return [
    TargetPlatform.windows,
    TargetPlatform.linux,
    TargetPlatform.macOS,
  ].contains(defaultTargetPlatform);
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());

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

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  int topIndex = 0;
  PaneDisplayMode displayMode = PaneDisplayMode.auto;

  @override
  Widget build(BuildContext context) {
    return m.MaterialApp(
      localizationsDelegates: FluentLocalizations.localizationsDelegates,
      supportedLocales: FluentLocalizations.supportedLocales,
      debugShowCheckedModeBanner: false,
      home: m.Scaffold(
        body: WindowBorder(
          color: Colors.yellow,
          width: 1,
          child: FluentTheme(
            data: FluentThemeData(
              accentColor: Colors.red,
              visualDensity: VisualDensity.standard,
              focusTheme: FocusThemeData(
                glowFactor: is10footScreen(context) ? 2.0 : 0.0,
              ),
            ),
            child: NavigationView(
              appBar: NavigationAppBar(
                automaticallyImplyLeading: false,
                title: () {
                  return WindowTitleBarBox(child: MoveWindow());
                }(),
                actions:
                    Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                  Align(
                    alignment: AlignmentDirectional.centerEnd,
                    child: Padding(
                      padding: const EdgeInsetsDirectional.only(end: 8.0),
                      child: ToggleSwitch(
                        content: const Text('Dark Mode'),
                        checked: false,
                        onChanged: (v) {},
                      ),
                    ),
                  ),
                  if (!kIsWeb) const WindowButtons(),
                ]),
              ),
              pane: NavigationPane(
                selected: topIndex,
                onChanged: (index) => setState(() => topIndex = index),
                displayMode: displayMode,
                items: items,
                footerItems: [
                  PaneItem(
                    icon: const Icon(FluentIcons.settings),
                    title: const Text('Settings'),
                    body: const _NavigationBodyItem(),
                  ),
                  PaneItemAction(
                    icon: const Icon(FluentIcons.add),
                    title: const Text('Add New Item'),
                    onTap: () {
                      // Your Logic to Add New `NavigationPaneItem`
                      items.add(
                        PaneItem(
                          icon: const Icon(FluentIcons.new_folder),
                          title: const Text('New Item'),
                          body: const Center(
                            child: Text(
                              'This is a newly added Item',
                            ),
                          ),
                        ),
                      );
                      setState(() {});
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<NavigationPaneItem> items = [
    PaneItem(
      icon: const Icon(FluentIcons.home),
      title: const Text('Home'),
      body: const _NavigationBodyItem(),
    ),
    PaneItemSeparator(),
    PaneItem(
      icon: const Icon(FluentIcons.issue_tracking),
      title: const Text('Track orders'),
      infoBadge: const InfoBadge(source: Text('8')),
      body: const _NavigationBodyItem(
        header: 'Badging',
        content: Text(
          'Badging is a non-intrusive and intuitive way to display '
          'notifications or bring focus to an area within an app - '
          'whether that be for notifications, indicating new content, '
          'or showing an alert. An InfoBadge is a small piece of UI '
          'that can be added into an app and customized to display a '
          'number, icon, or a simple dot.',
        ),
      ),
    ),
    PaneItem(
      icon: const Icon(FluentIcons.disable_updates),
      title: const Text('Disabled Item'),
      body: const _NavigationBodyItem(),
      enabled: false,
    ),
    PaneItemExpander(
      icon: const Icon(FluentIcons.account_management),
      title: const Text('Account'),
      body: const _NavigationBodyItem(
        header: 'PaneItemExpander',
        content: Text(
          'Some apps may have a more complex hierarchical structure '
          'that requires more than just a flat list of navigation '
          'items. You may want to use top-level navigation items to '
          'display categories of pages, with children items displaying '
          'specific pages. It is also useful if you have hub-style '
          'pages that only link to other pages. For these kinds of '
          'cases, you should create a hierarchical NavigationView.',
        ),
      ),
      items: [
        PaneItemHeader(header: const Text('Apps')),
        PaneItem(
          icon: const Icon(FluentIcons.mail),
          title: const Text('Mail'),
          body: const _NavigationBodyItem(),
        ),
        PaneItem(
          icon: const Icon(FluentIcons.calendar),
          title: const Text('Calendar'),
          body: const _NavigationBodyItem(),
        ),
      ],
    ),
  ];
}

class _NavigationBodyItem extends StatelessWidget {
  const _NavigationBodyItem({
    this.header,
    this.content,
  });

  final String? header;
  final Widget? content;

  @override
  Widget build(BuildContext context) {
    return ScaffoldPage.withPadding(
      header: PageHeader(title: Text(header ?? 'This is a header text')),
      content: content ?? const SizedBox.shrink(),
    );
  }
}
