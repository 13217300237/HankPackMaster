import 'package:fluent_ui/fluent_ui.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

import 'entity.dart';

class ProjectManagerPage extends StatefulWidget {
  const ProjectManagerPage({super.key});

  @override
  State<ProjectManagerPage> createState() => _ProjectManagerPageState();
}

class _ProjectManagerPageState extends State<ProjectManagerPage> {
  List<Employee> employees = <Employee>[];

  late EmployeeDataSource employeeDataSource;

  @override
  void initState() {
    super.initState();
    employees = getEmployees();
    employeeDataSource = EmployeeDataSource(employees: employees);
  }

  List<Employee> getEmployees() {
    return [
      Employee(1, 'James', 'Project Lead', 20000),
      Employee(2, 'Kathryn', 'Manager', 30000),
      Employee(3, 'Lara', 'Developer', 15000),
      Employee(4, 'Michael', 'Designer', 15000),
      Employee(5, 'Martin', 'Developer', 15000),
      Employee(6, 'Newberry', 'Developer', 15000),
      Employee(7, 'Balnc', 'Developer', 15000),
      Employee(8, 'Perry', 'Developer', 15000),
      Employee(9, 'Gable', 'Developer', 15000),
      Employee(10, 'Grimes', 'Developer', 15000),
      Employee(11, 'James', 'Project Lead', 20000),
      Employee(12, 'Kathryn', 'Manager', 30000),
      Employee(13, 'Lara', 'Developer', 15000),
      Employee(14, 'Michael', 'Designer', 15000),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      borderColor: Colors.transparent,
      backgroundColor: Colors.green.withOpacity(.05),
      borderRadius: BorderRadius.circular(5),
      margin: const EdgeInsets.all(15),
      child: SfDataGrid(
        columnWidthMode: ColumnWidthMode.lastColumnFill,
        autoExpandGroups: true,
        allowExpandCollapseGroup: true,
        source: employeeDataSource,
        rowsPerPage: 10,
        allowSorting: true,
        columns: <GridColumn>[
          GridColumn(
              columnName: 'id',
              label: Container(
                  padding: const EdgeInsets.all(16.0),
                  alignment: Alignment.centerRight,
                  child: const Text(
                    'ID',
                  ))),
          GridColumn(
              columnName: 'name',
              label: Container(
                  padding: const EdgeInsets.all(16.0),
                  alignment: Alignment.centerLeft,
                  child: const Text('Name'))),
          GridColumn(
              columnName: 'designation',
              width: 120,
              label: Container(
                  padding: const EdgeInsets.all(16.0),
                  alignment: Alignment.centerLeft,
                  child: const Text('Designation'))),
          GridColumn(
              columnName: 'salary',
              label: Container(
                  padding: const EdgeInsets.all(16.0),
                  alignment: Alignment.centerRight,
                  child: const Text('Salary'))),
        ],
      ),
    );
  }
}
