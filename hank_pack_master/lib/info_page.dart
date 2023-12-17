import 'package:flutter/material.dart';

class MyInfoPage extends StatefulWidget {
  const MyInfoPage({super.key, required this.title});

  final String title;

  @override
  State<MyInfoPage> createState() => _MyInfoPageState();
}

class _MyInfoPageState extends State<MyInfoPage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              '''
              这是一个流水线作业工具，它目前的功能只针对安卓工程:
              1. 调用git指令克隆git仓库，并切换到指定分支，并且合并指定分支的代码
              2. 执行gradle命令，对安卓工程进行编译，随后执行打包指令，最后产出apk文件
              3. 执行签名指令，对apk进行再签名
              4. 执行加固命令，对apk进行加固并再签名
              5. 将加固后的apk文件上传到 pgy 这种托管平台
              其中各种指令的执行结果，通过stream 显示在日志面板上
              
              我做这个的目的，就是将打包出产物的流程一体化，人为的操作只有 设置好 git仓库以及 工作分支然后点击开始打包即可。
              生成的产物apk将会以 下载链接，下载二维码，以及 文件本身的方式，呈现在 用户设置好的目标目录上
              ''',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.dangerous),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
