import 'package:fluent_ui/fluent_ui.dart';
import 'package:hank_pack_master/comm/toast_util.dart';
import 'package:hank_pack_master/comm/upload_platforms.dart';
import 'package:hank_pack_master/hive/env_group/env_group_operator.dart';
import 'package:hank_pack_master/hive/project_record/project_record_entity.dart';
import 'package:hank_pack_master/ui/work_shop/work_shop_vm.dart';

import '../../../comm/text_util.dart';
import '../../../comm/ui/form_input.dart';
import '../../../comm/url_check_util.dart';
import '../../../hive/env_group/env_check_result_entity.dart';

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

  final TextEditingController _updateLogController = TextEditingController();
  final TextEditingController _mergeBranchNameController =
      TextEditingController();

  final TextEditingController _apkLocationController = TextEditingController();

  String? _selectedOrder;

  UploadPlatform? _selectedUploadPlatform;

  EnvCheckResultEntity? jdk; // 当前使用的jdk版本

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
              Text(title,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.w600)),
              mustSpace
            ])),
        Expanded(
          child: Row(
            children: List.generate(uploadPlatforms.length, (index) {
              return Padding(
                padding: const EdgeInsets.only(right: 18.0),
                child: RadioButton(
                    checked: index == _selectedUploadPlatform?.index,
                    content: Text(
                      uploadPlatforms[index].name,
                      style: const TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 18),
                    ),
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
          String appUpdateStr = _updateLogController.text;
          List<String> mergeBranchList = _mergeBranchNameController.text
              .trim()
              .split("\n")
              .map((e) => e.trim())
              .toList();
          mergeBranchList.removeWhere((e) => e.trim().isEmpty);

          String apkLocation = _apkLocationController.text;
          String? selectedOrder = _selectedOrder;
          UploadPlatform? selectedUploadPlatform = _selectedUploadPlatform;

          // 将此任务添加到队列中去
          widget.projectRecordEntity.setting = PackageSetting(
            appUpdateLog: appUpdateStr,
            apkLocation: apkLocation,
            selectedOrder: selectedOrder,
            selectedUploadPlatform: selectedUploadPlatform,
            jdk: jdk,
            mergeBranchList: mergeBranchList,
          );

          String errMsg = widget.projectRecordEntity.setting!.readyToPackage();
          if (errMsg.isNotEmpty) {
            setState(() => _errMsg = errMsg);
            return;
          }

          var success = widget.workShopVm.enqueue(widget.projectRecordEntity);
          if (success) {
            Navigator.pop(context);
            widget.goToWorkShop?.call();
          } else {
            ToastUtil.showPrettyToast('打包任务入列失败,发现重复任务');
          }
        });
    var cancelActionBtn = OutlinedButton(
        child: const Text("取消"), onPressed: () => Navigator.pop(context));

    // 弹窗
    var contentWidget = Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          input("更新日志", "输入更新日志...", _updateLogController,
              maxLines: 4,
              must: true,
              crossAxisAlignment: CrossAxisAlignment.center),
          input("合并分支", "输入打包前要合入的其他分支名...", _mergeBranchNameController,
              // 这些分支貌似不应该手动填，而是选择 TODO
              maxLines: 3,
              must: false,
              toolTip: "注意：多个分支换行为分隔",
              crossAxisAlignment: CrossAxisAlignment.center),
          choose('打包命令', enableAssembleMap, setSelectedOrder: (order) {
            // 命令内容形如：assembleGoogleUat
            // 那就提取出 assemble后面的第一个单词，并将它转化为小写
            var apkChildFolder = extractFirstWordAfterAssemble(order);
            // 同时设置默认的apk路径
            _apkLocationController.text =
                'app\\build\\outputs\\apk\\$apkChildFolder';
            _selectedOrder = order;
            setState(() {});
          }, selected: _selectedOrder),
          const SizedBox(height: 5),
          input("apk路径", "程序会根据此路径检测apk文件", _apkLocationController,
              maxLines: 1),
          chooseRadio('上传方式'),
          javaHomeChoose(),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(_errMsg,
                  style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.w600,
                      fontSize: 16)),
              const SizedBox(width: 10),
              confirmActionBtn,
              const SizedBox(width: 10),
              cancelActionBtn,
            ],
          )
        ]);

    return contentWidget;
  }

  Widget javaHomeChoose() {
    List<EnvCheckResultEntity> jdks = []; // 这里的数据应该从

    var find = EnvGroupOperator.find("java");
    if (find != null && find.envValue != null) {
      jdks = find.envValue!.toList();
    }

    Widget mustSpace = SizedBox(
        width: 20,
        child: Center(
            child: Text(
          '*',
          style: TextStyle(fontSize: 18, color: Colors.red),
        )));

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 0),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        SizedBox(
            width: 100,
            child: Row(children: [
              const Text("JavaHome",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
              mustSpace
            ])),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: List.generate(jdks.length, (index) {
              return Padding(
                padding: const EdgeInsets.only(right: 18.0, bottom: 10),
                child: RadioButton(
                    checked: jdk == jdks[index],
                    content: Text(
                      jdks[index].envName,
                      style: const TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 18),
                      overflow: TextOverflow.ellipsis,
                    ),
                    onChanged: (checked) {
                      if (checked == true) {
                        setState(() {
                          jdk = jdks[index];
                          debugPrint("当前使用的jdk是 ${jdk?.envPath}");
                        });
                      }
                    }),
              );
            }),
          ),
        )
      ]),
    );
  }
}
