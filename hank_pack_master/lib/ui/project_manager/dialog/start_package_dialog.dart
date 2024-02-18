
import 'package:fluent_ui/fluent_ui.dart';
import 'package:hank_pack_master/comm/toast_util.dart';
import 'package:hank_pack_master/comm/upload_platforms.dart';
import 'package:hank_pack_master/hive/project_record/project_record_entity.dart';
import 'package:hank_pack_master/ui/work_shop/work_shop_vm.dart';

import '../../../comm/ui/form_input.dart';
import '../../../comm/url_check_util.dart';

class StartPackageDialogWidget extends StatefulWidget {
  final WorkShopVm workShopVm;

  final List<String> enableAssembleOrders;
  final ProjectRecordEntity projectRecordEntity;

  final Function? goToWorkShop;

  const StartPackageDialogWidget({
    super.key,
    required this.projectRecordEntity,
    required this.workShopVm,
    required this.enableAssembleOrders,
    this.goToWorkShop,
  });

  @override
  State<StartPackageDialogWidget> createState() =>
      _StartPackageDialogWidgetState();
}

class _StartPackageDialogWidgetState extends State<StartPackageDialogWidget> {
  var isValidGitUrlRes = true;

  var textStyle = const TextStyle(fontSize: 18);
  var textMustStyle = TextStyle(fontSize: 18, color: Colors.red);

  var errStyle = TextStyle(fontSize: 16, color: Colors.red);

  final TextEditingController _projectAppDescController =
      TextEditingController();

  final TextEditingController _updateLogController = TextEditingController();

  final TextEditingController _apkLocationController = TextEditingController();

  String? _selectedOrder;

  UploadPlatform? _selectedUploadPlatform;

  @override
  void initState() {
    super.initState();
    _projectAppDescController.addListener(() {
      if (_projectAppDescController.text.isEmpty) {
        isValidGitUrlRes = true;
      } else {
        isValidGitUrlRes = isValidGitUrl(_projectAppDescController.text);
      }
      setState(() {});
    });
  }

  Widget chooseRadio(String title) {
    Widget mustSpace = SizedBox(
        width: 20,
        child: Center(
            child: Text(
          '*',
          style: TextStyle(fontSize: 18, color: Colors.red),
        )));

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 0),
      child: Row(children: [
        SizedBox(
            width: 100,
            child: Row(children: [
              Text(title, style: const TextStyle(fontSize: 18)),
              mustSpace
            ])),
        Expanded(
          child: Row(
            children: List.generate(uploadPlatforms.length, (index) {
              return Padding(
                padding: const EdgeInsets.only(right: 18.0),
                child: RadioButton(
                    checked: index == _selectedUploadPlatform?.index,
                    content: Text(uploadPlatforms[index].name),
                    onChanged: (checked) {
                      if (checked == true) {
                        _selectedUploadPlatform = uploadPlatforms[index];
                        setState(() {});
                      }
                    }),
              );
            }),
          ),
        )
      ]),
    );
  }


  String _errMsg = "";

  @override
  Widget build(BuildContext context) {
    Map<String, String> enableAssembleMap = {};
    for (var e in widget.enableAssembleOrders) {
      enableAssembleMap[e] = e;
    }

    var confirmActionBtn = FilledButton(
        child: const Text("确定"),
        onPressed: () {
          // 收集信息,并返回出去
          String appDescStr = _projectAppDescController.text;
          String appUpdateStr = _updateLogController.text;
          String apkLocation = _apkLocationController.text;
          String? selectedOrder = _selectedOrder;
          UploadPlatform? selectedUploadPlatform = _selectedUploadPlatform;

          // 将此任务添加到队列中去
          widget.projectRecordEntity.setting = PackageSetting(
            appDescStr: appDescStr,
            appUpdateStr: appUpdateStr,
            apkLocation: apkLocation,
            selectedOrder: selectedOrder,
            selectedUploadPlatform: selectedUploadPlatform,
          );

          String errMsg = widget.projectRecordEntity.setting!.ready();
          if (errMsg.isNotEmpty) {
            setState(() => _errMsg = errMsg);
            return;
          }

          var success = widget.workShopVm.enqueue(widget.projectRecordEntity);
          Navigator.pop(context);
          if (success) {
            widget.goToWorkShop?.call();
          } else {
            ToastUtil.showPrettyToast('入列失败,发现重复任务');
          }
        });
    var cancelActionBtn = OutlinedButton(
        child: const Text("取消"), onPressed: () => Navigator.pop(context));

    // 弹窗
    var contentWidget = Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          input("应用描述", "输入应用描述...", _projectAppDescController, maxLines: 5),
          input("更新日志", "输入更新日志...", _updateLogController, maxLines: 5),
          choose('打包命令', enableAssembleMap, setSelectedOrder: (order) {
            // 同时设置默认的apk路径
            if (order == 'assembleDebug') {
              _apkLocationController.text = 'app\\build\\outputs\\apk\\debug';
            } else if (order == 'assembleRelease') {
              _apkLocationController.text = 'app\\build\\outputs\\apk\\release';
            }
            _selectedOrder = order;
            setState(() {});
          }, selected: _selectedOrder),
          const SizedBox(height: 5),
          input("apk路径", "程序会根据此路径检测apk文件", _apkLocationController,
              maxLines: 1),
          chooseRadio('上传方式'),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(_errMsg, style: TextStyle(color: Colors.red)),
              const SizedBox(width: 10),
              confirmActionBtn,
              const SizedBox(width: 10),
              cancelActionBtn,
            ],
          )
        ]);

    return contentWidget;
  }
}
