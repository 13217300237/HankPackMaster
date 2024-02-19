import 'package:fluent_ui/fluent_ui.dart';
import 'package:go_router/go_router.dart';
import 'package:hank_pack_master/comm/dialog_util.dart';
import 'package:hank_pack_master/ui/project_manager/dialog/start_package_dialog.dart';
import 'package:hank_pack_master/ui/work_shop/work_shop_vm.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

import '../../comm/toast_util.dart';
import '../../comm/url_check_util.dart';
import 'column_name_const.dart';
import 'dialog/create_project_record_dialog.dart';
import 'grid_datasource.dart';

class ProjectManagerPage extends StatefulWidget {
  const ProjectManagerPage({super.key});

  @override
  State<ProjectManagerPage> createState() => _ProjectManagerPageState();
}

const minimumWidth = 100.0;

class _ProjectManagerPageState extends State<ProjectManagerPage> {
  late ProjectEntityDataSource _dataSource;
  int _rowsPerPage = 10;

  double projectNameColumnWidth = 150;
  double gitUrlColumnWidth = 300;
  double branchColumnWidth = minimumWidth;
  double statueColumnWidth = minimumWidth;
  double assembleOrdersWidth = 250;
  double jobOperationWidth = minimumWidth;

  @override
  void initState() {
    super.initState();
    _dataSource = ProjectEntityDataSource(
      buildContext: context,
      funcGoToWorkShop: (e) {
        DialogUtil.showCustomDialog(
            context: context,
            title: "项目激活提醒",
            content: "要激活此项目么？ \n ${e.projectName}",
            confirmText: "确定激活",
            onConfirm: () {
              var enqueueSuccess = _workShopVm.enqueue(e);
              if (enqueueSuccess) {
                context.go('/work_shop');
              } else {
                ToastUtil.showPrettyToast('入列失败,发现重复任务');
              }
            });
      },
      funcGoPackageAction: (e) {
        DialogUtil.showCustomDialog(
            context: context,
            title: "项目 ${e.projectName} 打包配置",
            content: StartPackageDialogWidget(
              projectRecordEntity: e,
              workShopVm: _workShopVm,
              enableAssembleOrders: e.assembleOrders ?? [],
              goToWorkShop: () => context.go('/work_shop'),
            ),
            showActions: false);
      },
    );

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _dataSource.init();
      _workShopVm.onTaskFinished = _dataSource.init;
    });
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
            label:
                const Text('新建', style: TextStyle(fontWeight: FontWeight.w600)),
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
            label:
                const Text('清空', style: TextStyle(fontWeight: FontWeight.w600)),
            onPressed: clearAllProjectRecord,
          ),
        ),
        CommandBarBuilderItem(
          builder: (context, mode, w) => Tooltip(
            message: "刷新",
            child: w,
          ),
          wrappedItem: CommandBarButton(
            icon: const Icon(FluentIcons.refresh),
            label:
                const Text('刷新', style: TextStyle(fontWeight: FontWeight.w600)),
            onPressed: _dataSource.init,
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

  late WorkShopVm _workShopVm;

  @override
  Widget build(BuildContext context) {
    _workShopVm = context.watch<WorkShopVm>();

    var grid = Expanded(
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.teal, width: .1),
          borderRadius: const BorderRadius.all(Radius.circular(3)),
        ),
        margin: const EdgeInsets.all(15),
        child: SfDataGrid(
          columnWidthMode: ColumnWidthMode.fill,
          allowColumnsResizing: true,
          columnResizeMode: ColumnResizeMode.onResize,
          onColumnResizeUpdate: (ColumnResizeUpdateDetails args) {
            setState(() {

              switch(args.column.columnName){
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
    var borderRight =
        const Border(right: BorderSide(color: Colors.white, width: .7));

    return <GridColumn>[
      GridColumn(
          columnName: ColumnNameConst.projectName,
          minimumWidth: minimumWidth,
          width: projectNameColumnWidth,
          columnWidthMode: ColumnWidthMode.fill,
          label: Container(
              decoration: BoxDecoration(
                  color: bg, borderRadius: topLeftBorder, border: borderRight),
              alignment: Alignment.center,
              child: const Text('项目名称', style: gridTextStyle))),
      GridColumn(
          columnName: ColumnNameConst.gitUrl,
          minimumWidth: minimumWidth,
          width: gitUrlColumnWidth,
          columnWidthMode: ColumnWidthMode.fill,
          label: Container(
              decoration: BoxDecoration(
                  color: bg, borderRadius: zeroBorder, border: borderRight),
              alignment: Alignment.center,
              child: const Text('远程仓库', style: gridTextStyle))),
      GridColumn(
        columnName: ColumnNameConst.branch,
        minimumWidth: minimumWidth,
        width: branchColumnWidth,
        label: Container(
            decoration: BoxDecoration(
                color: bg, borderRadius: zeroBorder, border: borderRight),
            alignment: Alignment.center,
            child: const Text('分支名', style: gridTextStyle)),
      ),
      GridColumn(
        columnName: ColumnNameConst.statue,
        minimumWidth: minimumWidth,
        width: statueColumnWidth,
        label: Container(
            decoration: BoxDecoration(
                color: bg, borderRadius: zeroBorder, border: borderRight),
            alignment: Alignment.center,
            child: const Text('激活状态', style: gridTextStyle)),
      ),
      GridColumn(
        minimumWidth: minimumWidth,
        width: jobOperationWidth,
        columnName: ColumnNameConst.jobOperation,
        label: Container(
            decoration: BoxDecoration(color: bg, borderRadius: topRightBorder),
            alignment: Alignment.center,
            child: const Text('作业功能', style: gridTextStyle)),
      ),
      GridColumn(
        columnName: ColumnNameConst.assembleOrders,
        minimumWidth: minimumWidth,
        width: assembleOrdersWidth,
        label: Container(
            decoration: BoxDecoration(
                color: bg, borderRadius: zeroBorder, border: borderRight),
            alignment: Alignment.center,
            child: const Text('可用变体', style: gridTextStyle)),
      ),
      GridColumn(
        minimumWidth: minimumWidth,
        columnName: ColumnNameConst.recordOperation,
        label: Container(
            decoration: BoxDecoration(color: bg, borderRadius: topRightBorder),
            alignment: Alignment.center,
            child: const Text('项目操作', style: gridTextStyle)),
      ),
    ];
  }
}
