import 'package:fluent_ui/fluent_ui.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

import '../../hive/project_record/project_record_entity.dart';

/// 数据源解析器
class GridDataSource extends DataGridSource {
  List<DataGridRow> _dataList = [];

  GridDataSource({required List<ProjectRecordEntity> data}) {
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
        child: Text(dataGridCell.value.toString()),
      );
    }).toList());
  }
}
