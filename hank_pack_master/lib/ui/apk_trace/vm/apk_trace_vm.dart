import 'package:cross_file/cross_file.dart';
import 'package:desktop_drop/desktop_drop.dart';
import 'package:file_picker/file_picker.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:hank_pack_master/comm/file_ext.dart';
import 'package:hank_pack_master/comm/text_util.dart';
import 'package:hank_pack_master/hive/project_record/project_record_operator.dart';

import '../../../comm/comm_font.dart';
import '../../../comm/toast_util.dart';
import '../../../hive/project_record/job_history_entity.dart';

typedef TraceResShownFunc = void Function(List<JobHistoryEntity> s);

class ApkTraceVm extends ChangeNotifier {
  XFile? selectedFile;
  bool dragging = false;
  bool tracing = false;

  late TraceResShownFunc traceResShownFunc;

  ApkTraceVm({required TraceResShownFunc func}) {
    traceResShownFunc = func;
  }

  final textStyle1 = const TextStyle(
      fontSize: 22, fontWeight: FontWeight.w600, fontFamily: commFontFamily);

  final textStyle2 = const TextStyle(
      fontSize: 30, fontWeight: FontWeight.w600, fontFamily: commFontFamily);

  void onDragDone(DropDoneDetails details) {
    if (details.files.isEmpty) {
      ToastUtil.showPrettyToast('没有选择任何文件', success: false);
    } else if (details.files.length > 1) {
      ToastUtil.showPrettyToast('仅支持选择单个文件', success: false);
    } else {
      selectedFile = details.files[0];
    }
    doTrace();
    notifyListeners();
  }

  void onDragEntered(DropEventDetails details) {
    dragging = true;
    notifyListeners();
  }

  onDragExited(DropEventDetails details) {
    dragging = false;
    notifyListeners();
  }

  void clearFile() {
    selectedFile = null;
    notifyListeners();
  }

  void onFileSelected(PlatformFile f) {
    selectedFile = XFile(f.path!);
    notifyListeners();
    doTrace();
  }

  Future showLoading() async {
    tracing = true;
    notifyListeners();
  }

  void hideLoading() {
    tracing = false;
    notifyListeners();
  }

  List<JobHistoryEntity> findMd5List = [];

  Future find() async {
    List<JobHistoryEntity> list = ProjectRecordOperator.findALlHis();
    String thisMd5 = await selectedFile!.md5();
    findMd5List = list.where((e) => e.md5 == thisMd5).toList();
  }

  Future wait3S() async {
    await Future.delayed(const Duration(milliseconds: 500));
  }

  /// 执行追踪动作
  void doTrace() async {
    showLoading();
    await Future.wait([find(), wait3S()]);
    hideLoading();
    traceResShownFunc.call(findMd5List);
  }

  void doFileChoose() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['apk'],
    );

    if (result != null) {
      var f = result.files.single;
      debugPrint('选择了 $f');
      if (!f.path.empty()) {
        onFileSelected(f);
      }
    }
  }
}
