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

  late GridDataSource _dataSource;
  final int _rowsPerPage = 10;

  @override
  void initState() {
    super.initState();
    _dataSource = GridDataSource(data: _getProjectRecordEntity);
  }

  List<ProjectRecordEntity> get _getProjectRecordEntity {
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

  /// Define list of CommandBarItem
  get simpleCommandBarItems => <CommandBarItem>[
        CommandBarBuilderItem(
          builder: (context, mode, w) => Tooltip(
            message: "新建工程",
            child: w,
          ),
          wrappedItem: CommandBarButton(
            icon: const Icon(FluentIcons.add),
            label: const Text('新建'),
            onPressed: () {},
          ),
        ),
        const CommandBarButton(
          icon: Icon(FluentIcons.cancel),
          label: Text('Disabled'),
          onPressed: null,
        ),
      ];

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
          rowsPerPage: _rowsPerPage,
          source: _dataSource,
          columns: _getColumn,
        ),
      ),
    );

    var pager = SizedBox(
      width: MediaQuery.of(context).size.width / 2,
      child: SfDataPager(
        pageCount: ((_getProjectRecordEntity.length / _rowsPerPage).ceil())
            .toDouble(),
        direction: Axis.horizontal,
        delegate: _dataSource,
      ),
    );

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
            pager
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
