2024年2月11日:
找到一个 表格组件的案例：git@github.com:syncfusion/flutter-examples.git

可以参照它来制作表格的各种高级特性。


2024年2月15日:
pgy: '_api_key': '3e3bb841269ccb9e3fb9b3feffa4273c'


测试用的git工程:
"git@github.com:18598925736/MyApplication0016.git"; // 测试 Java17环境下的安卓工程
"git@github.com:18598925736/MyApp20231224.git"; // 测试 Java11环境下的安卓工程
"https://github.com/18598925736/MyApp20231224.git" // 在公司只能用 https测试github的东西
"ssh://git@codehub-dg-g.huawei.com:2222/zWX1245985/test20240204_2.git"; // 公司电脑，测试内网git

2024年2月16日：

自动参数环境检测之后，应该提供一个手动添加环境的过程。
比如，用where java命令并不能找出机器上所有的jdk，此时，就需要用户手动去指定，然后自动去校验它是否有效。

很多安卓工程都是使用不同的 jdk版本去构建的，所以，在打包阶段，应该还要提供强制指定jdk版本的选项。

至此，基本功能已经完成。

预计在2月底发布 0.0.1内测版本。


2024年2月22日

接下来要完成，打包失败的记录完整化，因为后续要提供 apk包上传失败后，允许重新从失败的阶段继续往下走。


接下来最重要的改动就是，保留所有失败记录，包括项目激活的。并且支持从失败的节点继续往下走。
2024年2月24日

1. 打包成功之后，给一个未读数给打包历史上


  OBSClient.init(
      ak: "WME9RK9W2EA5J7WMG0ZD",
      sk: "mW2cNSmvCgDBk2WSeqNSdJowr7KlMTe5FxDl9ovB",
      domain:
      "https://kbzpay-apppackage.obs.ap-southeast-1.myhuaweicloud.com",
      bucketName: "kbzpay-apppackage");


2024年2月27日：
针对上传过程中失败的，允许以上传的那个包为起始点继续上传。