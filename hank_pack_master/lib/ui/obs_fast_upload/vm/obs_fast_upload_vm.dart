import 'dart:io';

import 'package:hank_pack_master/comm/text_util.dart';
import 'package:cross_file/cross_file.dart';
import 'package:desktop_drop/desktop_drop.dart';
import 'package:file_picker/file_picker.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:hank_pack_master/hive/fast_obs_upload/fast_obs_upload_entity.dart';
import 'package:hank_pack_master/hive/fast_obs_upload/fast_obs_upload_operator.dart';
import 'package:jiffy/jiffy.dart';
import 'package:hank_pack_master/comm/text_util.dart';
import '../../../comm/hwobs/obs_client.dart';
import '../../../comm/toast_util.dart';

class FastObsUploadVm extends ChangeNotifier {
  XFile? selectedFile;
  bool dragging = false;
  bool uploading = false;

  Color btnColor = Colors.orange;

  int expiredDays = 7;

  void onMouseExit() {
    btnColor = Colors.orange;
    notifyListeners();
  }

  void onMouseEnter() {
    btnColor = Colors.orange.lightest;
    notifyListeners();
  }

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

  void doUpload({
    required Function(String msg, TextStyle textStyle) showFailedDialog,
    required Function(String msg, TextStyle textStyle) showSuccessDialog,
  }) async {
    showLoading();
    // 执行上传动作
    OBSResponse? oBSResponse = await OBSClient.putFile(
      objectName:
          "${OBSClient.commonUploadFolder}/fastUpload/${Jiffy.now().format(pattern: "yyyyMMdd_HHmmss")}/${Uri.encodeComponent(selectedFile!.name)}",
      file: File(selectedFile!.path),
      expiresDays: expiredDays, // 设置过期时间(天)，超过了之后会被自动删除
    );

    hideLoading();

    String? obsDownloadUrl = oBSResponse?.url;

    if (obsDownloadUrl == null || obsDownloadUrl.isEmpty) {
      showFailedDialog('${oBSResponse!.errMsg}', textStyle1);
    } else {
      // 弹窗，显示上传结果的二维码
      showSuccessDialog(obsDownloadUrl, textStyle1);

      FastObsUploadOperator.insert(FastObsUploadEntity(
          selectedFile!.path,
          selectedFile!.name,
          await selectedFile!.length(),
          await selectedFile!.lastModified(),
          DateTime.now(),
          expiredDays,
          obsDownloadUrl,
          DateTime.now().add(Duration(days: expiredDays))));
      clearFile();
    }
  }

  void doFileChoose() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['*'],
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

extension XFileExt on XFile {
  Future<List<String>> detail() async {
    List<String> res = [];

    res.add('文件路径： $path ');
    res.add('文件名：$name');
    res.add('文件大小：${(await length()).toMb()}');
    res.add(
        '最后修改时间：${(await lastModified()).formatYYYMMDDHHmmSS()}');

    return res;
  }
}

