import 'package:fluent_ui/fluent_ui.dart';
import 'package:hank_pack_master/comm/toast_util.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

import '../../hive/project_record/project_record_entity.dart';
import '../../hive/project_record/project_record_operator.dart';
import 'column_name_const.dart';

const TextStyle gridTextStyle = TextStyle(
    color: Color(0xff2C473E),
    fontFamily: 'STKAITI',
    fontWeight: FontWeight.w600);

enum CellType {
  text, // 纯文案显示
  preChecked, // 预检状态标志
  goPreCheck, // 操作入列按钮
  goPackageAction, // 进入打包操作
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
  Function(ProjectRecordEntity)? funcGoPackageAction;

  bool insertOrUpdateProjectRecord(
      String gitUrl, String branchName, String projectName) {
    if (gitUrl.isEmpty || branchName.isEmpty || projectName.isEmpty) {
      return false;
    }

    ProjectRecordOperator.insertOrUpdate(
      ProjectRecordEntity(gitUrl, branchName, projectName),
    );

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

  ProjectEntityDataSource({
    required this.funcGoToWorkShop,
    required this.funcGoPackageAction,
  }) {
    _buildRows();
  }

  _buildRows() {
    _rows = dataList
        .map<DataGridRow>((e) => DataGridRow(cells: [
              DataGridCell<CellValue>(
                  columnName: ColumnNameConst.projectName,
                  value:
                      CellValue(value: e.projectName, cellType: CellType.text)),
              DataGridCell<CellValue>(
                  columnName: ColumnNameConst.gitUrl,
                  value: CellValue(value: e.gitUrl, cellType: CellType.text)),
              DataGridCell<CellValue>(
                  columnName: ColumnNameConst.branch,
                  value: CellValue(value: e.branch, cellType: CellType.text)),
              DataGridCell<CellValue>(
                  columnName: ColumnNameConst.statue,
                  value: CellValue(
                      value: e.preCheckOk, cellType: CellType.preChecked)),
              DataGridCell<CellValue>(
                  columnName: ColumnNameConst.assembleOrders,
                  value: CellValue(
                      value: e.assembleOrders, cellType: CellType.text)),
              if (e.preCheckOk) ...[
                DataGridCell<CellValue>(
                    columnName: ColumnNameConst.operation,
                    value: CellValue(
                      value: "开始打包",
                      cellType: CellType.goPackageAction,
                      entity: e,
                    )),
              ] else ...[
                DataGridCell<CellValue>(
                    columnName: ColumnNameConst.operation,
                    value: CellValue(
                      value: "马上激活",
                      cellType: CellType.goPreCheck,
                      entity: e,
                    )),
              ],
            ]))
        .toList();
  }

  @override
  List<DataGridRow> get rows => _rows;

  /// 每行UI的构建逻辑
  @override
  DataGridRowAdapter? buildRow(DataGridRow row) {
    var rowIndex = rows.indexOf(row);
    Color backgroundColor = Colors.transparent;
    if ((rowIndex % 2) == 1) {
      backgroundColor = Colors.green.withOpacity(.1);
    }

    return DataGridRowAdapter(
        color: backgroundColor,
        cells: row.getCells().map<Widget>((dataGridCell) {
          CellValue cellValue = dataGridCell.value;

          Widget cellWidget;

          switch (cellValue.cellType) {
            case CellType.text:
              cellWidget = Text(
                "${cellValue.value}",
                style: gridTextStyle,
                overflow: TextOverflow.ellipsis,
              );
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
            case CellType.goPreCheck:
              cellWidget = Tooltip(
                message: "${cellValue.value}",
                child: IconButton(
                  icon: Icon(FluentIcons.build_queue_new,
                      color: Colors.green.withOpacity(.8)),
                  onPressed: () => funcGoToWorkShop?.call(cellValue.entity!),
                ),
              );
              break;
            case CellType.goPackageAction:
              cellWidget = Tooltip(
                message: "${cellValue.value}",
                child: IconButton(
                  icon: Icon(FluentIcons.packages,
                      color: Colors.green.withOpacity(.8)),
                  onPressed: () => funcGoPackageAction?.call(cellValue.entity!),
                ),
              );
              break;
          }

          return Container(
            padding: const EdgeInsets.only(left: 5),
            alignment: Alignment.center,
            child: cellWidget,
          );
        }).toList());
  }
}
