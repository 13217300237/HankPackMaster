import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/material.dart' as m;
import 'package:flutter/material.dart';
import 'package:flutter_acrylic/flutter_acrylic.dart' as flutter_acrylic;
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:hank_pack_master/ui/env/env_param_vm.dart';
import 'package:hank_pack_master/ui/comm/theme.dart';
import 'package:hank_pack_master/ui/routes/route.dart';
import 'package:oktoast/oktoast.dart';
import 'package:provider/provider.dart';

final _appTheme = AppTheme();
final _envParamModel = EnvParamVm();
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
          brightness: Brightness.dark,
          accentColor: appTheme.accentColor,
          visualDensity: VisualDensity.standard,
          focusTheme: FocusThemeData(
            glowFactor: is10footScreen(context) ? 2.0 : 0.0,
          ),
          fontFamily: 'STKAITI'),
      // 白天模式主题
      theme: FluentThemeData(
          accentColor: appTheme.accentColor,
          visualDensity: VisualDensity.standard,
          focusTheme: FocusThemeData(
            glowFactor: is10footScreen(context) ? 2.0 : 0.0,
          ),
          fontFamily: 'STKAITI'),
      // 语言环境
      locale: appTheme.locale,
      // 子widget包装器
      builder: (context, child) {
        return Directionality(
          textDirection: appTheme.textDirection,
          child: NavigationPaneTheme(
            data: NavigationPaneThemeData(
              backgroundColor:
                  appTheme.windowEffect != flutter_acrylic.WindowEffect.disabled
                      ? m.Colors.grey
                      : null,
            ),
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
