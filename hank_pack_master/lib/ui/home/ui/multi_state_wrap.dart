import 'package:flutter/material.dart';

typedef SuccessLayoutBuilder = Widget Function(String data);

enum Status { initial, loading, error, success, timeout }

class TimeoutTag {}

class DataWrapper {
  bool isSuccess = false;
  String? data;

  DataWrapper({required this.isSuccess, required this.data});
}

class WrapperSize {
  double height;
  double width;

  WrapperSize({required this.height, required this.width});
}

/// 组件对外开放的状态控制器
class StateController extends ChangeNotifier {
  Status _currentState = Status.initial;

  DataWrapper? _dataWrapper;

  changeState(Status status, {DataWrapper? dataWrapper}) {
    _currentState = status;
    _dataWrapper = dataWrapper;
    notifyListeners();
  }
}

class MultipleStatusWidget extends StatefulWidget {
  final Future<DataWrapper> Function() asyncTask;

  final Duration overtimeDuration; // 超时时间

  final SuccessLayoutBuilder successLayoutBuilder;

  final Widget idleLayout;
  final Widget loadingLayout;
  final Widget errLayout;
  final Widget timeoutLayout;

  final bool needFadeInAnimation;

  final WrapperSize successSize;
  final WrapperSize loadingSize;

  final StateController stateController;

  const MultipleStatusWidget({
    super.key,
    required this.overtimeDuration,
    required this.successLayoutBuilder,
    required this.idleLayout,
    required this.loadingLayout,
    required this.errLayout,
    required this.timeoutLayout,
    required this.asyncTask,
    required this.stateController,
    required this.successSize,
    required this.loadingSize,
    this.needFadeInAnimation = false,
  });

  @override
  State<StatefulWidget> createState() {
    return MultipleStatusWidgetState();
  }
}

class MultipleStatusWidgetState extends State<MultipleStatusWidget>
    with TickerProviderStateMixin {
  /// 组件状态
  Status _currentStatus = Status.initial;

  /// 超时的计时器
  late Future<TimeoutTag> Function() timeoutTask;

  String? _data;

  late AnimationController _controller;

  late Animation fadeInAnimation;
  late Animation heightChangeAnimation;
  late Animation widthChangeAnimation;

  @override
  void initState() {
    super.initState();

    widget.stateController.addListener(() {
      _data = widget.stateController._dataWrapper?.data;
      _changeState(widget.stateController._currentState);
    });

    _initWidget();
    _initData();
  }

  _initWidget() {
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 300));
    fadeInAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(_controller);

    heightChangeAnimation = Tween<double>(
            begin: widget.loadingSize.height, end: widget.successSize.height)
        .animate(_controller);
    widthChangeAnimation = Tween<double>(
            begin: widget.loadingSize.width, end: widget.successSize.width)
        .animate(_controller);
  }

  _initData() {
    _changeState(Status.loading);
    timeoutTask = () async {
      await Future.delayed(widget.overtimeDuration);
      return TimeoutTag();
    };

    _loadData();
  }

  void _loadData() {
    _changeState(Status.loading);
    Future.any([timeoutTask(), widget.asyncTask()]).then((value) {
      if (value is TimeoutTag) {
        _changeState(Status.timeout);
      } else {
        var dataWrapper = value as DataWrapper;
        _data = dataWrapper.data;
        _changeState(Status.success);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return _buildMainLayout(_currentStatus);
  }

  Widget _buildMainLayout(Status status) {
    Widget w;
    switch (status) {
      case Status.initial:
        w = widget.idleLayout;
        break;
      case Status.loading:
        w = widget.loadingLayout;
        break;
      case Status.error:
        w = GestureDetector(onTap: _loadData, child: widget.errLayout);
        break;
      case Status.timeout:
        w = GestureDetector(onTap: _loadData, child: widget.timeoutLayout);
        break;
      case Status.success:
        w = widget.successLayoutBuilder(_data!);
        break;
    }

    return AnimatedBuilder(
        animation: fadeInAnimation,
        builder: (_, __) {
          return Opacity(
              opacity: widget.needFadeInAnimation ? fadeInAnimation.value : 1,
              child: SizedBox(
                height: heightChangeAnimation.value,
                width: widthChangeAnimation.value,
                child: w,
              ));
        });
  }

  void _changeState(Status newStatus) {
    if (_currentStatus != newStatus) {
      // 确定上一个状态到下一个状态的高度变化
      double beginHeight;
      double endHeight;

      double beginWidth;
      double endWidth;

      if (_currentStatus != Status.success && newStatus == Status.success) {
        // 从非success到success
        beginHeight = widget.loadingSize.height;
        endHeight = widget.successSize.width;

        beginWidth = widget.loadingSize.width;
        endWidth = widget.successSize.width;
      } else if (_currentStatus == Status.success &&
          newStatus != Status.success) {
        // 非success到非success
        beginHeight = widget.successSize.height;
        endHeight = widget.loadingSize.height;

        beginWidth = widget.successSize.width;
        endWidth = widget.loadingSize.width;
      } else {
        // 从非success到非success
        beginHeight = widget.loadingSize.height;
        endHeight = widget.loadingSize.height;

        beginWidth = widget.loadingSize.width;
        endWidth = widget.loadingSize.width;
      }
      _currentStatus = newStatus;
      setState(() {});

      heightChangeAnimation = Tween<double>(begin: beginHeight, end: endHeight)
          .animate(_controller);
      widthChangeAnimation =
          Tween<double>(begin: beginWidth, end: endWidth).animate(_controller);

      _controller.reset();
      _controller.forward();
    }
  }
}
