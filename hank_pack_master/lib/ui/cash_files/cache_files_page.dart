import 'package:file_picker/file_picker.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/material.dart' as m;
import 'package:hank_pack_master/ui/cash_files/cache_files_vm.dart';
import 'package:hank_pack_master/ui/project_manager/grid_datasource.dart';
import 'package:provider/provider.dart';

import '../../comm/ui/download_button.dart';
import '../../comm/ui/my_tool_tip_icon.dart';

class CacheFilesPage extends StatefulWidget {
  const CacheFilesPage({super.key});

  @override
  State<CacheFilesPage> createState() => _CacheFilesPageState();
}

class _CacheFilesPageState extends State<CacheFilesPage> {
  late CacheFilesVm _cacheFilesVm;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _cacheFilesVm.init();
    });
  }

  @override
  Widget build(BuildContext context) {
    _cacheFilesVm = context.watch<CacheFilesVm>();

    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const Text('缓存文件管理模块',
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          Card(
            backgroundColor: Colors.successPrimaryColor.withOpacity(.2),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _textInput(
                  toolTip: '输入仓库的host',
                  label: 'Host',
                  controller: _cacheFilesVm.hostInputController,
                ),
                _textInput(
                  toolTip: '输入仓库的path',
                  label: 'Path',
                  controller: _cacheFilesVm.pathInputController,
                ),
                _textInput(
                  toolTip: '选择文件的保存路径',
                  label: '文件保存路径',
                  controller: _cacheFilesVm.saveFolderInputController,
                  needFolderChoose: true,
                ),
                const SizedBox(height: 12),
                FilledButton(
                  style: ButtonStyle(
                      backgroundColor: ButtonState.resolveWith((states) =>
                          _cacheFilesVm.enableDownload
                              ? Colors.blue
                              : Colors.grey)),
                  child: const Text("开始批量下载",
                      style:
                          TextStyle(fontWeight: FontWeight.w600, fontSize: 22)),
                  onPressed: () {
                    if (_cacheFilesVm.enableDownload) {
                      _cacheFilesVm.fetchFilesList();
                    }
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _listFileWidget(),
        ],
      ),
    );
  }

  Widget _listFileWidget() {
    if (_cacheFilesVm.loadingFileList == true) {
      return const Expanded(
        child: Center(
          child: SizedBox(
            width: 100,
            height: 100,
            child: m.CircularProgressIndicator(),
          ),
        ),
      );
    } else {
      return Expanded(
          child: ListView.builder(
        itemBuilder: (c, i) {
          String fileName = _cacheFilesVm.listFileMap.keys.toList()[i];
          DownloadButtonController controller =
              _cacheFilesVm.listFileMap.values.toList()[i];
          return Padding(
            padding: const EdgeInsets.only(right: 30.0, bottom: 15),
            child: DownloadButton(
              fileName: fileName,
              mainColor: Colors.teal.darkest,
              btnWidth: 500,
              downloadButtonController: controller,
            ),
          );
        },
        itemCount: _cacheFilesVm.listFileMap.length,
      ));
    }
  }

  final _style = const TextStyle(fontSize: 22, fontWeight: FontWeight.w600);

  Widget _textInput({
    required String toolTip,
    required String label,
    required TextEditingController controller,
    bool needFolderChoose = false,
  }) {
    var dataCorrect = true;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(children: [
        Expanded(
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
              SizedBox(
                  width: 250,
                  child: Row(
                    children: [
                      Text(label, style: _style),
                      toolTipIcon(msg: toolTip, iconColor: Colors.teal),
                    ],
                  )),
              const Spacer(),
              Expanded(
                child: TextBox(
                  style: _style,
                  decoration: BoxDecoration(
                      border: Border.all(
                          color: dataCorrect ? Colors.white : Colors.red,
                          width: 1)),
                  unfocusedColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  controller: controller,
                  textAlign: TextAlign.end,
                  suffix: needFolderChoose
                      ? IconButton(
                          icon: const Icon(FluentIcons.folder_open, size: 18),
                          onPressed: () async {
                            String? selectedDirectory =
                                await FilePicker.platform.getDirectoryPath();
                            if (selectedDirectory != null) {
                              controller.text = selectedDirectory;
                            }
                          })
                      : const SizedBox(),
                ),
              )
            ])),
      ]),
    );
  }
}
