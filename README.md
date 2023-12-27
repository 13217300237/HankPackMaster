# HankPackMaster
一个自动化的apk打包上传加固签名一体化的工具。

# 功能概述

这是一款集成化打包工具，具备自动

## git操作

- 克隆代码
  
- 切换分支
  
- 合并分支
  
- 检查最新提交
  

## 打包操作

- 执行任意gradle命令
  
- 执行打包命令，生成 apk产物
  
- 调整打包参数（verisonCode,versionName等）
  

## apk文件后续操作

- 自动apk签名
  
- 自动apk加固
  
- 自动上传到 托管平台（蒲公英，七牛，OBS等）
  
- 支持最终产物的重命名并输出到指定位置
  
- 自动生成下载链接和下载二维码，支持设置下载有效期
  

这只是第一阶段。

如果有了Mac机器，往第二阶段走，打出 ipa。

第三阶段，打出Flutter支持的所有 应用产物（mac版本，windows版本，Web版）

# 技术选型

开发框架为Flutter，Flutter对于 桌面版（windows，mac，fusion）的支持也越来越完善。

收集到了一个 flutterDesktop技术支持的 案例和package集。`https://github.com/leanflutter/awesome-flutter-desktop`

可以从这里获得技术支持。


桌面版本的UI组件库：fluent_ui，可用。
