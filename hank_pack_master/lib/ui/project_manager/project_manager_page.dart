import 'dart:math';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:go_router/go_router.dart';
import 'package:hank_pack_master/comm/dialog_util.dart';
import 'package:hank_pack_master/hive/project_record/project_record_operator.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

import '../../comm/url_check_util.dart';
import '../../hive/project_record/project_record_entity.dart';
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

  @override
  void initState() {
    super.initState();
    _dataSource = ProjectEntityDataSource(
      funcGoToWorkShop: (e) => context.go('/work_shop', extra: e),
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

    var contentWidget = CreateProjectDialogWidget(
        gitUrlTextController: gitUrlTextController,
        branchNameTextController: branchNameTextController);

    DialogUtil.showCustomDialog(
        context: context,
        title: '新增工程',
        content: contentWidget,
        showActions: true,
        confirmText: "确定",
        onConfirm: () {
          debugPrint(
              "当前 gitUrl: ${gitUrlTextController.text} ,校验结果 ${isValidGitUrl(gitUrlTextController.text)}");

          if (!isValidGitUrl(gitUrlTextController.text)) {
            DialogUtil.showInfo(context: context, content: "gitUrl 填写格式不正确");
            return false;
          }
          _dataSource.insertOrUpdateProjectRecord(
              gitUrlTextController.text, branchNameTextController.text);
        },
        judgePop: () {
          if (gitUrlTextController.text.isEmpty ||
              branchNameTextController.text.isEmpty) {
            DialogUtil.showInfo(
                context: context, content: "gitUrl 和 branchName 必须都正确填写!");
            return false;
          }
          if (!isValidGitUrl(gitUrlTextController.text)) {
            DialogUtil.showInfo(context: context, content: "gitUrl 填写格式不正确");
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

  @override
  Widget build(BuildContext context) {
    var grid = Expanded(
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: SfDataGrid(
          columnWidthMode: ColumnWidthMode.fill,
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
    var bg = Colors.green.withOpacity(.1);
    var radius = 5.0;

    return <GridColumn>[
      GridColumn(
          columnName: 'gitUrl',
          label: Container(
              decoration: BoxDecoration(
                  color: bg,
                  borderRadius:
                      BorderRadius.only(topLeft: Radius.circular(radius))),
              padding: const EdgeInsets.only(left: 8.0),
              alignment: Alignment.centerLeft,
              child: const Text('gitUrl', style: gridTextStyle))),
      GridColumn(
        columnName: 'branch',
        label: Container(
            decoration: BoxDecoration(
                color: bg,
                borderRadius:
                    BorderRadius.only(topRight: Radius.circular(radius))),
            padding: const EdgeInsets.only(left: 8.0),
            alignment: Alignment.centerLeft,
            child: const Text('branch', style: gridTextStyle)),
      ),
      GridColumn(
        columnName: 'operation',
        label: Container(
            decoration: BoxDecoration(
                color: bg,
                borderRadius:
                    BorderRadius.only(topRight: Radius.circular(radius))),
            padding: const EdgeInsets.only(left: 8.0),
            alignment: Alignment.centerLeft,
            child: const Text('操作', style: gridTextStyle)),
      ),
    ];
  }
}
