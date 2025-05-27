import 'package:bot_toast/bot_toast.dart' show BotToastInit;
import 'package:flutter/material.dart'
    show StatelessWidget, BuildContext, Widget, Size, MaterialApp;
import 'package:flutter_riverpod/flutter_riverpod.dart' show ProviderScope;
import 'package:flutter_screenutil/flutter_screenutil.dart' show ScreenUtilInit;

import '../constant/app_config.dart' show AppConfig;
import '../constant/theme.dart' show Theme;
import '../util/navigate.dart' show Navigate;

/// 应用程序的根Widget
/// 负责配置全局的Provider作用域、屏幕适配、主题和路由
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      // Riverpod的Provider作用域，为整个应用提供状态管理
      child: ScreenUtilInit(
        // 屏幕适配初始化配置
        designSize: const Size(1080, 2339), // 设计稿尺寸（宽x高）
        minTextAdapt: true, // 启用最小文字适配
        splitScreenMode: true, // 支持分屏模式
        builder: (_, child) => MaterialApp.router(
          // 使用Material风格的应用，支持路由配置
          title: AppConfig.instance.appName, // 应用名称，从配置中获取
          theme: Theme.instance.theme, // 应用主题，从主题配置中获取
          builder: BotToastInit(), // BotToast初始化，用于显示Toast消息
          routerConfig: Navigate.instance.router, // 路由配置，从导航工具中获取
        ),
      ),
    );
  }
}
