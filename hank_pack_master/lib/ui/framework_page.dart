import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:go_router/go_router.dart';
import 'package:hank_pack_master/comm/dialog_util.dart';
import 'package:hank_pack_master/ui/comm/theme.dart';
import 'package:hank_pack_master/ui/project_manager/dialog/fast_upload_list_dialog.dart';
import 'package:hank_pack_master/ui/work_shop/work_shop_vm.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';

import '../comm/ui/env_error_widget.dart';
import '../comm/ui/xGate_widget.dart';
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

  late EnvParamVm _envParamVm;

  late WorkShopVm _workShopVm;

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
      icon: const Icon(FluentIcons.a_t_p_logo),
      title: Text('作业工坊', style: w600TextStyle),
      body: const SizedBox.shrink(),
    ),
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
  }).toList();

  late final List<NavigationPaneItem> footerItems = [
    PaneItemSeparator(),
    PaneItem(
      key: const ValueKey('/cash_files'),
      icon: const Icon(FluentIcons.temporary_access_pass),
      title: Text('缓存文件管理', style: w600TextStyle),
      body: const SizedBox.shrink(),
      onTap: () {
        if (GoRouterState.of(context).uri.toString() != '/cash_files') {
          context.go('/cash_files');
        }
      },
    ),
    PaneItem(
      key: const ValueKey('/obs_fast_upload'),
      icon: const Icon(FluentIcons.upload),
      title: Text('OBS快传', style: w600TextStyle),
      body: const SizedBox.shrink(),
      onTap: () {
        if (GoRouterState.of(context).uri.toString() != '/obs_fast_upload') {
          context.go('/obs_fast_upload');
        }
      },
    ),
    PaneItem(
      key: const ValueKey('/trace'),
      icon: const Icon(FluentIcons.trackers),
      title: Text('应用包回溯', style: w600TextStyle),
      body: const SizedBox.shrink(),
      onTap: () {
        if (GoRouterState.of(context).uri.toString() != '/trace') {
          context.go('/trace');
        }
      },
    ),
  ];

  @override
  void initState() {
    windowManager.addListener(this);
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      // 弹出loading

      EasyLoading.show(
          status: '环境检测中...',
          dismissOnTap: false,
          maskType: EasyLoadingMaskType.black);

      _envParamVm.checkEnv().then((errList) {
        EasyLoading.dismiss();

        if (errList.isNotEmpty) {
          DialogUtil.showBlurDialog(
              context: context,
              title: '环境监测结果',
              content: EnvErrWidget(errList: errList),
              cancelText: '现在不要!',
              confirmText: '去环境设置模块看看',
              onConfirm: () {
                context.go('/env');
              });
        }
      });

      // 检查待上传任务
      showFastUploadDialogFunc() {
        DialogUtil.showCustomDialog(
            context: context,
            title: '待上传任务提示',
            content: '存在待上传任务，是否查看',
            confirmText: '去看看',
            onConfirm: () {
              DialogUtil.showCustomDialog(
                context: context,
                title: '待上传任务',
                maxWidth: 1200,
                content: FastUploadListDialog(
                  maxHeight: 700,
                  workShopVm: _workShopVm,
                ),
                showActions: false,
              );
            });
      }

      _envParamVm.startXGateListen(
          showFastUploadDialogFunc: showFastUploadDialogFunc);
    });
    super.initState();
  }

  @override
  void dispose() {
    windowManager.removeListener(this);
    searchController.dispose();
    searchFocusNode.dispose();
    _envParamVm.cancelXGateListen();
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
    _envParamVm = context.watch<EnvParamVm>();
    _workShopVm = context.watch<WorkShopVm>();
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
            "工作空间: ${_envParamVm.workSpaceRoot}",
            style: const TextStyle(fontSize: 25, fontWeight: FontWeight.w600),
          ))),
          const Align(
            alignment: AlignmentDirectional.centerStart,
            child: Padding(
              padding: EdgeInsetsDirectional.only(end: 8.0),
              child: NetworkStateWidget(),
            ),
          ),
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
        confirmText: '确定',
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
