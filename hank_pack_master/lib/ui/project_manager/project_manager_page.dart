import 'package:fluent_ui/fluent_ui.dart';
import 'package:hank_pack_master/comm/dialog_util.dart';
import 'package:hank_pack_master/ui/comm/vm/task_queue_vm.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

import '../../comm/url_check_util.dart';
import 'column_name_getter.dart';
import 'create_project_record_dialog.dart';
import 'grid_datasource.dart';

class ProjectManagerPage extends StatefulWidget {
  const ProjectManagerPage({super.key});

  @override
  State<ProjectManagerPage> createState() => _ProjectManagerPageState();
}

class _ProjectManagerPageState extends State<ProjectManagerPage> {
  late ProjectEntityDataSource _dataSource;
  int _rowsPerPage = 10;

  double projectNameColumnWidth = 200;
  double gitUrlColumnWidth = 600;
  double branchNameColumnWidth = 100;
  double statueColumnWidth = 100;

  @override
  void initState() {
    super.initState();
    _dataSource = ProjectEntityDataSource(
      funcGoToWorkShop: (e) {
        _taskQueueVm.enqueue(e);
        DialogUtil.showInfo(context: context, content: "任务已入列");
      },
    );
    _dataSource.init();
  }

  /// Define list of CommandBarItem
  get simpleCommandBarItems => <CommandBarItem>[
        CommandBarBuilderItem(
          builder: (context, mode, w) => Tooltip(
            message: "新建一个安卓工程",
            child: w,
          ),
          wrappedItem: CommandBarButton(
            icon: const Icon(FluentIcons.add),
            label: const Text('新建'),
            onPressed: createAndroidProjectRecord,
          ),
        ),
        CommandBarBuilderItem(
          builder: (context, mode, w) => Tooltip(
            message: "清空所有工程",
            child: w,
          ),
          wrappedItem: CommandBarButton(
            icon: const Icon(FluentIcons.clear),
            label: const Text('清空'),
            onPressed: clearAllProjectRecord,
          ),
        ),
      ];

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

    var contentWidget = CreateProjectDialogWidget(
        projectNameTextController: projectNameTextController,
        gitUrlTextController: gitUrlTextController,
        branchNameTextController: branchNameTextController);

    DialogUtil.showCustomDialog(
        context: context,
        title: '新增工程',
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
          );
        },
        judgePop: () {
          if (gitUrlTextController.text.isEmpty ||
              branchNameTextController.text.isEmpty) {
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
    return SfDataPager(
      delegate: _dataSource,
      availableRowsPerPage: const <int>[10, 15, 20],
      pageCount: pageCount,
      onRowsPerPageChanged: (int? rowsPerPage) {
        setState(() {
          _rowsPerPage = rowsPerPage!;
        });
      },
    );
  }

  late TaskQueueVm _taskQueueVm;

  @override
  Widget build(BuildContext context) {
    _taskQueueVm = context.watch<TaskQueueVm>();

    var grid = Expanded(
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.teal, width: .1),
          borderRadius: const BorderRadius.all(Radius.circular(3)),
        ),
        margin: const EdgeInsets.all(15),
        child: SfDataGrid(
          columnWidthMode: ColumnWidthMode.lastColumnFill,
          allowColumnsResizing: true,
          columnResizeMode: ColumnResizeMode.onResize,
          onColumnResizeUpdate: (ColumnResizeUpdateDetails args) {
            setState(() {
              if (args.column.columnName == 'gitUrl') {
                gitUrlColumnWidth = args.width;
              } else if (args.column.columnName == 'branch') {
                branchNameColumnWidth = args.width;
              } else if (args.column.columnName == 'statue') {
                statueColumnWidth = args.width;
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
      color: const Color(0xffAFCF84),
      child: Card(
          backgroundColor: const Color(0xfff2f2e8),
          margin: const EdgeInsets.all(15),
          child: Column(children: [
            Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15.0),
                child: CommandBar(
                    overflowBehavior: CommandBarOverflowBehavior.noWrap,
                    primaryItems: [...simpleCommandBarItems])),
            grid,
            _buildDataPager()
          ])),
    );
  }

  List<GridColumn> get _getGridHeader {
    var bg = Colors.green.withOpacity(.3);
    var zeroBorder = const BorderRadius.only(topRight: Radius.circular(0));
    var topLeftBorder = const BorderRadius.only(topLeft: Radius.circular(2));
    var topRightBorder = const BorderRadius.only(topRight: Radius.circular(2));

    return <GridColumn>[
      GridColumn(
          columnName: ColumnNameConst.projectName,
          minimumWidth: 150.0,
          width: projectNameColumnWidth,
          columnWidthMode: ColumnWidthMode.fill,
          label: Container(
              decoration: BoxDecoration(color: bg, borderRadius: topLeftBorder),
              padding: const EdgeInsets.only(left: 8.0),
              alignment: Alignment.center,
              child: const Text('项目名称', style: gridTextStyle))),
      GridColumn(
          columnName: ColumnNameConst.gitUrl,
          minimumWidth: 150.0,
          width: gitUrlColumnWidth,
          columnWidthMode: ColumnWidthMode.fill,
          label: Container(
              decoration: BoxDecoration(color: bg, borderRadius: topLeftBorder),
              padding: const EdgeInsets.only(left: 8.0),
              alignment: Alignment.center,
              child: const Text('远程仓库', style: gridTextStyle))),
      GridColumn(
        columnName: ColumnNameConst.branch,
        width: branchNameColumnWidth,
        label: Container(
            decoration: BoxDecoration(color: bg, borderRadius: zeroBorder),
            padding: const EdgeInsets.only(left: 8.0),
            alignment: Alignment.center,
            child: const Text('分支名', style: gridTextStyle)),
      ),
      GridColumn(
        columnName: ColumnNameConst.statue,
        minimumWidth: 50.0,
        width: statueColumnWidth,
        label: Container(
            decoration: BoxDecoration(color: bg, borderRadius: zeroBorder),
            padding: const EdgeInsets.only(left: 8.0),
            alignment: Alignment.center,
            child: const Text('状态', style: gridTextStyle)),
      ),
      GridColumn(
        columnName: ColumnNameConst.operation,
        label: Container(
            decoration: BoxDecoration(color: bg, borderRadius: topRightBorder),
            padding: const EdgeInsets.only(left: 8.0),
            alignment: Alignment.center,
            child: const Text('操作', style: gridTextStyle)),
      ),
    ];
  }
}
