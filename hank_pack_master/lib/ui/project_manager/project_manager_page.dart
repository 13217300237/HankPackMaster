import 'package:fluent_ui/fluent_ui.dart';
import 'package:go_router/go_router.dart';
import 'package:hank_pack_master/comm/dialog_util.dart';
import 'package:hank_pack_master/hive/project_record/project_record_operator.dart';
import 'package:hank_pack_master/ui/project_manager/dialog/active_dialog.dart';
import 'package:hank_pack_master/ui/project_manager/dialog/start_package_dialog.dart';
import 'package:hank_pack_master/ui/work_shop/work_shop_vm.dart';
import 'package:jiffy/jiffy.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

import '../../comm/gradients.dart';
import '../../comm/url_check_util.dart';
import '../../hive/project_record/project_record_entity.dart';
import '../comm/theme.dart';
import '../comm/vm/env_param_vm.dart';
import 'column_name_const.dart';
import 'dialog/create_project_record_dialog.dart';
import 'dialog/fast_upload_dialog.dart';
import 'grid_datasource.dart';
import 'package:syncfusion_flutter_core/theme.dart';
import 'package:flutter/material.dart' as m;

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
        Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0),
            child: CommandBar(
                overflowBehavior: CommandBarOverflowBehavior.noWrap,
                primaryItems: [...simpleCommandBarItems])),
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
            enableAssembleOrders: e.assembleOrderList,
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
    );

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _dataSource.init();
      _workShopVm.onTaskFinished = _dataSource.init;
      _workShopVm.onProcessChanged = (double v) {
        _dataSource.runningProcessValue = v;
        _dataSource.notifyListeners();
      };
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
        CommandBarBuilderItem(
          builder: (context, mode, w) => Tooltip(
            message: "最近作业历史",
            child: commandCard(w),
          ),
          wrappedItem: CommandBarButton(
            icon: const Icon(FluentIcons.history),
            label: const Text('最近作业历史',
                style: TextStyle(fontWeight: FontWeight.w600)),
            onPressed: () {
              DialogUtil.showCustomDialog(
                context: context,
                title: "最近作业历史",
                content: ListView(
                  children: [...getRecentJobResult()],
                ),
              );
            },
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
    );

    DialogUtil.showCustomDialog(
        context: context,
        title: '新建工程',
        content: contentWidget,
        showActions: true,
        confirmText: "确定",
        onConfirm: () {
          if (!isValidGitUrl(gitUrlTextController.text)) {
            return false;
          }
          _dataSource.insertOrUpdateProjectRecord(
            gitUrlTextController.text,
            branchNameTextController.text,
            projectNameTextController.text,
            projectDescTextController.text,
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

  List<Widget> getRecentJobResult() {
    var recentJobHistoryList =
        ProjectRecordOperator.getRecentJobHistoryList(recentCount: 3);

    return [
      ...recentJobHistoryList.map((e) {
        return m.Card(
          color: e.success == true
              ? Colors.green.withOpacity(.1)
              : Colors.red.withOpacity(.1),
          margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("工程名:${e.projectName}", style: gridTextStyle),
                Text("git地址:${e.gitUrl}", style: gridTextStyle),
                Text("分支名：${e.branchName}", style: gridTextStyle),
                Text(
                    "构建时间:${Jiffy.parseFromDateTime(DateTime.fromMillisecondsSinceEpoch(e.buildTime ?? 0)).format(pattern: "yyyy-MM-dd HH:mm:ss")}",
                    style: gridTextStyle),
                Text("打包历史内容:${e.historyContent}", style: gridTextStyle),
              ],
            ),
          ),
        );
      }).toList()
    ];
  }
}
