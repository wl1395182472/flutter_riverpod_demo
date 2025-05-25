import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart' hide Theme;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../constant/app_config.dart';
import '../constant/theme.dart';
import '../util/navigate.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      child: ScreenUtilInit(
        designSize: const Size(1080, 2339),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (_, child) => MaterialApp.router(
          title: AppConfig.instance.appName,
          theme: Theme.instance.theme,
          builder: BotToastInit(),
          routerConfig: Navigate.instance.router,
        ),
      ),
    );
  }
}
