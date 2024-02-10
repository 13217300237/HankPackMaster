import 'package:fluent_ui/fluent_ui.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

import '../../hive/project_record/project_record_entity.dart';
import 'grid_datasource.dart';

class ProjectManagerPage extends StatefulWidget {
  const ProjectManagerPage({super.key});

  @override
  State<ProjectManagerPage> createState() => _ProjectManagerPageState();
}

class _ProjectManagerPageState extends State<ProjectManagerPage> {
  List<ProjectRecordEntity> projectRecordEntityList = <ProjectRecordEntity>[];

  late GridDataSource _dataSource;

  @override
  void initState() {
    super.initState();
    projectRecordEntityList = getProjectRecordEntity();
    _dataSource = GridDataSource(data: projectRecordEntityList);
  }

  List<ProjectRecordEntity> getProjectRecordEntity() {
    return [
      ProjectRecordEntity(
          "git@github.com:18598925736/MyApplication0016.git", "dev"),
      ProjectRecordEntity(
          "git@github.com:18598925736/MyApp20231224.git", "dev"),
      ProjectRecordEntity(
          "ssh://git@codehub-dg-g.huawei.com:2222/zWX1245985/test20240204_2.git",
          "master"),

      ProjectRecordEntity(
          "git@github.com:18598925736/MyApplication0016.git", "dev"),
      ProjectRecordEntity(
          "git@github.com:18598925736/MyApp20231224.git", "dev"),
      ProjectRecordEntity(
          "ssh://git@codehub-dg-g.huawei.com:2222/zWX1245985/test20240204_2.git",
          "master"),

      ProjectRecordEntity(
          "git@github.com:18598925736/MyApplication0016.git", "dev"),
      ProjectRecordEntity(
          "git@github.com:18598925736/MyApp20231224.git", "dev"),
      ProjectRecordEntity(
          "ssh://git@codehub-dg-g.huawei.com:2222/zWX1245985/test20240204_2.git",
          "master"),

      ProjectRecordEntity(
          "git@github.com:18598925736/MyApplication0016.git", "dev"),
      ProjectRecordEntity(
          "git@github.com:18598925736/MyApp20231224.git", "dev"),
      ProjectRecordEntity(
          "ssh://git@codehub-dg-g.huawei.com:2222/zWX1245985/test20240204_2.git",
          "master"),

      ProjectRecordEntity(
          "git@github.com:18598925736/MyApplication0016.git", "dev"),
      ProjectRecordEntity(
          "git@github.com:18598925736/MyApp20231224.git", "dev"),
      ProjectRecordEntity(
          "ssh://git@codehub-dg-g.huawei.com:2222/zWX1245985/test20240204_2.git",
          "master"),
    ];
  }

  final int _rowsPerPage = 5;

  @override
  Widget build(BuildContext context) {

    var grid = Expanded(
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: SfDataGrid(
          columnWidthMode: ColumnWidthMode.fill,
          navigationMode: GridNavigationMode.cell,
          gridLinesVisibility: GridLinesVisibility.none,
          headerGridLinesVisibility: GridLinesVisibility.none,
          source: _dataSource,
          columns: _getColumn,
        ),
      ),
    );

    var pager = SizedBox(
      width: MediaQuery.of(context).size.width / 2,
      child: SfDataPager(
        pageCount:
            ((projectRecordEntityList.length / _rowsPerPage).ceil()).toDouble(),
        direction: Axis.horizontal,
        delegate: _dataSource,
      ),
    );


    return Column(children: [grid, pager]);
  }

  List<GridColumn> get _getColumn {
    return <GridColumn>[
      GridColumn(
          columnName: 'gitUrl',
          label: Container(
              padding: const EdgeInsets.only(left: 8.0),
              alignment: Alignment.centerLeft,
              child: const Text('gitUrl'))),
      GridColumn(
        columnName: 'branch',
        label: Container(
            padding: const EdgeInsets.only(left: 8.0),
            alignment: Alignment.centerLeft,
            child: const Text('branch')),
      ),
    ];
  }
}
