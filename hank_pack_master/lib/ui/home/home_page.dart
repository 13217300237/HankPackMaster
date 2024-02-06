import 'package:fluent_ui/fluent_ui.dart';

import '../../comm/hwobs/hw_obs_util.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String text = """
  # 2023年12月23日
现在所有的任务都可以正常执行。

# 2023年12月30日
现在可以正常检查打包所需环境参数
我正在做一款 安卓打包的流水线工具，编程框架为Flutter。你帮我参谋一下我还有哪些需要完善的。

暂时命名：安小助。
设计 整体的功能模块。

1. 参数管理模块
   - 环境参数的自动感应
     - 如果同一个环境存在多个不同路径，那就要求用户选择。或者手动自行指定。
     - 比如，检测出sdk路径有多个，那就将这么几个显示在界面上，供用户进行单选，并且另外提供一个目录选择的方式手动指定。
     - 目前需要检查的环境参数有：安卓sdk，jdk，flutterSdk，git等
   - 打包文件默认输出路径
     - 用于在打包成功之后检测apk的生成路径下是否有刚刚打出的包，并且对该包进行合法性检查（包体积，包最后修改时间等）
   - 是否自动上传
     - 如果自动上传，需要设置当前 服务器的TOKEN ,APPID ,KEY等参数，并提供TEST按钮检查服务器的可用性。
     - 如果不自动上传，则无需参数。
2. 工程管理模块
   - 工程设置（git地址，git分支）
   - 预览工作区间文件
   - 查看打包记录
     - 打包的成败
       - 成功的优先显示apk文件路径，次而显示打包时的完整参数和全部日志
       - 失败的主要显示 错误日志，次而显示打包时的完整参数
     - 打包存档
       - 每一次打包时的git提交记录
       - 每一次打包的
   - 开始打包任务
     - 用流水线指示灯的模式，展示打包的每一个阶段所发生的细节。
     - 遇到异常时，中断当前操作。
     - 一个项目从git clone到输出产物的下载二维码，完整步骤为：
       - gitClone
       - gitCheckout
       - checkProject
       - assemble
       - checkApk
       - zipalign
       - jiagu
       - upload
       - generateQrCode
       - 以上步骤串行执行，有一个步骤出现异常，剩下的步骤不再执行，并且输出错误日志。
3. 应用包回溯模块
   1. 允许从窗口外拖入一个 apk进来，分析它的包名，图标，最后修改日期，
   2. 从 本地的打包记录中，尝试查找和这个包对应的打包记录，如果能找到的话，输出该次打包的git仓库地址，代码分支，打包时间等。
4. 应用设置模块
   - UI方面
     - 字体
     - 皮肤
   - 版本号管理
  """;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      color: Colors.transparent,
      child: SingleChildScrollView(
        child: Column(
          children: [
            FilledButton(
                child: const Text("测试华为OBS上传"),
                onPressed: () async {
                  return HwObsUtil.getInstance().doUpload();
                }),
            const SizedBox(height: 10),
            FilledButton(
                child: const Text("测试华为OBS列举桶"),
                onPressed: () async {
                  return HwObsUtil.getInstance().duList();
                }),
            const SizedBox(height: 30),
            Text(
              text,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
