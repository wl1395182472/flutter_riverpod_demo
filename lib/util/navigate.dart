import 'package:go_router/go_router.dart' show GoRouter, GoRoute;

import '../view/home/home_page.dart' show HomePage;
import '../view/not_found/not_found_page.dart' show NotFoundPage;
import '../view/purchase/purchase_page.dart' show PurchasePage;
import '../view/splash/splash_page.dart' show SplashPage;

/// 路由导航工具类
///
/// 基于 GoRouter 的单例路由管理工具，提供应用内统一导航功能
/// 使用单例模式确保整个应用共享同一个路由实例
///
/// 使用示例：
/// ```dart
/// // 导航到指定路径
/// Navigate.instance.to('/purchase');
///
/// // 推送新页面并等待返回结果
/// final result = await Navigate.instance.push<String>('/purchase');
///
/// // 返回上一页
/// Navigate.instance.back();
/// ```
class Navigate {
  /// 私有构造函数，防止外部直接实例化
  Navigate._privateConstructor();

  /// 单例实例
  static final instance = Navigate._privateConstructor();

  /// 工厂构造函数，返回单例实例
  factory Navigate() {
    return instance;
  }

  /// 定义路由名称常量
  /// 首页路径
  static const String home = '/';

  /// 启动页路径
  static const String splash = '/splash';

  /// 购买页路径
  static const String purchase = '/purchase';

  // GoRouter 路由实例配置
  late final router = GoRouter(
    // 设置应用启动时的初始路由
    initialLocation: splash,
    // 定义应用所有可用路由
    routes: [
      // 启动页路由
      GoRoute(
        path: splash,
        name: 'splash',
        builder: (context, state) => const SplashPage(),
      ),
      // 首页路由
      GoRoute(
        path: home,
        name: 'home',
        builder: (context, state) => const HomePage(),
      ),
      // 购买页路由
      GoRoute(
        path: purchase,
        name: 'purchase',
        builder: (context, state) => const PurchasePage(),
      ),
    ],

    // 路由错误处理，当访问不存在的路由时显示404页面
    errorBuilder: (context, state) => NotFoundPage(),

    // 开启调试日志，在开发环境下打印路由相关信息
    debugLogDiagnostics: true,

    // 路由重定向处理，可在此处实现登录验证等逻辑
    redirect: (context, state) {
      // 暂无重定向逻辑
      return null;
    },
  );

  /// 普通导航到新页面（替换当前路由栈）
  ///
  /// [path] 目标路径
  /// [extra] 传递给目标页面的额外数据
  void to(String path, {Object? extra}) {
    router.go(path, extra: extra);
  }

  /// 推送新页面到路由栈顶并等待返回结果
  ///
  /// [path] 目标路径
  /// [extra] 传递给目标页面的额外数据
  /// 返回目标页面关闭时传回的数据
  Future<T?> push<T>(String path, {Object? extra}) {
    return router.push<T>(path, extra: extra);
  }

  /// 替换当前页面（不改变路由栈深度）
  ///
  /// [path] 目标路径
  /// [extra] 传递给目标页面的额外数据
  void replace(String path, {Object? extra}) {
    router.replace(path, extra: extra);
  }

  /// 返回上一页
  ///
  /// [result] 传递给上一页的返回数据
  void back<T>([T? result]) {
    if (router.canPop()) {
      router.pop(result);
    }
  }

  /// 返回到指定路径（清空路由栈并导航到目标路径）
  ///
  /// [path] 目标路径
  void backTo(String path) {
    router.go(path);
  }

  /// 弹出到根路由（清空整个路由栈）
  void popToRoot() {
    while (router.canPop()) {
      router.pop();
    }
  }
}
