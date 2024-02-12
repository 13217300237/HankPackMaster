import 'dart:math';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:hank_pack_master/comm/dialog_util.dart';
import 'package:hank_pack_master/hive/project_record/project_record_operator.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

import '../../hive/project_record/project_record_entity.dart';
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
    _dataSource = ProjectEntityDataSource();
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
    var gitUrlTextController = TextEditingController();
    var branchNameController = TextEditingController();

    var textStyle = const TextStyle(fontSize: 18);

    var gitUrlLabel =
        SizedBox(width: 100, child: Text('gitUrl', style: textStyle));
    var branchNameLabel =
        SizedBox(width: 100, child: Text('branchName', style: textStyle));

    var gitUrlTextBox = Expanded(
      child: TextBox(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              color: Colors.green.withOpacity(.1)),
          unfocusedColor: Colors.transparent,
          highlightColor: Colors.transparent,
          expands: false,
          maxLines: 1,
          style: textStyle,
          controller: gitUrlTextController),
    );
    var branchNameTextBox = Expanded(
      child: TextBox(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              color: Colors.green.withOpacity(.1)),
          unfocusedColor: Colors.transparent,
          highlightColor: Colors.transparent,
          expands: false,
          maxLines: 1,
          style: textStyle,
          controller: branchNameController),
    );
    var gitUrlRow =
        Row(children: [gitUrlLabel, const SizedBox(width: 20), gitUrlTextBox]);
    var branchNameRow = Row(children: [
      branchNameLabel,
      const SizedBox(width: 20),
      branchNameTextBox
    ]);
    // 弹窗
    var contentWidget = Column(mainAxisSize: MainAxisSize.min, children: [
      const SizedBox(height: 5),
      gitUrlRow,
      const SizedBox(height: 10),
      branchNameRow,
    ]);

    DialogUtil.showCustomDialog(
        context: context,
        title: '新增工程',
        content: contentWidget,
        showActions: true,
        confirmText: "确定",
        onConfirm: () {
          if (gitUrlTextController.text.isEmpty ||
              branchNameController.text.isEmpty) {
            DialogUtil.showInfo(
                context: context, content: "gitUrl和branchName必须全部正确填写...");
            return false;
          }

          var res = _dataSource.insertOrUpdateProjectRecord(
            gitUrlTextController.text,
            branchNameController.text,
          );
          if (res) {
            DialogUtil.showInfo(context: context, content: "新增成功");
          }
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
          columns: _getColumn,
        ),
      ),
    );

    var size = _dataSource.dataList.length;
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

  List<GridColumn> get _getColumn {
    var bg = Colors.green.withOpacity(.1);

    return <GridColumn>[
      GridColumn(
          columnName: 'gitUrl',
          label: Container(
              decoration: BoxDecoration(
                  color: bg,
                  borderRadius:
                      const BorderRadius.only(topLeft: Radius.circular(10))),
              padding: const EdgeInsets.only(left: 8.0),
              alignment: Alignment.centerLeft,
              child: const Text('gitUrl', style: gridTextStyle))),
      GridColumn(
        columnName: 'branch',
        label: Container(
            decoration: BoxDecoration(
                color: bg,
                borderRadius:
                    const BorderRadius.only(topRight: Radius.circular(10))),
            padding: const EdgeInsets.only(left: 8.0),
            alignment: Alignment.centerLeft,
            child: const Text('branch', style: gridTextStyle)),
      ),
    ];
  }
}
