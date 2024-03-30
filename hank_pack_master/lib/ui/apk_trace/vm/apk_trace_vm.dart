import 'dart:io';

import 'package:cross_file/cross_file.dart';
import 'package:desktop_drop/desktop_drop.dart';
import 'package:file_picker/file_picker.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:hank_pack_master/comm/text_util.dart';
import 'package:hank_pack_master/hive/fast_obs_upload/fast_obs_upload_entity.dart';
import 'package:hank_pack_master/hive/fast_obs_upload/fast_obs_upload_operator.dart';
import 'package:hank_pack_master/hive/project_record/project_record_operator.dart';
import 'package:jiffy/jiffy.dart';

import '../../../comm/hwobs/obs_client.dart';
import '../../../comm/toast_util.dart';
import '../../../hive/project_record/job_history_entity.dart';

class ApkTraceVm extends ChangeNotifier {
  XFile? selectedFile;
  bool dragging = false;
  bool uploading = false;

  final textStyle1 = const TextStyle(
      fontSize: 22, fontWeight: FontWeight.w600, fontFamily: 'STKAITI');

  final textStyle2 = const TextStyle(
      fontSize: 30, fontWeight: FontWeight.w600, fontFamily: 'STKAITI');

  void onDragDone(DropDoneDetails details) {
    if (details.files.isEmpty) {
      ToastUtil.showPrettyToast('没有选择任何文件', success: false);
    } else if (details.files.length > 1) {
      ToastUtil.showPrettyToast('仅支持选择单个文件', success: false);
    } else {
      selectedFile = details.files[0];
    }
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
  }

  void showLoading() {
    uploading = true;
    notifyListeners();
  }

  void hideLoading() {
    uploading = false;
    notifyListeners();
  }

  /// 执行追踪动作
  void doTrace({
    required Function(String msg, TextStyle textStyle) showFailedDialog,
    required Function(String msg, TextStyle textStyle) showSuccessDialog,
  }) async {
    showLoading();

    List<JobHistoryEntity> list = ProjectRecordOperator.findALlHis();

    hideLoading();
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
