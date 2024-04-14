import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_acrylic/flutter_acrylic.dart';
import 'package:system_theme/system_theme.dart';

enum NavigationIndicators { sticky, end }

class AppTheme extends ChangeNotifier {
  AccentColor? _accentColor; // 主色调
  AccentColor get accentColor => _accentColor ?? systemAccentColor;

  set accentColor(AccentColor color) {
    _accentColor = color;
    notifyListeners();
  }

  Color? _bgColor; // 背景色
  Color get bgColor => _bgColor ?? const Color(0xffDDE1EA);

  set bgColor(Color color) {
    _bgColor = color;
    notifyListeners();
  }

  Color _bgColorErr = Colors.errorSecondaryColor.withOpacity(.9); // 背景色1
  Color get bgColorErr {
    return _bgColorErr;
  }

  Color _bgColorSucc = Colors.successPrimaryColor.withOpacity(.2); // 背景色2
  Color get bgColorSucc {
    return _bgColorSucc;
  }

  ThemeMode _mode = ThemeMode.light;

  ThemeMode get mode => _mode;

  set mode(ThemeMode mode) {
    _mode = mode;

    if (_mode == ThemeMode.light) {
      _bgColorErr = Colors.errorSecondaryColor.lightest;
      _bgColorSucc = Colors.successPrimaryColor.withOpacity(.2);
    } else {
      _bgColorErr = Colors.errorSecondaryColor.dark.withOpacity(.4);
      _bgColorSucc = Colors.successPrimaryColor.withOpacity(.2);
    }

    notifyListeners();
  }

  PaneDisplayMode _displayMode = PaneDisplayMode.open;

  PaneDisplayMode get displayMode => _displayMode;

  set displayMode(PaneDisplayMode displayMode) {
    _displayMode = displayMode;
    notifyListeners();
  }

  NavigationIndicators _indicator = NavigationIndicators.sticky;

  NavigationIndicators get indicator => _indicator;

  set indicator(NavigationIndicators indicator) {
    _indicator = indicator;
    notifyListeners();
  }

  WindowEffect _windowEffect = WindowEffect.disabled;

  WindowEffect get windowEffect => _windowEffect;

  set windowEffect(WindowEffect windowEffect) {
    _windowEffect = windowEffect;
    notifyListeners();
  }

  void setEffect(WindowEffect effect, BuildContext context) {
    Window.setEffect(
      effect: effect,
      color: [
        WindowEffect.solid,
        WindowEffect.acrylic,
      ].contains(effect)
          ? FluentTheme.of(context).micaBackgroundColor.withOpacity(0.05)
          : Colors.transparent,
      dark: FluentTheme.of(context).brightness.isDark,
    );
  }

  TextDirection _textDirection = TextDirection.ltr;

  TextDirection get textDirection => _textDirection;

  set textDirection(TextDirection direction) {
    _textDirection = direction;
    notifyListeners();
  }

  Locale? _locale;

  Locale? get locale => _locale;

  set locale(Locale? locale) {
    _locale = locale;
    notifyListeners();
  }
}

AccentColor get systemAccentColor {
  if ((defaultTargetPlatform == TargetPlatform.windows ||
          defaultTargetPlatform == TargetPlatform.android) &&
      !kIsWeb) {
    return AccentColor.swatch({
      'darkest': SystemTheme.accentColor.darkest,
      'darker': SystemTheme.accentColor.darker,
      'dark': SystemTheme.accentColor.dark,
      'normal': SystemTheme.accentColor.accent,
      'light': SystemTheme.accentColor.light,
      'lighter': SystemTheme.accentColor.lighter,
      'lightest': SystemTheme.accentColor.lightest,
    });
  }
  return Colors.green;
}
