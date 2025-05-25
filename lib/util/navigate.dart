import 'package:go_router/go_router.dart';

import '../view/home/home_page.dart';
import '../view/not_found/not_found_page.dart';
import '../view/purchase/purchase_page.dart';
import '../view/splash/splash_page.dart';

/// 路由导航工具类
/// 单例模式实现，提供应用内导航功能
class Navigate {
  Navigate._privateConstructor();

  static final instance = Navigate._privateConstructor();

  factory Navigate() {
    return instance;
  }

  // 定义路由名称常量
  static const String home = '/';
  static const String splash = '/splash';
  static const String purchase = '/purchase';

  // 路由实例
  late final router = GoRouter(
    // 初始路由
    initialLocation: splash,
    // 定义路由
    routes: [
      GoRoute(
        path: splash,
        name: 'splash',
        builder: (context, state) => const SplashPage(),
      ),
      GoRoute(
        path: home,
        name: 'home',
        builder: (context, state) => const HomePage(),
      ),
      GoRoute(
        path: purchase,
        name: 'purchase',
        builder: (context, state) => const PurchasePage(),
      ),
    ],

    // 错误处理
    errorBuilder: (context, state) => NotFoundPage(),

    // 调试日志
    debugLogDiagnostics: true,

    // 重定向处理
    redirect: (context, state) {
      return null;
    },
  );
  // 普通导航到新页面
  void to(String path, {Object? extra}) {
    router.go(path, extra: extra);
  }

  // 推送新页面并期望返回结果
  Future<T?> push<T>(String path, {Object? extra}) {
    return router.push<T>(path, extra: extra);
  }

  // 替换当前页面
  void replace(String path, {Object? extra}) {
    router.replace(path, extra: extra);
  }

  // 返回上一页
  void back<T>([T? result]) {
    if (router.canPop()) {
      router.pop(result);
    }
  }

  // 返回到指定路径
  void backTo(String path) {
    router.go(path);
  }

  // 弹出到顶层路由
  void popToRoot() {
    while (router.canPop()) {
      router.pop();
    }
  }
}
