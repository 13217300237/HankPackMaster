import 'package:fluent_ui/fluent_ui.dart';
import 'package:go_router/go_router.dart';
import 'package:hank_pack_master/comm/dialog_util.dart';
import 'package:hank_pack_master/ui/comm/theme.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';

import 'app.dart';
import 'comm/vm/env_param_vm.dart';

///
/// 主框架界面
///
class FrameworkPage extends StatefulWidget {
  const FrameworkPage(
    this.navigationShell, {
    super.key,
  });

  final StatefulNavigationShell navigationShell;

  @override
  State<FrameworkPage> createState() => _FrameworkPageState();
}

class _FrameworkPageState extends State<FrameworkPage> with WindowListener {
  bool value = false;

  final viewKey = GlobalKey(debugLabel: 'Navigation View Key');
  final searchKey = GlobalKey(debugLabel: 'Search Bar Key');
  final searchFocusNode = FocusNode();
  final searchController = TextEditingController();
  var w600TextStyle = const TextStyle(fontWeight: FontWeight.w600);

  late final List<NavigationPaneItem> originalItems = [
    PaneItem(
      key: const ValueKey('/'),
      icon: const Icon(FluentIcons.home),
      title: Text('首页', style: w600TextStyle),
      body: const SizedBox.shrink(),
    ),
    PaneItem(
      key: const ValueKey('/env'),
      icon: const Icon(FluentIcons.button_control),
      title: Text('环境参数', style: w600TextStyle),
      body: const SizedBox.shrink(),
    ),
    PaneItem(
      key: const ValueKey('/project_manager'),
      icon: const Icon(FluentIcons.a_a_d_logo),
      title: Text('工程管理', style: w600TextStyle),
      body: const SizedBox.shrink(),
    ),
    PaneItem(
      key: const ValueKey('/work_shop'),
      icon: const Icon(FluentIcons.a_a_d_logo),
      title: Text('打包工坊', style: w600TextStyle),
      body: const SizedBox.shrink(),
    ),
    // PaneItem( // TODO
    //   key: const ValueKey('/files'),
    //   icon: const Icon(FluentIcons.a_t_p_logo),
    //   title: Text('缓存文件迁移', style: w600TextStyle),
    //   body: const SizedBox.shrink(),
    // ),
    // PaneItem(
    //   key: const ValueKey('/trace'),
    //   icon: const Icon(FluentIcons.app_icon_secure),
    //   title: Text('应用包回溯', style: w600TextStyle),
    //   body: const SizedBox.shrink(),
    // ),
    // PaneItem(
    //   key: const ValueKey('/device'),
    //   icon: const Icon(FluentIcons.analytics_query),
    //   title: Text('设备相关', style: w600TextStyle),
    //   body: const SizedBox.shrink(),
    // ),
    // PaneItem(
    //   key: const ValueKey('/timer'),
    //   icon: const Icon(FluentIcons.timer),
    //   title: Text('定时任务', style: w600TextStyle),
    //   body: const SizedBox.shrink(),
    // ),
    // PaneItem(
    //   key: const ValueKey('/statistics'),
    //   icon: const Icon(FluentIcons.archive),
    //   title: Text('工作统计', style: w600TextStyle),
    //   body: const SizedBox.shrink(),
    // ),
    // PaneItem(
    //   key: const ValueKey('/information'),
    //   icon: const Icon(FluentIcons.info),
    //   title:  Text('技术资讯', style: w600TextStyle),
    //   body: const SizedBox.shrink(),
    // ),
  ].map<NavigationPaneItem>((e) {
    PaneItem buildPaneItem(PaneItem item) {
      return PaneItem(
        key: item.key,
        icon: item.icon,
        title: item.title,
        body: item.body,
        onTap: () {
          final path = (item.key as ValueKey).value;
          if (GoRouterState.of(context).uri.toString() != path) {
            context.go(path);
          }
          item.onTap?.call();
        },
      );
    }

    if (e is PaneItemExpander) {
      return PaneItemExpander(
        key: e.key,
        icon: e.icon,
        title: e.title,
        body: e.body,
        items: e.items.map((item) {
          if (item is PaneItem) return buildPaneItem(item);
          return item;
        }).toList(),
      );
    }
    return buildPaneItem(e);

    return e;
  }).toList();

  // TODO
  late final List<NavigationPaneItem> footerItems = [
    // PaneItemSeparator(),
    // PaneItem(
    //   key: const ValueKey('/settings'),
    //   icon: const Icon(FluentIcons.settings),
    //   title: const Text('Settings'),
    //   body: const SizedBox.shrink(),
    //   onTap: () {
    //     if (GoRouterState.of(context).uri.toString() != '/settings') {
    //       context.go('/settings');
    //     }
    //   },
    // ),
  ];

  @override
  void initState() {
    windowManager.addListener(this);
    super.initState();
  }

  @override
  void dispose() {
    windowManager.removeListener(this);
    searchController.dispose();
    searchFocusNode.dispose();
    super.dispose();
  }

  int _calculateSelectedIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    int indexOriginal = originalItems
        .where((item) => item.key != null)
        .toList()
        .indexWhere((item) => item.key == Key(location));

    if (indexOriginal == -1) {
      int indexFooter = footerItems
          .where((element) => element.key != null)
          .toList()
          .indexWhere((element) => element.key == Key(location));
      if (indexFooter == -1) {
        return 0;
      }
      return originalItems
              .where((element) => element.key != null)
              .toList()
              .length +
          indexFooter;
    } else {
      return indexOriginal;
    }
  }

  @override
  Widget build(BuildContext context) {
    final appTheme = context.watch<AppTheme>();
    final envParamModel = context.watch<EnvParamVm>();
    final fluentTheme = FluentTheme.of(context);
    return NavigationView(
      key: viewKey,
      appBar: NavigationAppBar(
        automaticallyImplyLeading: false,
        title: const DragToMoveArea(
          child: Align(
            alignment: AlignmentDirectional.centerStart,
            child: null,
          ),
        ),
        actions: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
          Expanded(
            child: Center(
              child: Text(
                "工作空间: ${envParamModel.workSpaceRoot}",
                style:
                    const TextStyle(fontSize: 25, fontWeight: FontWeight.w600),
              ),
            ),
          ),
          // TODO 模式切换再说吧
          // Align(
          //   alignment: AlignmentDirectional.centerEnd,
          //   child: Padding(
          //     padding: const EdgeInsetsDirectional.only(end: 8.0),
          //     child: ToggleSwitch(
          //       content: const Text('Dark Mode'),
          //       checked: fluentTheme.brightness.isDark,
          //       onChanged: (v) {
          //         if (v) {
          //           appTheme.mode = ThemeMode.dark;
          //         } else {
          //           appTheme.mode = ThemeMode.light;
          //         }
          //       },
          //     ),
          //   ),
          // ),
          const WindowButtons(),
        ]),
      ),
      paneBodyBuilder: (item, child) {
        final name =
            item?.key is ValueKey ? (item!.key as ValueKey).value : null;
        return FocusTraversalGroup(
          key: ValueKey('body$name'),
          child: widget.navigationShell,
        );
      },
      pane: NavigationPane(
        size: const NavigationPaneSize(
            openMaxWidth: 220,
            openWidth: 220,
            compactWidth: 100,
            openMinWidth: 200),
        selected: _calculateSelectedIndex(context),
        header: const SizedBox(
          height: kOneLineTileHeight,
          child: Text(
            appTitle,
            style: TextStyle(fontSize: 20),
          ),
        ),
        displayMode: appTheme.displayMode,
        indicator: () {
          switch (appTheme.indicator) {
            case NavigationIndicators.end:
              return const EndNavigationIndicator();
            case NavigationIndicators.sticky:
            default:
              return const StickyNavigationIndicator();
          }
        }(),
        items: originalItems,
        autoSuggestBox: Builder(builder: (context) {
          return AutoSuggestBox(
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            key: searchKey,
            focusNode: searchFocusNode,
            controller: searchController,
            unfocusedColor: Colors.transparent,
            // also need to include sub items from [PaneItemExpander] items
            items: <PaneItem>[
              ...originalItems
                  .whereType<PaneItemExpander>()
                  .expand<PaneItem>((item) {
                return [
                  item,
                  ...item.items.whereType<PaneItem>(),
                ];
              }),
              ...originalItems
                  .where(
                    (item) => item is PaneItem && item is! PaneItemExpander,
                  )
                  .cast<PaneItem>(),
            ].map((item) {
              assert(item.title is Text);
              final text = (item.title as Text).data!;
              return AutoSuggestBoxItem(
                label: text,
                value: text,
                onSelected: () {
                  item.onTap?.call();
                  searchController.clear();
                  searchFocusNode.unfocus();
                  final view = NavigationView.of(context);
                  if (view.compactOverlayOpen) {
                    view.compactOverlayOpen = false;
                  } else if (view.minimalPaneOpen) {
                    view.minimalPaneOpen = false;
                  }
                },
              );
            }).toList(),
            trailingIcon: IgnorePointer(
              child: IconButton(
                onPressed: () {},
                icon: const Icon(FluentIcons.search),
              ),
            ),
            placeholder: 'Search',
            placeholderStyle:
                const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
          );
        }),
        autoSuggestBoxReplacement: const Icon(FluentIcons.search),
        footerItems: footerItems,
      ),
      onOpenSearch: searchFocusNode.requestFocus,
    );
  }

  @override
  void onWindowClose() async {
    bool isPreventClose = await windowManager.isPreventClose();
    if (isPreventClose && mounted) {
      DialogUtil.showCustomDialog(
        context: context,
        onConfirm: () => windowManager.destroy(),
        title: "提示",
        content: "关闭应用吗？",
      );
    }
  }
}

class WindowButtons extends StatelessWidget {
  const WindowButtons({super.key});

  @override
  Widget build(BuildContext context) {
    final FluentThemeData theme = FluentTheme.of(context);

    return SizedBox(
      width: 138,
      height: 50,
      child: WindowCaption(
        brightness: theme.brightness,
        backgroundColor: Colors.transparent,
      ),
    );
  }
}
