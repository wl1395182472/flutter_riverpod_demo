import 'package:flutter/material.dart' show WidgetsFlutterBinding, runApp;

import 'service/storage_service.dart' show StorageService;
import 'view/my_app.dart' show MyApp;

/// 应用程序的主入口函数
/// 负责初始化必要的服务并启动应用
void main() async {
  // 确保Flutter绑定初始化完成
  // 这是在runApp之前调用异步方法的必要步骤
  WidgetsFlutterBinding.ensureInitialized();

  // 初始化存储服务
  // 等待存储服务完全初始化后再启动应用，确保数据持久化功能可用
  await StorageService.instance.init();

  // 启动Flutter应用
  // 传入MyApp作为根Widget
  runApp(const MyApp());
}
