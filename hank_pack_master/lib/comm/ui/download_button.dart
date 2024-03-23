import 'package:fluent_ui/fluent_ui.dart';

class DownloadButtonController extends ChangeNotifier {
  DownloadState downloadState = DownloadState.idle;

  int progressValue = 0;

  startDownload() {
    downloadState = DownloadState.downloading;
    notifyListeners();
  }

  resetState() {
    downloadState = DownloadState.idle;
    notifyListeners();
  }

  void setProgressValue(int progress) {
    progressValue = progress;

    if (progressValue == 100) {
      downloadState = DownloadState.completed;
    }

    notifyListeners();
  }
}

class DownloadButton extends StatefulWidget {
  final Color mainColor;

  final DownloadButtonController downloadButtonController;

  final double btnWidth;

  final String fileName;

  const DownloadButton({
    super.key,
    required this.mainColor,
    required this.btnWidth,
    required this.downloadButtonController,
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
  late final double _btnWidth;

  double borderRadius = 6;

  /// 按钮状态
  DownloadState get _downloadState =>
      widget.downloadButtonController.downloadState;

  final TextStyle _textStyle = const TextStyle(
      color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600);

  /// 当前的下载进度
  int get _downloadProgressValue =>
      widget.downloadButtonController.progressValue;

  double get overlayWidth {
    if (_downloadState == DownloadState.downloading) {
      return _btnWidth * (_downloadProgressValue / 100);
    }
    return 0;
  }

  @override
  void initState() {
    super.initState();
    _btnWidth = widget.btnWidth;
    widget.downloadButtonController.addListener(() {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      _mainLayout(),
      _loadingLayout(),
    ]);
  }

  /// 主要布局
  Widget _mainLayout() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: Container(
        width: _btnWidth,
        height: 50,
        color: widget.mainColor.withOpacity(.7),
        child: _textActionButton(),
      ),
    );
  }

  /// loading遮罩层
  Widget _loadingLayout() {
    return Positioned(
        left: 0,
        top: 0,
        height: 50,
        width: overlayWidth,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(borderRadius),
          child: Container(
            color: Colors.white.withOpacity(.4),
          ),
        ));
  }

  /// 文字部分
  Widget _textActionButton() {
    Widget urlText() {
      return Text(widget.fileName, style: _textStyle);
    }

    Widget stateText() {
      Widget w;
      switch (_downloadState) {
        case DownloadState.idle:
          w = const SizedBox();
          break;
        case DownloadState.downloading:
          w = Text('$_downloadProgressValue%', style: _textStyle);
          break;
        case DownloadState.completed:
          w = Icon(
            FluentIcons.completed_solid,
            color: Colors.green.darkest,
          );
          break;
      }
      return w;
    }

    return Expanded(
        child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          urlText(),
          stateText(),
        ],
      ),
    ));
  }
}
