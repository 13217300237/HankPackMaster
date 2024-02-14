import 'package:fluent_ui/fluent_ui.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

import '../../hive/project_record/project_record_entity.dart';
import '../../hive/project_record/project_record_operator.dart';

const TextStyle gridTextStyle = TextStyle(
    color: Color(0xff2C473E),
    fontFamily: 'STKAITI',
    fontWeight: FontWeight.w600);

enum CellType {
  text,
  preChecked,
  enqueueAction,
}

class CellValue {
  CellType cellType;
  dynamic value;
  ProjectRecordEntity? entity;

  CellValue({required this.cellType, required this.value, this.entity});
}

/// 数据源解析器
class ProjectEntityDataSource extends DataGridSource {
  List<DataGridRow> _rows = [];

  final List<ProjectRecordEntity> dataList = [];

  Function(ProjectRecordEntity)? funcGoToWorkShop;

  bool insertOrUpdateProjectRecord(String gitUrl, String branchName) {
    if (gitUrl.isEmpty || branchName.isEmpty) {
      return false;
    }

    ProjectRecordOperator.insertOrUpdate(
        ProjectRecordEntity(gitUrl, branchName));

    _refresh();

    return true;
  }

  void init() {
    _refresh();
  }

  void clearAllProjectRecord() async {
    debugPrint("执行删除全部");
    await ProjectRecordOperator.clear();
    _refresh();
  }

  /// 原来表格的刷新必须强制更新 每行组件（`_buildRows`）
  _refresh() {
    dataList.clear();
    dataList.addAll(ProjectRecordOperator.findAll());
    _buildRows();
    notifyListeners();
  }

  ProjectEntityDataSource(
      {required Function(ProjectRecordEntity) this.funcGoToWorkShop}) {
    _buildRows();
  }

  _buildRows() {
    _rows = dataList
        .map<DataGridRow>((e) => DataGridRow(cells: [
              DataGridCell<CellValue>(
                  columnName: 'gitUrl',
                  value: CellValue(value: e.gitUrl, cellType: CellType.text)),
              DataGridCell<CellValue>(
                  columnName: 'branch',
                  value: CellValue(value: e.branch, cellType: CellType.text)),
              DataGridCell<CellValue>(
                  columnName: 'statue',
                  value: CellValue(
                      value: e.preCheckOk, cellType: CellType.preChecked)),
              DataGridCell<CellValue>(
                  columnName: 'operation',
                  value: CellValue(
                      value: "任务入列",
                      cellType: CellType.enqueueAction,
                      entity: e)),
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
      CellValue cellValue = dataGridCell.value;

      Widget cellWidget;

      switch (cellValue.cellType) {
        case CellType.text:
          cellWidget = Text("${cellValue.value}", style: gridTextStyle);
          break;
        case CellType.preChecked:
          Color color;
          if (cellValue.value == true) {
            color = Colors.green;
          } else {
            color = Colors.grey.withOpacity(.5);
          }
          cellWidget = Icon(FluentIcons.skype_circle_check, color: color);
          break;
        case CellType.enqueueAction:
          cellWidget = Tooltip(
            message: "${cellValue.value}",
            child: IconButton(
              icon: Icon(FluentIcons.build_queue_new, color: Colors.blue),
              onPressed: () => funcGoToWorkShop?.call(cellValue.entity!),
            ),
          );
          break;
      }

      return Container(
        padding: const EdgeInsets.only(left: 5),
        alignment: Alignment.centerLeft,
        child: cellWidget,
      );
    }).toList());
  }
}
