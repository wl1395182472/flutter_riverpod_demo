import 'package:flutter/material.dart'
    show StatelessWidget, BuildContext, Widget, AppBar, Center, Scaffold;

import '../../component/global_text.dart' show GlobalText;

/// 404页面组件
///
/// 当用户访问不存在的路由时显示此页面
/// 提供统一的错误提示界面
class NotFoundPage extends StatelessWidget {
  const NotFoundPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 应用栏，显示页面标题
      appBar: AppBar(
        title: const GlobalText('Page Not Found'),
      ),
      // 页面主体内容
      body: Center(
        child: GlobalText(
          '404 - Page Not Found', // 404错误提示文本
        ),
      ),
    );
  }
}
