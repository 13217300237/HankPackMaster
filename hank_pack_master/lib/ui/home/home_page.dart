import 'dart:convert';
import 'dart:io';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:hank_pack_master/core/command_util.dart';

import '../../comm/hwobs/obs_client.dart';
import '../../comm/ui/animation_widget.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String text = """
  # 这是什么？

这是一个由Flutter框架，dart语言编写的 PC桌面版应用，目前仅支持windows平台。

它诞生的目的是 为了简化安卓工程师日常工作中的一些繁琐步骤。

比如，当一个安卓工程师需要在多个 项目之间来回投入精力，或者一个项目的多个分支之间投入精力。更具体一点，我在项目A 的 a1分支上修改了代码，自测通过，下一步就是 将生成的apk包交给测试同学进行验证，而我们往往需要将包传到托管平台（或者网盘上）。

如果是单一项目的单一分支还好，但是日常情况却是，我们经常来回游走于多个功能分支，切来切去之后，慢慢的就发现就算我作为这个项目的主要开发者，也分不清刚才给出去的 apk包是哪个项目的哪个分支。

如果不对这种情况进行有效管理，久而久之，安卓工程师的精力就会消耗在这些无意义的流程中去。

这款PC软件名叫 “**安小助**”，它将作为安卓开发工程师的私人助手，有效管理自己负责的多个项目，以及多个项目的多个分支。

# 有什么主要功能模块？

**“安小助”** 的主要功能模块包括:

## 环境参数模块

一个安卓开发者往往需要安装androidSdk，jdk，git，adb 或者flutter 等开发环境。在这个模块中，**“安小助”** 会自动检测windows上已经安装的 java(也就是jdk)，git，adb，flutter 的版本，并检测其有效性，并支持 手动添加环境以应对自动检测不到的情况。

此外，**“安小助”** 还需要您设置 工作空间路径，作为 后续 **安小助** 进行项目管理的主要位置。

最后，您可能还需要设置 PGY平台的 apiKey （用于上传apk到蒲公英平台），或者设置 华为OBS平台的一些参数（以支持上传apk到华为OBS），PGY和OBS是目前支持的两种apk上传方案。

您可能还会看到 **阶段任务执行参数设置**, 这是打包工坊中用于单个阶段任务执行的相关参数，通常不需要修改。

---

## 工程管理模块

**“安小助”** 中，用 一个`gitUrl` 和 一个`branch`，唯一确定一个 **工程**。也就是说，相同的`gitUrl`，但是 `branch`不同，可以共存。这是为了满足 相同安卓项目的不同分支的管理需要。

确定一个**工程**之后，首先要对这个工程进行激活。激活的意思是，拉取这个`gitUrl`的指定`branch`代码，并且使用`gradle`命令尝试对它进行编译，并且得出它的所有`assemble`开头的可用命令。

激活完成之后，可以进行打包。打包时，必须选择 激活阶段产生的`assemble`命令中的某一个。并且提供 apk文件的检索路径（因为安卓项目通过gradle编程支持可以实现 更换apk的产出位置），本次打包的更新日志文案，以及上传平台（可选 华为obs平台 或者 蒲公英平台）。

所有工程将会在此模块的表格中进行呈现和管理。包括：工程激活和 工程 打包的进度。

## 打包工坊模块

这是重点模块，工程的激活，打包的详细情况都在这里呈现。

首先打包工坊中的左侧有一个等待队列，支持多个任务排队处理。

中间部分是 正在处理的任务的详细情况。包括：工程的名称，git地址，分支名，更新日志，打包命令，上传方式等。

打包工坊的右边是，正在处理的任务的细分任务阶段。

工程激活的细分任务阶段为：

- git 克隆

- git 切换分支

- 可用assemble指令查询


工程打包的细分阶段为：

- git pull

- assemble命令执行

- apk文件检测

- apk上传

- 构建打包结果
  """;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      color: Colors.transparent,
      child: SingleChildScrollView(
        child: Column(
          children: [
            // ...testLayout(),
            Text(text,style: TextStyle(fontSize: 20,fontWeight: FontWeight.w600),),
          ],
        ),
      ),
    );
  }

  testLayout() {
    return [
      Row(
        children: [
          FilledButton(
              child: const Text("测试华为OBS上传字符串"),
              onPressed: () async {
                var oBSResponse = await OBSClient.putObject(
                    objectName: "test/test.txt",
                    data: utf8.encode("Hello OBS"));

                debugPrint("${oBSResponse?.url}");
              }),
          const SizedBox(width: 20),
          FilledButton(
              child: const Text("测试华为OBS上传文件"),
              onPressed: () async {
                File fileToUpload = File(
                    "C:\\Users\\zwx1245985\\Desktop\\KBZPay_5.6.3_uat2_google.apk");

                var oBSResponse = await OBSClient.putFile(
                    objectName: "test/test20240228.apk", // 支持这样传，增加中间层目录
                    file: fileToUpload);

                debugPrint("${oBSResponse?.url}");
              }),
          const SizedBox(width: 20),
          FilledButton(
              child: const Text("测试解析apk文件"),
              onPressed: () async {
                String apkPath =
                    'E:/packTest/MyApp20231224/app/build/outputs/apk/debug/app-debug.apk'; // 替换为你的 APK 文件路径

                CommandUtil.getInstance().aapt(apkPath);
              }),
        ],
      ),
      const SizedBox(height: 30),
      AnimatedShapeWidget(
        width: 200,
        height: 200,
        animationDuration: const Duration(milliseconds: 200),
        startBorderRadius: 20,
        endBorderRadius: 100,
        startColor: Colors.green,
        endColor: Colors.blue,
      ),
    ];
  }
}
