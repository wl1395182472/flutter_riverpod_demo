import 'package:flutter/material.dart'
    show
        StatefulWidget,
        State,
        BuildContext,
        Widget,
        WidgetsBinding,
        Image,
        Hero,
        Center,
        Scaffold;
import 'package:go_router/go_router.dart';

import '../../constant/image_path.dart' show ImagePath;
import '../../service/app_service.dart' show AppService;
import '../../util/navigate.dart' show Navigate;

/// 应用启动页面组件
///
/// 主要功能：
/// - 显示应用图标启动画面
/// - 初始化应用服务
/// - 导航到主页
class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    // 在界面构建完成后执行初始化服务
    WidgetsBinding.instance.addPostFrameCallback((_) {
      initService();
    });
  }

  /// 初始化应用服务
  ///
  /// 确保总启动时间至少2秒，同时在这个时间内完成AppService初始化
  /// 初始化完成后自动导航到主页
  void initService() async {
    // 确保总时间至少2秒，AppService初始化在这2秒内完成
    await Future.wait([
      Future.delayed(const Duration(seconds: 2)), // 最少显示2秒启动画面
      AppService.instance.init(), // 初始化应用服务
    ]);

    // 检查页面是否仍然挂载，避免在页面已销毁后进行导航
    if (mounted) {
      context.go(Navigate.home);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Hero(
          tag: 'app_icon', // Hero动画标签，与主页的应用图标形成过渡动画
          child: Image.asset(
            '${ImagePath.instance.icon}app_icon.png',
          ),
        ),
      ),
    );
  }
}
