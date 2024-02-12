import 'dart:math';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

import '../../hive/project_record/project_record_entity.dart';

const TextStyle gridTextStyle = TextStyle(color: Color(0xff2C473E));

/// 数据源解析器
class ProjectEntityDataSource extends DataGridSource {
  List<DataGridRow> _dataList = [];

  final List<ProjectRecordEntity> data = Iterable.generate(21)
      .map((e) => ProjectRecordEntity("$e", "testBranch"))
      .toList();

  refresh() {
    _buildRows();
    notifyListeners();
  }

  ProjectEntityDataSource() {
    _buildRows();
  }

  _buildRows() {
    _dataList = data
        .map<DataGridRow>((e) => DataGridRow(cells: [
              DataGridCell<String>(columnName: 'gitUrl', value: e.gitUrl),
              DataGridCell<String>(columnName: 'branch', value: e.branch),
            ]))
        .toList();
  }

  @override
  List<DataGridRow> get rows => _dataList;

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
