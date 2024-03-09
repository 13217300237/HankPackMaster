import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/material.dart' as m;
import 'package:flutter_acrylic/flutter_acrylic.dart' as flutter_acrylic;
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:hank_pack_master/ui/comm/vm/env_param_vm.dart';
import 'package:hank_pack_master/ui/comm/theme.dart';
import 'package:hank_pack_master/ui/work_shop/work_shop_vm.dart';
import 'package:oktoast/oktoast.dart';
import 'package:provider/provider.dart';

import '../routes/route.dart';

/// 概念
/// project：一个gitUrl+一个branchName组合成为一个Project，确定唯一一个工程
/// task: 一个project可以执行多个task，一个task有两个大阶段（工程预检阶段 | 工程打包阶段）
/// stage: 每一个task的两个大阶段都可以分为多个小阶段，每一个小阶段有独立的准入和准出

final _appTheme = AppTheme();
final _envParamModel = EnvParamVm();
final _workShopVm = WorkShopVm();
const String appTitle = '安小助';

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (context) => _appTheme),
          ChangeNotifierProvider(create: (context) => _envParamModel),
          ChangeNotifierProvider(create: (context) => _workShopVm),
        ],
        builder: (context, child) {
          return FluentApp(
            // 是否显示debug标记
            localizationsDelegates: FluentLocalizations.localizationsDelegates,
            debugShowCheckedModeBanner: false,
            title: 'Flutter EasyLoading',
            home: OKToast(child: fluentUi(context)),
            builder: EasyLoading.init(),
          );
        });
  }

  var tooltipTheme = const TooltipThemeData(
      waitDuration: Duration(milliseconds: 200),
      textStyle: TextStyle(
          fontSize: 16, fontWeight: FontWeight.w600, fontFamily: 'STKAITI'));

  Widget fluentUi(BuildContext context) {
    var appTheme = context.watch<AppTheme>();
    return FluentApp.router(
      // 白天黑夜模式
      themeMode: appTheme.mode,
      // 是否显示debug标记
      debugShowCheckedModeBanner: false,
      // 主色调
      color: appTheme.accentColor,
      // 黑暗模式主题
      darkTheme: FluentThemeData(
          tooltipTheme: tooltipTheme,
          brightness: Brightness.dark,
          accentColor: appTheme.accentColor,
          visualDensity: VisualDensity.standard,
          focusTheme:
              FocusThemeData(glowFactor: is10footScreen(context) ? 2.0 : 0.0),
          fontFamily: 'STKAITI'),
      // 白天模式主题
      theme: FluentThemeData(
          tooltipTheme: tooltipTheme,
          scrollbarTheme: const ScrollbarThemeData(),
          accentColor: appTheme.accentColor,
          visualDensity: VisualDensity.standard,
          focusTheme:
              FocusThemeData(glowFactor: is10footScreen(context) ? 2.0 : 0.0),
          fontFamily: 'STKAITI'),
      // 语言环境
      locale: appTheme.locale,
      // 子widget包装器
      builder: (context, child) {
        return Directionality(
          textDirection: appTheme.textDirection,
          child: NavigationPaneTheme(
            data: const NavigationPaneThemeData(
                backgroundColor: Color(0xFFF6EFE9)),
            child: child!,
          ),
        );
      },
      routeInformationParser: statefulRouter.routeInformationParser,
      routerDelegate: statefulRouter.routerDelegate,
      routeInformationProvider: statefulRouter.routeInformationProvider,
    );
  }
}
