import 'package:flutter/material.dart';

class DownloadButtonController extends ChangeNotifier {
  DownloadState _downloadState = DownloadState.idle;

  resetState() {
    _downloadState = DownloadState.idle;
    notifyListeners();
  }
}

class DownloadButton extends StatefulWidget {
  final Color mainColor;

  final DownloadButtonController controller;

  final double btnWidth;

  final String fileName;

  const DownloadButton({
    super.key,
    required this.mainColor,
    required this.btnWidth,
    required this.controller,
    required this.fileName,
  });

  @override
  State<StatefulWidget> createState() {
    return DownloadButtonState();
  }
}

enum DownloadState { idle, downloading, completed }

class DownloadButtonState extends State<DownloadButton>
    with TickerProviderStateMixin {
  /// 下载进度控制器
  late AnimationController _progressController;

  /// 缩放控制, 点击按钮时进行短暂缩放
  late AnimationController _scaleController;

  /// 下载完成之后 下载按钮的消失动画
  late AnimationController _fadeController;

  late Animation _scaleAnimation;
  late Animation _progressAnimation;
  late Animation _fadeAnimation;

  late final double _btnWidth;

  /// 遮罩层透明度
  double _barColorOpacity = .4;

  /// 按钮状态
  DownloadState _downloadState = DownloadState.idle;

  final TextStyle _textStyle =
      const TextStyle(color: Colors.white, fontSize: 18);

  /// 当前的下载进度
  int _downloadProgressValue = 0;

  @override
  void initState() {
    super.initState();

    widget.controller.addListener(() {
      if (widget.controller._downloadState == DownloadState.idle) {
        resetStatue();
      }
    });

    _btnWidth = widget.btnWidth;
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );

    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _fadeAnimation = Tween<double>(begin: 50, end: 0).animate(_fadeController)
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _scaleController.reverse();
          _fadeController.forward();
          _progressController.forward();
        }
      });

    _scaleAnimation =
        Tween<double>(begin: 1, end: 1.05).animate(_scaleController)
          ..addStatusListener((status) async {
            if (status == AnimationStatus.completed) {
              _scaleController.reverse();
              _fadeController.forward();

              _progressController.reset();
              _progressController.forward();
            }
          });

    _progressAnimation =
        Tween<double>(begin: 0, end: _btnWidth).animate(_progressController)
          ..addListener(() {
            setState(() {
              _downloadProgressValue =
                  ((100 * _progressAnimation.value / _btnWidth)).floor();
            });
          })
          ..addStatusListener((status) {
            if (status == AnimationStatus.forward) {
              setState(() {
                _downloadState = DownloadState.downloading;
                _barColorOpacity = 0.4;
              });
            } else if (status == AnimationStatus.completed) {
              setState(() {
                _downloadState = DownloadState.completed;
                _barColorOpacity = 0;
              });
            }
          });
  }

  @override
  void dispose() {
    super.dispose();
    _progressController.dispose();
    _scaleController.dispose();
    _fadeController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        debugPrint('当前状态是 $_downloadState');
        if (_downloadState == DownloadState.idle) {
          startDownload();
        } else if (_downloadState == DownloadState.completed) {
          resetStatue();
        } else {
          debugPrint('下载中，点了没用 $_downloadProgressValue');
        }
      },
      child: Stack(children: [
        _mainLayout(),
        _loadingLayout(),
      ]),
    );
  }

  void startDownload() {
    _scaleController.forward();
  }

  void resetStatue() {
    setState(() {
      _downloadState = DownloadState.idle;
    });
    _fadeController.reverse();
    _progressController.reset();
  }

  void setDownloading() {
    setState(() {
      _downloadState = DownloadState.downloading;
    });
  }

  /// 主要布局
  Widget _mainLayout() {
    return AnimatedBuilder(
        animation: _scaleController,
        builder: (BuildContext context, Widget? child) {
          return Transform.scale(
              scale: _scaleAnimation.value,
              child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                      width: _btnWidth,
                      height: 50,
                      color: widget.mainColor.withOpacity(.7),
                      child: Row(
                          children: [
                            _textActionButton(),
                            _downloadActionBtn()
                          ]))));
        });
  }

  /// loading遮罩层
  Widget _loadingLayout() {
    return AnimatedBuilder(
        animation: _progressController,
        builder: (BuildContext context, Widget? child) {
          return Positioned(
              left: 0,
              top: 0,
              height: 50,
              width: _progressAnimation.value,
              child: AnimatedOpacity(
                  opacity: _barColorOpacity,
                  duration: const Duration(milliseconds: 200),
                  child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Container(color: Colors.white))));
        });
  }

  /// 文字部分
  Widget _textActionButton() {
    Widget w;
    switch (_downloadState) {
      case DownloadState.idle:
        w = Text(widget.fileName, style: _textStyle,textAlign: TextAlign.left,);
        break;
      case DownloadState.downloading:
        w = Text('$_downloadProgressValue%', style: _textStyle);
        break;
      case DownloadState.completed:
        w = Text('已完成', style: _textStyle);
        break;
    }

    return Expanded(child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15.0),
      child: w,
    ));
  }

  /// 下载箭头按钮
  Widget _downloadActionBtn() {
    var decoration = const BorderRadius.only(
        topLeft: Radius.circular(0),
        bottomLeft: Radius.circular(0),
        topRight: Radius.circular(10),
        bottomRight: Radius.circular(10));

    return AnimatedBuilder(
        builder: (BuildContext context, Widget? child) {
          return Container(
              decoration: BoxDecoration(
                  color: widget.mainColor, borderRadius: decoration),
              width: _fadeAnimation.value,
              height: 50,
              child: const Icon(Icons.arrow_downward, color: Colors.white));
        },
        animation: _fadeController);
  }
}
