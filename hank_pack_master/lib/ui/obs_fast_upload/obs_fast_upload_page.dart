import 'package:cross_file/cross_file.dart';
import 'package:desktop_drop/desktop_drop.dart';
import 'package:flutter/material.dart';
import 'package:hank_pack_master/comm/gradients.dart';

/// 文件快传，选中一个文件，并且
class ObsFastUploadPage extends StatefulWidget {
  const ObsFastUploadPage({super.key});

  @override
  State<ObsFastUploadPage> createState() => _ObsFastUploadPageState();
}

class _ObsFastUploadPageState extends State<ObsFastUploadPage> {
  XFile? _selectedFile;

  bool _dragging = false;

  final _textStyle1 = const TextStyle(
      fontSize: 22, fontWeight: FontWeight.w600, fontFamily: 'STKAITI');

  final _textStyle2 = const TextStyle(
    fontSize: 30,
    fontWeight: FontWeight.w600,
    fontFamily: 'STKAITI',
  );

  @override
  Widget build(BuildContext context) {
    return DropTarget(
      onDragDone: (detail) {
        setState(() {
          if (detail.files.isEmpty) {
            debugPrint('没有选择任何文件');
          } else if (detail.files.length > 1) {
            debugPrint('仅支持选择单个文件');
          } else {
            _selectedFile = detail.files[0];
          }
        });
      },
      onDragEntered: (detail) {
        setState(() {
          _dragging = true;
        });
      },
      onDragExited: (detail) {
        setState(() {
          _dragging = false;
        });
      },
      child: Container(
          decoration: BoxDecoration(gradient: mainPanelGradient),
          padding: const EdgeInsets.all(15),
          child: Column(
            children: [fileSelectorWidget()],
          )),
    );
  }

  // 每次仅仅支持一个文件
  Widget fileSelectorWidget() {
    var text = _selectedFile == null
        ? Center(
            child: Text(
            "拖拽文件放置到这里",
            style: _textStyle2,
          ))
        : FutureBuilder(
            future: _selectedFile!.string(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return const Text('读取xFile错误');
              } else {
                return Text(
                  '${snapshot.data}',
                  style: _textStyle1,
                );
              }
            });

    return Card(
      color: _dragging ? Colors.teal : Colors.teal.withOpacity(.2),
      child: Container(
          padding: const EdgeInsets.all(15),
          width: double.infinity,
          height: 200,
          child: text),
    );
  }
}

extension XFileExt on XFile {
  Future<String> string() async {
    return '''
    $path 
    $name
    $mimeType
    ${await length()}
    ${await lastModified()}
    ''';
  }
}
