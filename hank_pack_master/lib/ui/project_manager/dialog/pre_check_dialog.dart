import 'package:fluent_ui/fluent_ui.dart';
import 'package:hank_pack_master/comm/toast_util.dart';
import 'package:hank_pack_master/comm/upload_platforms.dart';
import 'package:hank_pack_master/hive/env_group/env_group_operator.dart';
import 'package:hank_pack_master/hive/project_record/project_record_entity.dart';
import 'package:hank_pack_master/ui/work_shop/work_shop_vm.dart';

import '../../../comm/ui/form_input.dart';
import '../../../comm/url_check_util.dart';
import '../../../hive/env_group/env_check_result_entity.dart';

class PreCheckDialogWidget extends StatefulWidget {
  final WorkShopVm workShopVm;

  final List<String> enableAssembleOrders;
  final ProjectRecordEntity projectRecordEntity;

  final Function? goToWorkShop;

  final String defaultJavaHome;

  const PreCheckDialogWidget({
    super.key,
    required this.projectRecordEntity,
    required this.workShopVm,
    required this.enableAssembleOrders,
    this.goToWorkShop,
    required this.defaultJavaHome,
  });

  @override
  State<PreCheckDialogWidget> createState() => _PreCheckDialogWidgetState();
}

class _PreCheckDialogWidgetState extends State<PreCheckDialogWidget> {
  EnvCheckResultEntity? _jdk; // 当前使用的jdk版本
  String _errMsg = "";

  @override
  void initState() {
    super.initState();
    _jdk = EnvCheckResultEntity(envPath: widget.defaultJavaHome, envName: '');
  }

  @override
  Widget build(BuildContext context) {
    Map<String, String> enableAssembleMap = {};
    for (var e in widget.enableAssembleOrders) {
      enableAssembleMap[e] = e;
    }

    var confirmActionBtn = FilledButton(
        child: const Text("确定"),
        onPressed: () {
          // 将此任务添加到队列中去
          widget.projectRecordEntity.setting = PackageSetting(jdk: _jdk);

          String errMsg = widget.projectRecordEntity.setting!.readyToActive();
          if (errMsg.isNotEmpty) {
            setState(() => _errMsg = errMsg);
            return;
          }

          var success = widget.workShopVm.enqueue(widget.projectRecordEntity);
          Navigator.pop(context);
          if (success) {
            widget.goToWorkShop?.call();
          } else {
            ToastUtil.showPrettyToast('激活任务入列失败,发现重复任务');
          }
        });
    var cancelActionBtn = OutlinedButton(
        child: const Text("取消"), onPressed: () => Navigator.pop(context));

    // 弹窗内容
    var contentWidget = Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _javaHomeChoose(),
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

  Widget _javaHomeChoose() {
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
                    checked: _jdk == jdks[index],
                    content: Text(
                      jdks[index].envName,
                      style: const TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 18),
                      overflow: TextOverflow.ellipsis,
                    ),
                    onChanged: (checked) {
                      if (checked == true) {
                        setState(() {
                          _jdk = jdks[index];
                          debugPrint("当前使用的jdk是 ${_jdk?.envPath}");
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
