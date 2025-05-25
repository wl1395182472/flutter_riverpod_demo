import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../constant/image_path.dart';
import '../../service/app_service.dart';
import '../../util/navigate.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      initService();
    });
  }

  void initService() async {
    // 确保总时间至少2秒，AppService初始化在这2秒内完成
    await Future.wait([
      Future.delayed(const Duration(seconds: 2)),
      AppService.instance.init(),
    ]);

    if (mounted) {
      context.go(Navigate.home);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Image.asset(
          '${ImagePath.instance.icon}app_icon.png',
        ),
      ),
    );
  }
}
