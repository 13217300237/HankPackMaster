import 'dart:io';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:hank_pack_master/comm/dialog_util.dart';
import 'package:hank_pack_master/comm/toast_util.dart';
import 'package:hank_pack_master/hive/env_group/env_group_operator.dart';
import 'package:hank_pack_master/hive/project_record/project_record_entity.dart';
import 'package:hank_pack_master/hive/project_record/upload_platforms.dart';
import 'package:hank_pack_master/ui/work_shop/work_shop_vm.dart';

import '../../../comm/comm_font.dart';
import '../../../comm/str_const.dart';
import '../../../comm/text_util.dart';
import '../../../comm/ui/form_input.dart';
import '../../../comm/upload_platforms.dart';
import '../../../core/command_util.dart';
import '../../../hive/env_config/env_config_operator.dart';
import '../../../hive/env_group/env_check_result_entity.dart';
import '../../../hive/project_record/package_setting_entity.dart';
import '../../../hive/project_record/project_record_operator.dart';

class StartPackageDialogWidget extends StatefulWidget {
  final WorkShopVm workShopVm;

  final List<String> enableAssembleOrders;
  final ProjectRecordEntity projectRecordEntity;
  final EnvCheckResultEntity javaHome;

  final Function? goToWorkShop;

  const StartPackageDialogWidget({
    super.key,
    required this.projectRecordEntity,
    required this.workShopVm,
    required this.enableAssembleOrders,
    this.goToWorkShop,
    required this.javaHome,
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

  final TextEditingController _apkLocationController = TextEditingController();

  String? _selectedOrder;

  UploadPlatform? _selectedUploadPlatform;

  EnvCheckResultEntity? _jdk; // 当前使用的jdk版本

  String get projectName {
    var gitText = widget.projectRecordEntity.gitUrl;
    var lastSepIndex = gitText.lastIndexOf("/");
    var endIndex = gitText.length - 4;
    assert(endIndex > 0);
    String projectName = gitText.substring(lastSepIndex + 1, endIndex);
    return projectName;
  }

  String get gitBranch {
    return widget.projectRecordEntity.branch;
  }

  @override
  void initState() {
    super.initState();
    _jdk = widget.javaHome; // 这里必须使用 激活时使用的jdk
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      initSetting(widget.projectRecordEntity.packageSetting);
      String projectWorkDir =
          EnvConfigOperator.searchEnvValue(Const.envWorkspaceRootKey) +
              Platform.pathSeparator +
              projectName +
              Platform.pathSeparator +
              Uri.encodeComponent(gitBranch) +
              Platform.pathSeparator +
              projectName +
              Platform.pathSeparator; // 总目录\项目名\分支名\项目名

      debugPrint("命令执行根目录为:$projectWorkDir");

      // showLoading 正在获取
      EasyLoading.show(
          status: '正在获取远程分支状态...',
          dismissOnTap: false,
          maskType: EasyLoadingMaskType.black);
      CommandUtil.getInstance()
          .gitBranchRemote(projectWorkDir, (s) {})
          .then((s) {
        String commandsStr = s.res;

        List<String> commands = commandsStr.split("\n");

        String originTag = "origin/";

        commands.removeWhere((e) => e.contains("${originTag}HEAD"));
        commands.removeWhere((e) =>
            Uri.encodeComponent(e.trim()) ==
            Uri.encodeComponent('$originTag$gitBranch'));

        for (var s in commands) {
          var sx = s.substring(s.indexOf(originTag) + originTag.length);
          _branchList[sx] = false;
        }

        initSetting(widget.projectRecordEntity.packageSetting);
        EasyLoading.dismiss(animation: true);
      });
    });
  }

  void initSetting(PackageSetting? packageSetting) {
    if (packageSetting == null) {
      return;
    }

    packageSetting.mergeBranchList?.forEach((e) {
      _branchList[e] = true;
    });

    // _mergeBranchNameController.text = sb.toString().trim();
    _selectedOrder = packageSetting.selectedOrder;
    _selectedUploadPlatform = packageSetting.selectedUploadPlatform;
    _apkLocationController.text = packageSetting.apkLocation ?? '';
    _jdk = packageSetting.jdk;

    if (mounted) {
      setState(() {});
    }
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
                      uploadPlatforms[index].name!,
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

  final Map<String, bool> _branchList = {};

  List<String> get _selectedToMergeBranch {
    List<String> selected = [];
    _branchList.forEach((key, value) {
      if (value == true) {
        selected.add(key);
      }
    });
    return selected;
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
          // 收集信息,并返回出去
          String appUpdateStr = _updateLogController.text;
          String apkLocation = _apkLocationController.text;
          String? selectedOrder = _selectedOrder;
          UploadPlatform? selectedUploadPlatform = _selectedUploadPlatform;

          // 将此任务添加到队列中去
          widget.projectRecordEntity.packageSetting =
              widget.projectRecordEntity.settingToWorkshop = PackageSetting(
            appUpdateLog: appUpdateStr,
            apkLocation: apkLocation,
            selectedOrder: selectedOrder,
            selectedUploadPlatform: selectedUploadPlatform,
            jdk: _jdk,
            mergeBranchList: _selectedToMergeBranch,
          );
          ProjectRecordOperator.update(widget.projectRecordEntity);

          String errMsg =
              widget.projectRecordEntity.settingToWorkshop!.readyToPackage();
          if (errMsg.isNotEmpty) {
            setState(() => _errMsg = errMsg);
            return;
          }

          var success = widget.workShopVm.enqueue(widget.projectRecordEntity);
          Navigator.pop(context);
          if (success) {
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
              must: false,
              crossAxisAlignment: CrossAxisAlignment.center),
          _branchMergeWidget(),
          Row(
            children: [
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
            ],
          ),
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

  _branchMergeWidget() {
    showDialog() {
      DialogUtil.showCustomDialog(
        context: context,
        title: '可选分支',
        maxHeight: 600,
        maxWidth: 900,
        content: BranchListLayout(branchList: _branchList),
        showActions: false,
      ).then((value) => setState(() {}));
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
              width: 100,
              child: Row(children: [
                FilledButton(
                  onPressed: showDialog,
                  child: const Text(
                    "合并分支",
                    style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        fontFamily: commFontFamily,
                        color: Colors.white),
                  ),
                ),
              ])),
          Expanded(
            child: Container(
              constraints: const BoxConstraints(maxHeight: 200),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      children: [
                        ..._selectedToMergeBranch.map((e) => GestureDetector(
                              onTap: showDialog,
                              child: Card(
                                margin:
                                    const EdgeInsets.only(right: 10, bottom: 5),
                                backgroundColor: Colors.blue,
                                child: Text(
                                  e,
                                  style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      fontFamily: commFontFamily,
                                      color: Colors.white),
                                ),
                              ),
                            )),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class BranchListLayout extends StatefulWidget {
  final Map<String, bool> branchList;

  const BranchListLayout({super.key, required this.branchList});

  @override
  State<BranchListLayout> createState() => _BranchListLayoutState();
}

class _BranchListLayoutState extends State<BranchListLayout> {
  // 记住刚刚传进来的 branchList,因为点取消的时候要还原
  late Map<String, bool> old;

  final _textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    old = {};
    old.addAll(widget.branchList);

    debugPrint("length->${widget.branchList.length}");

    _textController.addListener(() {
      setState(() {});
    });
  }

  var textStyle = const TextStyle(
      decoration: TextDecoration.none,
      fontSize: 15,
      height: 1.5,
      fontWeight: FontWeight.w600,
      color: Colors.white,
      fontFamily: commFontFamily);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Wrap(
              children: [
                ...widget.branchList.keys.toList().map(
                      (e) => Visibility(
                        visible: _textController.text.isEmpty
                            ? true
                            : e.contains(_textController.text),
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              widget.branchList[e] = !widget.branchList[e]!;
                            });
                          },
                          child: Card(
                            margin: const EdgeInsets.all(5),
                            backgroundColor: widget.branchList[e]!
                                ? Colors.blue
                                : Colors.white,
                            child: Text(
                              e,
                              style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  fontFamily: commFontFamily,
                                  color: widget.branchList[e]!
                                      ? Colors.white
                                      : Colors.black),
                            ),
                          ),
                        ),
                      ),
                    )
              ],
            ),
          ),
        ),
        const SizedBox(height: 18),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Expanded(
              child: TextBox(
                padding: const EdgeInsets.all(10),
                controller: _textController,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: const Color(0xff3c8981),
                    border: Border.all(color: Colors.transparent, width: 1.35)),
                unfocusedColor: Colors.transparent,
                highlightColor: Colors.transparent,
                style: textStyle,
                cursorColor: Colors.white,
                placeholder: '输入过滤关键字',
                placeholderStyle: textStyle.copyWith(color: Colors.white),
                expands: false,
                maxLines: 1,
                enabled: true,
                suffix: _textController.text.isEmpty
                    ? null
                    : Padding(
                        padding: const EdgeInsets.only(right: 10.0),
                        child: IconButton(
                          icon: const Icon(FluentIcons.clear,
                              color: Colors.white, size: 20),
                          onPressed: _textController.clear,
                        ),
                      ),
              ),
            ),
            const SizedBox(width: 90),
            OutlinedButton(
              child: const Text('取消',
                  style: TextStyle(fontSize: 22, fontFamily: commFontFamily)),
              onPressed: () {
                widget.branchList.clear();
                widget.branchList.addAll(old);
                Navigator.pop(context);
              },
            ),
            const SizedBox(width: 10),
            FilledButton(
              child: const Text('确定',
                  style: TextStyle(fontSize: 22, fontFamily: commFontFamily)),
              onPressed: () => Navigator.pop(context),
            )
          ],
        )
      ],
    );
  }
}
