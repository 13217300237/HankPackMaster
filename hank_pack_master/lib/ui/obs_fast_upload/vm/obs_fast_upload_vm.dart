import 'package:cross_file/cross_file.dart';
import 'package:desktop_drop/desktop_drop.dart';
import 'package:file_picker/file_picker.dart';
import 'package:fluent_ui/fluent_ui.dart';

import '../../../comm/toast_util.dart';

class FastObsUploadVm extends ChangeNotifier {
  XFile? selectedFile;
  bool dragging = false;
  bool uploading = false;

  Color btnColor = Colors.orange;

  void onMouseExit(){
    btnColor = Colors.orange;
    notifyListeners();
  }

  void onMouseEnter(){
    btnColor = Colors.orange.lightest;
    notifyListeners();
  }


  final textStyle1 = const TextStyle(
      fontSize: 22, fontWeight: FontWeight.w600, fontFamily: 'STKAITI');

  final textStyle2 = const TextStyle(
      fontSize: 30, fontWeight: FontWeight.w600, fontFamily: 'STKAITI');

  void onDragDone(DropDoneDetails details){
    if (details.files.isEmpty) {
      ToastUtil.showPrettyToast('没有选择任何文件', success: false);
    } else if (details.files.length > 1) {
      ToastUtil.showPrettyToast('仅支持选择单个文件', success: false);
    } else {
      selectedFile = details.files[0];
    }
    notifyListeners();
  }

  void onDragEntered(DropEventDetails details){
    dragging = true;
    notifyListeners();
  }

  onDragExited(DropEventDetails details){
    dragging = false;
    notifyListeners();
  }

  void clearFile() {
    selectedFile = null;
    notifyListeners();
  }

  void onFileSelected(PlatformFile f){
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

}

extension XFileExt on XFile {
  Future<List<String>> detail() async {
    List<String> res = [];

    res.add('文件路径： ${this.path} ');
    res.add('文件名：$name');
    res.add('文件大小：${(await length() / 1024 / 1024).toStringAsPrecision(2)} MB');
    res.add(
        '最后修改时间：${Jiffy.parseFromDateTime(await lastModified()).format(pattern: 'yyyy-MM-dd HH:mm:ss')}');

    return res;
  }
}
