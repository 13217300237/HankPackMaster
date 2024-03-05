import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:hank_pack_master/comm/text_util.dart';
import 'package:hank_pack_master/comm/toast_util.dart';
import 'package:hank_pack_master/hive/env_group/env_check_result_entity.dart';
import 'package:hank_pack_master/hive/env_group/env_group_entity.dart';
import 'package:hank_pack_master/hive/env_group/env_group_operator.dart';
import 'package:hank_pack_master/ui/env/hover_container.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/command_util.dart';
import '../comm/theme.dart';
import '../comm/vm/env_param_vm.dart';

///
/// 单独封装一个带动画特效的环境监测卡片
///
/// 1，执行where命令，找出 所有可执行文件的路径 (Done)
/// 2. 逐个进行java指令的 version执行，看看版本号
/// 3. 将执行的结果动态显示出来
/// 4. 用单选框展示，默认选中第一个
///
class EnvGroupCard extends StatefulWidget {
  final String order;
  final String orderUse;
  final String? downloadUrl;

  const EnvGroupCard(
      {super.key,
      required this.order,
      this.downloadUrl,
      required this.orderUse});

  @override
  State<EnvGroupCard> createState() => _EnvGroupCardState();
}

class _EnvGroupCardState extends State<EnvGroupCard> {
  late AppTheme _appTheme;
  late EnvParamVm _envParamModel;
  List<String> whereRes = [];

  bool showInfo = true;

  /// 是否正在加载 环境group
  bool _isEnvGroupLoading = false;

  @override
  Widget build(BuildContext context) {
    _envParamModel = context.watch<EnvParamVm>();
    _appTheme = context.watch<AppTheme>();

    return _createDynamicEnvCheckCard();
  }

  /// 带动态效果的环境监测卡片
  Widget _createDynamicEnvCheckCard() {
    return Row(children: [
      Expanded(
        child: Card(
            backgroundColor: _appTheme.bgColorSucc,
            margin: const EdgeInsets.all(8),
            borderRadius: BorderRadius.circular(5),
            borderColor: Colors.transparent,
            child: _buildEnvRadioBtn(
                widget.order, widget.downloadUrl, whereRes.toSet())),
      )
    ]);
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance
        .addPostFrameCallback((timeStamp) => _doWhereAction());
  }

  /// 可执行文件单选按钮组件
  Widget _buildEnvRadioBtn(
      String order, String? downloadUrl, Set<String> content) {
    List<Widget> muEnv = [];

    double cardWidth = 400;
    double cardHeight = 100;

    for (var binRoot in content) {
      Color bgColor = Colors.blue.withOpacity(.15);
      Color borderColor = Colors.transparent;
      IconData icon = FluentIcons.checkbox;
      if (_envParamModel.judgeEnv(order, binRoot)) {
        bgColor = Colors.green.withOpacity(.2);
        borderColor = Colors.green.withOpacity(.4);
        icon = FluentIcons.skype_check;
      }

      muEnv.add(HoverContainer(
        child: Card(
          borderColor: borderColor,
          backgroundColor: bgColor,
          borderRadius: BorderRadius.circular(5),
          padding: const EdgeInsets.all(0),
          child: GestureDetector(
            onTap: () =>
                _envParamModel.setEnv(order, binRoot, needToOverride: true),
            child: Container(
              padding: const EdgeInsets.only(
                  left: 10.0, bottom: 10, right: 10, top: 0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        _titleWidget(binRoot, cardWidth),
                        const SizedBox(width: 20),
                        EnvCheckWidget(
                            order: widget.order,
                            envPath: binRoot,
                            title: order,
                            cardWidth: cardWidth,
                            cardHeight: cardHeight),
                      ]),
                  const SizedBox(width: 10),
                  Icon(icon, size: 30, color: Colors.grey[180]),
                ],
              ),
            ),
          ),
        ),
      ));
    }

    return _card(order, muEnv);
  }

  Widget _titleWidget(String binRoot, double cardWidth) {
    return Container(
      width: cardWidth,
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Tooltip(
        message: binRoot,
        style: const TooltipThemeData(
            textStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
        triggerMode: TooltipTriggerMode.manual,
        child: Text(
          binRoot,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }

  Widget _card(String title, List<Widget> muEnv) {

    var listViewScroller = ScrollController();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Text(title,
                    style: const TextStyle(
                        fontSize: 30, fontWeight: FontWeight.w600)),
                const SizedBox(width: 20),
                if (widget.downloadUrl != null &&
                    widget.downloadUrl!.isNotEmpty)
                  Tooltip(
                    message: "点击进入下载地址",
                    child: IconButton(
                      onPressed: () async {
                        await launchUrl(
                            Uri.parse(widget.downloadUrl!)); // 通过资源管理器打开该目录
                      },
                      icon: Icon(
                        FluentIcons.cloud_link,
                        size: 30,
                        color: Colors.blue,
                      ),
                    ),
                  ),
              ],
            ),
            FilledButton(
              onPressed: () async {
                FilePickerResult? result = await FilePicker.platform.pickFiles(
                  type: FileType.custom,
                  allowedExtensions: ['exe', 'bat'],
                );

                if (result != null) {
                  String? path = result.files.single.path;
                  debugPrint('选择了 $path');
                  if (path != null && path.isNotEmpty && path.contains(title)) {
                    saveEnvPath(path);
                  } else {
                    ToastUtil.showPrettyToast("只能选择 $title.exe 或者 $title.bat");
                  }
                }
              },
              child: const Row(
                children: [
                  Icon(FluentIcons.check_list_text, size: 28),
                  SizedBox(width: 10),
                  Text(
                    "手动添加",
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 15),
        _infoWidget(),
        const SizedBox(height: 15),
        if (!_isEnvGroupLoading) ...[
          SizedBox(
            width: double.infinity,
            height: 228,
            child: Scrollbar(
              thumbVisibility: false,
              interactive: true,
              style: const ScrollbarThemeData(
                thickness: 8,
                // 设置滚动条的宽度
                radius: Radius.circular(10),
                hoveringThickness: 10,
                padding: EdgeInsets.all(5),
              ),
              controller: listViewScroller,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 28.0),
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  controller: listViewScroller,
                  children: [...muEnv],
                ),
              ),
            ),
          ),
        ] else ...[
          const ProgressBar(),
        ],
      ],
    );
  }

  Widget _infoWidget() {
    if (showInfo) {
      return Container(
        margin: const EdgeInsets.only(left: 5),
        child: InfoBar(
          title: const Text(
            '提示',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          content: SizedBox(
            width: double.infinity,
            child: Text('${widget.order}环境变量将用于${widget.orderUse}',
                style:
                    const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
          ),
          severity: InfoBarSeverity.info,
          isLong: true,
          onClose: () => setState(() => showInfo = false),
        ),
      );
    } else {
      return const SizedBox();
    }
  }

  bool hasExecutableExtension(String path) {
    var extensions = ['.exe', '.bat', '.cmd'];

    bool has = false;

    for (var element in extensions) {
      if (path.toLowerCase().endsWith(element)) {
        has = true;
        break;
      }
    }

    return has;
  }

  /// 保存/更新 环境变量，并刷新UI
  void saveEnvPath(String envPath) {
    // 过滤掉 不带可执行后缀的
    // 过滤掉重复的
    if (!hasExecutableExtension(envPath)) {
      return;
    }

    var find = EnvGroupOperator.find(widget.order);
    find ??= EnvGroupEntity(envGroupName: widget.order); // 保证 find 非空
    var envCheckResultEntityList = find.envValue; // 那就看检查结果
    envCheckResultEntityList ??= []; // 保证list非空

    // 这里必须保证同样的 envPath只被添加一次
    var i = envCheckResultEntityList.indexWhere((e) => e.envPath == envPath);
    if (i != -1) {
      envCheckResultEntityList.removeAt(i);
    }
    envCheckResultEntityList
        .add(EnvCheckResultEntity(envPath: envPath, envName: envPath));

    find.envValue = envCheckResultEntityList;
    EnvGroupOperator.insertOrUpdate(find);

    setState(() {
      whereRes.clear();
      find = EnvGroupOperator.find(widget.order);
      if (find != null) {
        find!.envValue?.forEach((e) {
          whereRes.add(e.envPath);
        });
      }
    });
  }

  String getFirstFromWhereRes() {
    if (whereRes.isNotEmpty) {
      return whereRes[0];
    }
    return "";
  }

  /// 初始化
  void _doWhereAction() async {
    _isEnvGroupLoading = true;

    /// 执行where命令
    CommandUtil.getInstance().whereCmd(
        order: widget.order,
        action: (s) {
          _isEnvGroupLoading = false;
          var split = s.trim().split("\n");
          for (var e in split) {
            e = e.trim();
            if (!judgeFlutterGit(e)) {
              saveEnvPath(e);
            }
          }
        });
  }

  /// 有个奇怪情况，flutterSDK自带git工具，但是并不是我手动安装的git，最好不要选，要将他排除在外
  bool judgeFlutterGit(String path) {
    if (path.contains("git.exe") &&
        path.contains("flutter${Platform.pathSeparator}bin")) {
      return true;
    } else {
      return false;
    }
  }

  Widget envErrWidget(String title) {
    if (_envParamModel.isEnvEmpty(title)) {
      return Text("${_envParamModel.envGuide[title]}",
          style: TextStyle(fontSize: 20, color: Colors.red));
    } else {
      return const SizedBox();
    }
  }
}

class EnvCheckWidget extends StatefulWidget {
  final String order;
  final String envPath;
  final String title;
  final double cardWidth;
  final double cardHeight;

  const EnvCheckWidget({
    super.key,
    required this.envPath,
    required this.title,
    required this.cardWidth,
    required this.cardHeight,
    required this.order,
  });

  @override
  State<EnvCheckWidget> createState() => _EnvCheckWidgetState();
}

class _EnvCheckWidgetState extends State<EnvCheckWidget> {
  String executeRes = "";

  bool get _executing => executeRes.isEmpty;

  void _envTestCheck(String binRoot) async {
    EnvGroupEntity? find = EnvGroupOperator.find(widget.order);

    if (find == null) {
      // 主命令查询结果为空
      return;
    }

    var index = find.envValue?.indexWhere((e) => e.envPath == widget.envPath);

    if (index == null) {
      // 没有任何子命令
      return;
    }

    if (index == -1) {
      // 存在子命令，但是并没有与当前 envPath匹配的
      return;
    }

    // 检查当前这条命令的检查结果是否为空
    var currentCheckResult = find.envValue![index].envCheckResult;
    if (currentCheckResult == null || currentCheckResult.isEmpty) {
      executeRes = await CommandUtil.getInstance().checkVersion(binRoot);
      find.envValue![index].envCheckResult = executeRes;
      find.envValue![index].envName =
          executeRes.getFirstLine() ?? ""; // 把结论的第一行作为envName
      EnvGroupOperator.insertOrUpdate(find); // 找不到执行结果，才进行更新
    } else {
      // 找到了执行结果，直接进行赋值
      executeRes = currentCheckResult;
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (_executing) {
      return SizedBox(
        width: widget.cardWidth,
        height: widget.cardHeight,
        child: const Center(child: ProgressRing()),
      );
    }

    return SizedBox(
      width: widget.cardWidth,
      height: widget.cardHeight,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              executeRes,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance
        .addPostFrameCallback((timeStamp) => _envTestCheck(widget.envPath));
  }
}
