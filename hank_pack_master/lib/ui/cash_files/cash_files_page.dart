import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/material.dart' as m;
import 'package:hank_pack_master/ui/cash_files/cache_files_vm.dart';
import 'package:hank_pack_master/ui/project_manager/grid_datasource.dart';
import 'package:provider/provider.dart';

import '../../comm/ui/download_button.dart';

class CashFilesPage extends StatefulWidget {
  const CashFilesPage({super.key});

  @override
  State<CashFilesPage> createState() => _CashFilesPageState();
}

class _CashFilesPageState extends State<CashFilesPage> {
  late CacheFilesVm _cacheFilesVm;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _cacheFilesVm.fetchFilesList();
    });
  }

  Widget _textRow(String title, String content) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Text(title, style: gridTextStyle),
          const Text(" : ", style: gridTextStyle),
          Text(content, style: gridTextStyle.copyWith(color: Colors.orange)),
        ],
      ),
    );
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
          _textRow("host", _cacheFilesVm.host),
          _textRow("path", _cacheFilesVm.path),
          _textRow("saveFolder", _cacheFilesVm.saveFolder),
          const SizedBox(height: 12),
          _listFileWidget(),
        ],
      ),
    );
  }

  Widget _listFileWidget() {
    if (_cacheFilesVm.loading == true) {
      return const Center(
        child: SizedBox(
          width: 100,
          height: 100,
          child: m.CircularProgressIndicator(),
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
}
