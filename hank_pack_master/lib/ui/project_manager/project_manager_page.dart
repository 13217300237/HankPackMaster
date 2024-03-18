import 'package:badges/badges.dart' as badges;
import 'package:fluent_ui/fluent_ui.dart';
import 'package:go_router/go_router.dart';
import 'package:hank_pack_master/comm/dialog_util.dart';
import 'package:hank_pack_master/comm/toast_util.dart';
import 'package:hank_pack_master/hive/project_record/project_record_operator.dart';
import 'package:hank_pack_master/ui/project_manager/dialog/active_dialog.dart';
import 'package:hank_pack_master/ui/project_manager/dialog/start_package_dialog.dart';
import 'package:hank_pack_master/ui/work_shop/work_shop_vm.dart';
import 'package:jiffy/jiffy.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_core/theme.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

import '../../comm/gradients.dart';
import '../../comm/pgy/pgy_entity.dart';
import '../../comm/url_check_util.dart';
import '../../hive/project_record/job_history_entity.dart';
import '../../hive/project_record/project_record_entity.dart';
import '../comm/theme.dart';
import '../comm/vm/env_param_vm.dart';
import '../work_shop/app_info_card.dart';
import 'column_name_const.dart';
import 'dialog/create_project_record_dialog.dart';
import 'dialog/fast_upload_dialog.dart';
import 'grid_datasource.dart';
import 'job_setting_card.dart';

class ProjectManagerPage extends StatefulWidget {
  const ProjectManagerPage({super.key});

  @override
  State<ProjectManagerPage> createState() => _ProjectManagerPageState();
}

const minimumWidth = 200.0;

class _ProjectManagerPageState extends State<ProjectManagerPage> {
  late ProjectEntityDataSource _dataSource;
  int _rowsPerPage = 10;

  double projectNameColumnWidth = 150;
  double gitUrlColumnWidth = 300;
  double branchColumnWidth = minimumWidth;
  double statueColumnWidth = minimumWidth;
  double assembleOrdersWidth = 250;
  double jobOperationWidth = minimumWidth;

  late WorkShopVm _workShopVm;
  late EnvParamVm _envParamVm;
  late AppTheme _appTheme;

  int get unreadHisCount {
    var unreadHisList = ProjectRecordOperator.findAllUnreadJobHistoryEntity();
    return unreadHisList.length;
  }

  @override
  Widget build(BuildContext context) {
    _envParamVm = context.watch<EnvParamVm>();
    _workShopVm = context.watch<WorkShopVm>();
    _appTheme = context.watch<AppTheme>();

    var grid = Expanded(
      child: Container(
        decoration: BoxDecoration(
            color: Colors.white.withOpacity(.6),
            border: Border.all(color: Colors.teal, width: .2),
            borderRadius: const BorderRadius.all(Radius.circular(3)),
            gradient: cardGradient),
        margin: const EdgeInsets.all(15),
        child: SfDataGrid(
          columnWidthMode: ColumnWidthMode.fill,
          allowColumnsResizing: true,
          columnResizeMode: ColumnResizeMode.onResize,
          onColumnResizeUpdate: (ColumnResizeUpdateDetails args) {
            setState(() {
              switch (args.column.columnName) {
                case ColumnNameConst.gitUrl:
                  gitUrlColumnWidth = args.width;
                  break;
                case ColumnNameConst.projectName:
                  projectNameColumnWidth = args.width;
                  break;
                case ColumnNameConst.branch:
                  branchColumnWidth = args.width;
                  break;
                case ColumnNameConst.statue:
                  statueColumnWidth = args.width;
                  break;
                case ColumnNameConst.assembleOrders:
                  assembleOrdersWidth = args.width;
                  break;
                case ColumnNameConst.jobOperation:
                  jobOperationWidth = args.width;
                  break;
              }
            });
            return true;
          },
          gridLinesVisibility: GridLinesVisibility.none,
          headerGridLinesVisibility: GridLinesVisibility.none,
          rowsPerPage: _rowsPerPage,
          source: _dataSource,
          columns: _getGridHeader,
        ),
      ),
    );

    var size = _dataSource.dataList.length;
    // 矫正size，以计算页数
    if (size == 0) {
      size = 1;
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 5),
      decoration: BoxDecoration(gradient: mainPanelGradient),
      child: Column(children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15.0),
                child: CommandBar(
                    overflowBehavior: CommandBarOverflowBehavior.noWrap,
                    primaryItems: [...simpleCommandBarItems])),
            Padding(
              padding: const EdgeInsets.only(right: 15.0),
              child: Card(
                borderRadius: BorderRadius.circular(10),
                padding:
                    const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                backgroundColor: Colors.teal,
                child: GestureDetector(
                  onTap: () {
                    DialogUtil.showCustomDialog(
                            context: context,
                            title: "最近作业历史",
                            maxWidth: 850,
                            content:
                                ListView(children: [...getRecentJobResult()]),
                            showCancel: false,
                            confirmText: '我知道了！')
                        .then((value) {
                      setState(() {});
                      _dataSource.notifyListeners();
                    });
                  },
                  child: Row(
                    children: [
                      const Text('最近作业历史',
                          style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 20,
                              color: Colors.white)),
                      Visibility(
                        visible: unreadHisCount > 0,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 10.0),
                          child: badges.Badge(
                            ignorePointer: false,
                            badgeContent: Text('$unreadHisCount',
                                style: const TextStyle(color: Colors.white)),
                            badgeStyle: badges.BadgeStyle(
                              shape: badges.BadgeShape.square,
                              badgeColor: Colors.red,
                              padding: const EdgeInsets.all(5),
                              borderRadius: BorderRadius.circular(4),
                              borderSide: const BorderSide(
                                  color: Colors.black, width: 1),
                              elevation: 0,
                            ),
                            badgeAnimation: const badges.BadgeAnimation.fade(
                              animationDuration: Duration(seconds: 1),
                              colorChangeAnimationDuration:
                                  Duration(seconds: 1),
                              loopAnimation: false,
                              curve: Curves.fastOutSlowIn,
                              colorChangeAnimationCurve: Curves.easeInCubic,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
        grid,
        _buildDataPager()
      ]),
    );
  }

  @override
  void initState() {
    super.initState();

    _dataSource = ProjectEntityDataSource(
      buildContext: context,
      funConfirmToActive: (e) {
        DialogUtil.showCustomDialog(
          context: context,
          title: "项目 ${e.projectName} 激活配置",
          content: ActiveDialogWidget(
            projectRecordEntity: e,
            workShopVm: _workShopVm,
            goToWorkShop: null,
            defaultJavaHome: _envParamVm.javaRoot,
          ),
          showActions: false,
        );
      },
      funcGoPackageAction: (e) {
        e.apkPath = null;

        DialogUtil.showCustomDialog(
            context: context,
            title: "项目 ${e.projectName} 打包配置",
            content: StartPackageDialogWidget(
              projectRecordEntity: e,
              workShopVm: _workShopVm,
              enableAssembleOrders: e.assembleOrderList,
              goToWorkShop: null,
              defaultJavaHome: _envParamVm.javaRoot,
            ),
            showActions: false);
      },
      funJumpToWorkShop: confirmGoToWorkShop,
      openFastUploadDialogFunc: (e, s) => DialogUtil.showCustomDialog(
          showActions: false,
          context: context,
          title: "快速上传",
          content: FastUploadDialogWidget(
            projectRecordEntity: e,
            workShopVm: _workShopVm,
            apkPath: s,
          )),
      funJudgeProjectStatue: (ProjectRecordEntity entity) {
        // 判断当前工程的状态
        if (_workShopVm.runningTask != null &&
            _workShopVm.runningTask! == entity) {
          return ProjectRecordStatue.running;
        } else if (_workShopVm.getQueueList().contains(entity)) {
          return ProjectRecordStatue.waiting;
        } else if (entity.preCheckOk == true) {
          return ProjectRecordStatue.checked;
        } else {
          return ProjectRecordStatue.unchecked;
        }
      },
      onRead: () => setState(() {}),
    );

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _dataSource.init();
      _workShopVm.onTaskFinished = _dataSource.init;
      _workShopVm.onProcessChanged = (double v) {
        _dataSource.runningProcessValue = v;
        _dataSource.notifyListeners();
      };

      setState(() {}); // 表格刷新貌似有bug，必须加这一句主动再刷新一次，才能让分页标签出现
    });
  }

  /// Define list of CommandBarItem
  get simpleCommandBarItems => <CommandBarItem>[
        CommandBarBuilderItem(
          builder: (context, mode, w) => Tooltip(
            message: "新建一个安卓工程",
            child: commandCard(w),
          ),
          wrappedItem: CommandBarButton(
            icon: const Icon(FluentIcons.add),
            label:
                const Text('新建', style: TextStyle(fontWeight: FontWeight.w600)),
            onPressed: createAndroidProjectRecord,
          ),
        ),
        CommandBarBuilderItem(
          builder: (context, mode, w) => Tooltip(
            message: "清空所有工程",
            child: commandCard(w),
          ),
          wrappedItem: CommandBarButton(
            icon: const Icon(FluentIcons.clear),
            label:
                const Text('清空', style: TextStyle(fontWeight: FontWeight.w600)),
            onPressed: clearAllProjectRecord,
          ),
        ),
        CommandBarBuilderItem(
          builder: (context, mode, w) => Tooltip(
            message: "刷新表格数据",
            child: commandCard(w),
          ),
          wrappedItem: CommandBarButton(
            icon: const Icon(FluentIcons.refresh),
            label:
                const Text('刷新', style: TextStyle(fontWeight: FontWeight.w600)),
            onPressed: _dataSource.init,
          ),
        ),
        CommandBarBuilderItem(
          builder: (context, mode, w) => Tooltip(
            message: "进入工坊查看详情",
            child: commandCard(w),
          ),
          wrappedItem: CommandBarButton(
            icon: Icon(
              FluentIcons.a_t_p_logo,
              color: _getWorkshopColor(),
            ),
            label: Row(
              children: [
                const Text('工坊', style: TextStyle(fontWeight: FontWeight.w600)),
                if (_workShopVm.runningTask != null) ...[
                  const SizedBox(width: 20),
                  Icon(
                    FluentIcons.bus_solid,
                    color: _getWorkshopColor(),
                  ),
                  const Text(
                    " 作业中",
                    style: TextStyle(fontWeight: FontWeight.w600),
                  )
                ] else ...[
                  const SizedBox(width: 20),
                  Icon(
                    FluentIcons.information_barriers,
                    color: _getWorkshopColor(),
                  ),
                  const Text(
                    " 闲置中",
                    style: TextStyle(fontWeight: FontWeight.w600),
                  )
                ],
                if (_workShopVm.queryListNotEmpty) ...[
                  const SizedBox(width: 10),
                  Icon(
                    FluentIcons.waitlist_confirm,
                    color: _getWorkshopColor(),
                  ),
                  Text(
                    " 等待队列: ${_workShopVm.getQueueList().length}",
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  )
                ],
                const SizedBox(width: 10),
              ],
            ),
            onPressed: () => context.go('/work_shop'),
          ),
        ),
      ];

  Widget commandCard(Widget w) {
    return Container(
      margin: const EdgeInsets.only(right: 5),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5), gradient: cardGradient),
      child: w,
    );
  }

  void clearAllProjectRecord() {
    DialogUtil.showCustomDialog(
      context: context,
      content: "确定删除所有工程记录么?",
      title: '警告',
      onConfirm: _dataSource.clearAllProjectRecord,
    );
  }

  /// 创建一个新的安卓工程record，并刷新UI
  void createAndroidProjectRecord() {
    TextEditingController gitUrlTextController = TextEditingController();
    TextEditingController branchNameTextController = TextEditingController();
    TextEditingController projectNameTextController = TextEditingController();
    TextEditingController projectDescTextController = TextEditingController();

    var contentWidget = CreateProjectDialogWidget(
      projectNameTextController: projectNameTextController,
      gitUrlTextController: gitUrlTextController,
      branchNameTextController: branchNameTextController,
      projectDescTextController: projectDescTextController,
      defaultBranch: "master",
    );

    DialogUtil.showCustomDialog(
        context: context,
        maxWidth: 700,
        title: '新建工程',
        content: contentWidget,
        showActions: true,
        confirmText: "确定",
        onConfirm: () {
          if (!isValidGitUrl(gitUrlTextController.text)) {
            return false;
          }
          var insertProjectRecord = _dataSource.insertProjectRecord(
            gitUrlTextController.text,
            branchNameTextController.text,
            projectNameTextController.text,
            projectDescTextController.text,
          );

          if (insertProjectRecord != true) {
            ToastUtil.showPrettyToast("已存在相同项目, 请检查现有项目列表 ");
            return false;
          }

          DialogUtil.showCustomDialog(
            context: context,
            title: "项目 ${projectNameTextController.text} 激活配置",
            content: ActiveDialogWidget(
              projectRecordEntity: ProjectRecordEntity(
                gitUrlTextController.text,
                branchNameTextController.text,
                projectNameTextController.text,
                projectDescTextController.text,
              ),
              workShopVm: _workShopVm,
              goToWorkShop: null,
              defaultJavaHome: _envParamVm.javaRoot,
            ),
            showActions: false,
          );
        },
        judgePop: () {
          if (gitUrlTextController.text.isEmpty ||
              branchNameTextController.text.isEmpty ||
              projectNameTextController.text.isEmpty ||
              projectDescTextController.text.isEmpty) {
            return false;
          }
          if (!isValidGitUrl(gitUrlTextController.text)) {
            return false;
          }
          return true;
        });
  }

  double get pageCount {
    if (_dataSource.dataList.isEmpty) {
      return 1;
    }
    return (_dataSource.dataList.length / _rowsPerPage).ceilToDouble();
  }

  Widget _buildDataPager() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: SfDataPagerTheme(
        data: SfDataPagerThemeData(
            backgroundColor: _appTheme.bgColorSucc.withOpacity(.1),
            itemColor: Colors.white,
            itemBorderColor: Colors.orange),
        child: SfDataPager(
          delegate: _dataSource,
          availableRowsPerPage: const <int>[10, 15, 20],
          pageCount: pageCount,
          onRowsPerPageChanged: (int? rowsPerPage) {
            setState(() {
              _rowsPerPage = rowsPerPage!;
            });
          },
        ),
      ),
    );
  }

  List<GridColumn> get _getGridHeader {
    var bg = Colors.green.withOpacity(.3);
    var zeroBorder = const BorderRadius.only(topRight: Radius.circular(0));
    var topLeftBorder = const BorderRadius.only(topLeft: Radius.circular(2));
    var topRightBorder = const BorderRadius.only(topRight: Radius.circular(2));
    var borderRight =
        const Border(right: BorderSide(color: Colors.white, width: .7));

    Widget leftContainer(String title) {
      return Container(
          decoration: BoxDecoration(
              color: bg, borderRadius: topLeftBorder, border: borderRight),
          alignment: Alignment.center,
          child: Text(title, style: gridTextStyle));
    }

    Widget centerContainer(String title) {
      return Container(
          decoration: BoxDecoration(
              color: bg, borderRadius: zeroBorder, border: borderRight),
          alignment: Alignment.center,
          child: Text(title, style: gridTextStyle));
    }

    Widget rightContainer(String title) {
      return Container(
          decoration: BoxDecoration(color: bg, borderRadius: topRightBorder),
          alignment: Alignment.center,
          child: Text(title, style: gridTextStyle));
    }

    return <GridColumn>[
      GridColumn(
          columnName: ColumnNameConst.projectName,
          minimumWidth: minimumWidth,
          width: projectNameColumnWidth,
          columnWidthMode: ColumnWidthMode.fill,
          label: leftContainer("工程名称")),
      GridColumn(
          columnName: ColumnNameConst.gitUrl,
          minimumWidth: minimumWidth,
          width: gitUrlColumnWidth,
          columnWidthMode: ColumnWidthMode.fill,
          label: centerContainer("远程仓库")),
      GridColumn(
          columnName: ColumnNameConst.branch,
          minimumWidth: minimumWidth,
          width: branchColumnWidth,
          label: centerContainer("分支名称")),
      GridColumn(
          columnName: ColumnNameConst.statue,
          minimumWidth: 200,
          width: statueColumnWidth,
          label: centerContainer("状态")),
      GridColumn(
          minimumWidth: 200,
          width: jobOperationWidth,
          columnName: ColumnNameConst.jobOperation,
          label: centerContainer("作业功能")),
      GridColumn(
          columnName: ColumnNameConst.assembleOrders,
          minimumWidth: minimumWidth,
          width: assembleOrdersWidth,
          label: centerContainer("可用变体")),
      GridColumn(
        minimumWidth: minimumWidth,
        columnName: ColumnNameConst.recordOperation,
        label: rightContainer("项目操作"),
      ),
    ];
  }

  void confirmGoToWorkShop() {
    DialogUtil.showCustomDialog(
      context: context,
      title: '提示',
      content: '正在执行任务，是否进入工坊查看',
      onConfirm: () => context.go('/work_shop'),
    );
  }

  Color _getWorkshopColor() {
    if (_workShopVm.runningTask != null) {
      return Colors.red;
    } else {
      return Colors.black;
    }
  }

  final TextStyle _style = const TextStyle(
    fontSize: 15,
    color: Colors.black,
    fontWeight: FontWeight.w600,
    fontFamily: 'STKAITI',
  );

  List<Widget> getRecentJobResult() {
    var recentJobHistoryList =
        ProjectRecordOperator.getRecentJobHistoryList(recentCount: 10);

    return [
      ...recentJobHistoryList.map((e) {
        MyAppInfo myAppInfo;
        try {
          myAppInfo = MyAppInfo.fromJsonString(e.historyContent!);
        } catch (ex) {
          myAppInfo = MyAppInfo(errMessage: e.historyContent);
        }

        var color = e.success == true
            ? Colors.green.withOpacity(.1)
            : Colors.red.withOpacity(.1);

        return MouseRegion(
          onEnter: (event) {
            ProjectRecordOperator.setReadV2(jobHistoryEntity: e);
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
            child: Column(
              children: [
                _title(e, color),
                Card(
                  borderColor: Colors.transparent,
                  backgroundColor: color,
                  borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(10),
                      bottomRight: Radius.circular(10)),
                  child: Stack(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _text("git地址", e.gitUrl ?? ''),
                          _text("分支名", e.branchName ?? ''),
                          _text(
                              "构建时间",
                              Jiffy.parseFromDateTime(
                                      DateTime.fromMillisecondsSinceEpoch(
                                          e.buildTime ?? 0))
                                  .format(pattern: "yyyy-MM-dd HH:mm:ss")),
                          const SizedBox(height: 10),
                          JobSettingCard(e.jobSetting),
                          const SizedBox(height: 10),
                          AppInfoCard(
                              appInfo: myAppInfo, initiallyExpanded: false),
                          const SizedBox(height: 10),
                          Expander(
                            content: _text("阶段日志详情 TODO", ""),
                            header: Text("阶段日志详情", style: _style),
                          )
                        ],
                      ),
                      Positioned(
                        right: 10,
                        top: 10,
                        child: Visibility(
                          visible: e.hasRead != true,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Card(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 5, horizontal: 15),
                                  backgroundColor: Colors.red,
                                  borderRadius: BorderRadius.circular(7),
                                  child: const Text(
                                    "NEW",
                                    style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 16,
                                        color: Colors.white),
                                  )),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList()
    ];
  }

  Widget _title(JobHistoryEntity e, Color color) {
    return Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
        decoration: BoxDecoration(
            color: color.withBlue(20),
            borderRadius: const BorderRadius.only(
                topRight: Radius.circular(10), topLeft: Radius.circular(10))),
        width: double.infinity,
        child: Text("${e.projectName}",
            style: const TextStyle(
              fontSize: 25,
              color: Colors.black,
              fontWeight: FontWeight.w600,
            )));
  }

  Widget _text(String title, String content) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 5),
      child: Row(
        children: [
          Text("$title : ", style: gridTextStyle2),
          Text(
            content,
            style: gridTextStyle3,
          )
        ],
      ),
    );
  }
}
