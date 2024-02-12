import 'package:fluent_ui/fluent_ui.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

import '../../hive/project_record/project_record_entity.dart';
import '../../hive/project_record/project_record_operator.dart';

const TextStyle gridTextStyle = TextStyle(color: Color(0xff2C473E));

/// 数据源解析器
class ProjectEntityDataSource extends DataGridSource {
  List<DataGridRow> _rows = [];

  final List<ProjectRecordEntity> dataList = Iterable.generate(21)
      .map((e) => ProjectRecordEntity("$e", "testBranch"))
      .toList();

  void insertOrUpdateProjectRecord() {
    ProjectRecordOperator.insertOrUpdate(ProjectRecordEntity(
        "${DateTime.now().millisecondsSinceEpoch}", "testBranch"));

    dataList.clear();
    dataList.addAll(ProjectRecordOperator.findAll());
    refresh();
  }

  /// 原来表格的刷新必须强制更新 每行组件（`_buildRows`）
  refresh() {
    _buildRows();
    notifyListeners();
  }

  ProjectEntityDataSource() {
    _buildRows();
  }

  _buildRows() {
    _rows = dataList
        .map<DataGridRow>((e) => DataGridRow(cells: [
              DataGridCell<String>(columnName: 'gitUrl', value: e.gitUrl),
              DataGridCell<String>(columnName: 'branch', value: e.branch),
            ]))
        .toList();
  }

  @override
  List<DataGridRow> get rows => _rows;

  /// 每行UI的构建逻辑
  @override
  DataGridRowAdapter? buildRow(DataGridRow row) {
    return DataGridRowAdapter(
        cells: row.getCells().map<Widget>((dataGridCell) {
      return Container(
        padding: const EdgeInsets.only(left: 10),
        alignment: Alignment.centerLeft,
        child: Text(dataGridCell.value.toString(), style: gridTextStyle),
      );
    }).toList());
  }
}
