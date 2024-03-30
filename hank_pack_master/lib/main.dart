import 'dart:io';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_acrylic/flutter_acrylic.dart' as flutter_acrylic;
import 'package:hive_flutter/adapters.dart';
import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:system_theme/system_theme.dart';
import 'package:window_manager/window_manager.dart';

import 'comm/functions.dart';
import 'comm/hwobs/obs_client.dart';
import 'comm/str_const.dart';
import 'hive/env_config/env_config_entity.dart';
import 'hive/env_config/env_config_operator.dart';
import 'hive/env_group/env_check_result_entity.dart';
import 'hive/env_group/env_group_entity.dart';
import 'hive/env_group/env_group_operator.dart';
import 'hive/fast_obs_upload/fast_obs_upload_operator.dart';
import 'hive/project_record/job_history_entity.dart';
import 'hive/project_record/job_result_entity.dart';
import 'hive/project_record/package_setting_entity.dart';
import 'hive/project_record/project_record_entity.dart';
import 'hive/project_record/project_record_operator.dart';
import 'hive/project_record/stage_record_entity.dart';
import 'hive/project_record/upload_platforms.dart';
import 'ui/app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  Directory saveDb = await path_provider.getApplicationCacheDirectory();
  debugPrint("saveDb->$saveDb");
  Hive.registerAdapter(EnvConfigEntityAdapter(), override: true);
  Hive.registerAdapter(PackageSettingAdapter(), override: true);
  Hive.registerAdapter(UploadPlatformAdapter(), override: true);
  Hive.registerAdapter(ProjectRecordEntityAdapter(), override: true);
  Hive.registerAdapter(EnvGroupEntityAdapter(), override: true);
  Hive.registerAdapter(EnvCheckResultEntityAdapter(), override: true);
  Hive.registerAdapter(JobHistoryEntityAdapter(),
      override: true); // StageRecordEntityAdapter
  Hive.registerAdapter(StageRecordEntityAdapter(), override: true);
  Hive.registerAdapter(JobResultEntityAdapter(), override: true);

  await Hive.initFlutter(saveDb.path);
  await EnvConfigOperator.openBox();
  await ProjectRecordOperator.openBox();
  await EnvGroupOperator.openBox();
  await FastObsUploadOperator.openBox();

  OBSClient.init(
    ak: EnvConfigOperator.searchEnvValue(Const.obsAccessKey),
    sk: EnvConfigOperator.searchEnvValue(Const.obsSecretKey),
    domain: EnvConfigOperator.searchEnvValue(Const.obsEndPoint),
    bucketName: EnvConfigOperator.searchEnvValue(Const.obsBucketName),
  );

  // if it's not on the web, windows or android, load the accent color
  if (!kIsWeb &&
      [
        TargetPlatform.windows,
        TargetPlatform.android,
      ].contains(defaultTargetPlatform)) {
    SystemTheme.accentColor.load();
  }

  if (isDesktop) {
    await flutter_acrylic.Window.initialize();
    if (defaultTargetPlatform == TargetPlatform.windows) {
      await flutter_acrylic.Window.hideWindowControls();
    }
    await WindowManager.instance.ensureInitialized();
    windowManager.waitUntilReadyToShow().then((_) async {
      await windowManager.setTitleBarStyle(
        TitleBarStyle.hidden,
        windowButtonVisibility: false,
      );
      await windowManager.setMinimumSize(const Size(500, 600));
      await windowManager.show();
      await windowManager.setPreventClose(true);
      await windowManager.setSkipTaskbar(false);
    });
  }

  runApp(const App()); // TEST
}
