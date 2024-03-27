import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio_smart_retry/dio_smart_retry.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:hank_pack_master/comm/toast_util.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../comm/ui/download_button.dart';

class CacheFilesVm extends ChangeNotifier {
  // 给定一个依赖下载地址：https://repo1.maven.org/maven2/org/apache/logging/log4j/log4j-core/2.17.0/ (maven的案例)
  // 换一个：           https://repo1.maven.org/maven2/org/apache/spark/spark-hive_2.13/3.5.1/
  String get host {
    var ori = hostInputController.text;
    if (ori.endsWith("/") || ori.endsWith("\\")) {
      return ori;
    }
    return ori + Platform.pathSeparator;
  } // "https://repo1.maven.org/maven2/";
  String get path {
    var ori = pathInputController.text;
    if (ori.endsWith("/") || ori.endsWith("\\")) {
      return ori;
    }
    return ori + Platform.pathSeparator; // 这里需要补充一个 /
  } // "org/apache/spark/spark-hive_2.13/3.5.1/";

  String get saveFolder => saveFolderInputController.text; // "E:/fileCache/";

  Map<String, DownloadButtonController> listFileMap = {};
  Map<String, bool> downloadTagList = {};

  TextEditingController hostInputController = TextEditingController();
  TextEditingController pathInputController = TextEditingController();
  TextEditingController saveFolderInputController = TextEditingController();

  String spTagHostInput = "hostInput";
  String spTagPathInput = "pathInput";
  String spTagSaveFolder = "saveFolder";

  init() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    hostInputController.addListener(() {
      prefs.setString(spTagHostInput, hostInputController.text);
      notifyListeners();
    });
    hostInputController.text = prefs.getString(spTagHostInput) ?? '';

    pathInputController.addListener(() {
      prefs.setString(spTagPathInput, pathInputController.text);
      notifyListeners();
    });
    pathInputController.text = prefs.getString(spTagPathInput) ?? '';

    saveFolderInputController.addListener(() {
      prefs.setString(spTagSaveFolder, saveFolderInputController.text);
      notifyListeners();
    });

    saveFolderInputController.text =
        prefs.getString(spTagSaveFolder) ?? defaultMavenLocalPath;
  }

  String get defaultMavenLocalPath {
    String? username = Platform.environment['USERNAME'];
    String defaultSaveFolder = "C:\\Users\\$username\\.m2\\repository";

    return defaultSaveFolder;
  }

  bool get enableDownload {
    if (host.isEmpty) {
      return false;
    }
    if (path.isEmpty) {
      return false;
    }
    if (saveFolder.isEmpty) {
      return false;
    }
    return true;
  }

  List<String> _parseHtmlString(String htmlString) {
    List<String> list = [];

    // 提取所有链接
    RegExp linkRegExp = RegExp(r'href="([^"]+)"');
    // 正则解释一下：
    // r前缀标识了这是一个原始字符串字面量，在Dart中，原始字符串字面量以r开头，它们允许我们在字符串中使用反斜杠而无需对其进行转义。这在处理正则表达式时非常有用，因为正则表达式本身经常包含反斜杠。
    //
    // href="([^"]+)"是实际的正则表达式模式。
    //
    // href=": 这部分简单地匹配了字符串中的“href=”这个文本。
    // ([^"]+): 这是一个用括号括起来的子表达式，
    // 它实际上定义了我们想要匹配的内容。
    // [^"]表示匹配除了双引号之外的任意字符，
    // +表示匹配前面的表达式一次或多次。
    // 因此，([^"]+)表示匹配双引号之间的所有字符（不包括双引号本身）。
    // ": 最后的双引号表示我们要匹配的文本在结束时需要有双引号闭合。
    Iterable<Match> matches = linkRegExp.allMatches(htmlString);

    // 打印链接
    for (Match match in matches) {
      if (match.groupCount > 0) {
        String? fileName = match.group(1);
        if (fileName == null || fileName.isEmpty) {
          continue;
        }
        if (fileName.contains("/")) {
          continue;
        }
        list.add(fileName);
      }
    }

    return list;
  }

  bool get downloading {
    if (downloadTagList.isEmpty) {
      return false;
    } else {
      var x = downloadTagList.values.where((e) => e == false).isNotEmpty;
      return x;
    }
  }

  int get uncompletedCount {
    return downloadTagList.values.where((e) => true == e).length;
  }

  int get totalCount {
    return downloadTagList.length;
  }

  Future fetchFilesList({
    required Function(bool loading) progressUtil,
    required Function(String) showErrorDialogFunc,
  }) async {
    progressUtil(true);
    listFileMap.clear();
    downloadTagList.clear();
    notifyListeners();

    Dio dio = Dio();

    try {
      Response response = await dio.get(host + path);
      progressUtil(false);

      if (response.statusCode == 200) {
        List<String> listFile = _parseHtmlString(response.data);

        for (var s in listFile) {
          listFileMap[s] = DownloadButtonController(); // 给每一条下载任务都创建一个下载按钮控制器
          downloadTagList[s] = false;
        }

        notifyListeners();

        if (listFileMap.isNotEmpty) {
          await downloadEachFile();
        }
      } else {
        ToastUtil.showPrettyToast("没有找到任何可下载的文件 ${response.statusCode}");
        progressUtil.call(false);
      }
    } catch (e) {
      showErrorDialogFunc("$e");
      progressUtil.call(false);
    }
  }

  Future downloadEachFile() async {
    Dio dio = Dio();

    dio.interceptors.add(RetryInterceptor(
      dio: dio,
      logPrint: print, // specify log function (optional)
      retries: 3, // retry count (optional)
      retryDelays: const [
        // set delays between retries (optional)
        Duration(seconds: 15), // wait 1 sec before first retry
        Duration(seconds: 15), // wait 2 sec before second retry
        Duration(seconds: 15), // wait 3 sec before third retry
      ],
    ));

    listFileMap.forEach((fileName, controller) async {
      String fileUrl = host + path + fileName;
      String savePath =
          saveFolder + Platform.pathSeparator + path + fileName; // 文件保存的本地路径
      controller.startDownload();
      try {
        await dio.download(fileUrl, savePath, onReceiveProgress: (c, t) {
          controller.setProgressValue((100 * c / t).round());
          if (c == t) {
            downloadTagList[fileName] = true;
          }
        });
        notifyListeners();
        debugPrint('$fileUrl 下载成功，保存在 $savePath');
      } on DioException catch (e) {
        debugPrint('下载失败: $fileUrl, 错误信息: ${e.message}'); // 下载失败咋办呢？
        downloadTagList[fileName] = true;
        notifyListeners();
      }
    });
  }
}
