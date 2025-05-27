import 'package:flutter/material.dart'
    show
        StatelessWidget,
        Widget,
        MainAxisSize,
        BuildContext,
        VoidCallback,
        ElevatedButton,
        Row,
        MainAxisAlignment,
        EdgeInsets,
        Padding;

import 'global_text.dart' show GlobalText;

/// 全局按钮组件
///
/// 支持显示图标和文本的自定义按钮组件，基于 ElevatedButton 实现
/// 可以单独显示图标、文本或者同时显示图标和文本
class GlobalButton extends StatelessWidget {
  /// 按钮点击回调函数
  ///
  /// 当用户点击按钮时触发，如果为 null 则按钮处于禁用状态
  final VoidCallback? onPressed;

  /// 按钮图标组件
  ///
  /// 可选的图标 Widget，显示在文本左侧
  final Widget? iconWidget;

  /// 按钮文本内容
  ///
  /// 可选的文本字符串，使用 GlobalText 组件渲染
  final String? text;

  /// 主轴大小设置
  ///
  /// 控制 Row 组件的主轴占用空间大小，默认为 MainAxisSize.min
  final MainAxisSize mainAxisSize;

  /// 构造函数
  ///
  /// 创建一个全局按钮组件实例
  ///
  /// [key] - Widget 的键值
  /// [onPressed] - 按钮点击回调函数
  /// [iconWidget] - 可选的图标组件
  /// [text] - 可选的按钮文本
  /// [mainAxisSize] - 主轴大小设置，默认为 MainAxisSize.min
  const GlobalButton({
    super.key,
    this.onPressed,
    this.iconWidget,
    this.text,
    this.mainAxisSize = MainAxisSize.min,
  });

  /// 构建 Widget
  ///
  /// 返回一个 ElevatedButton，内部使用 Row 布局来排列图标和文本
  /// 如果只有图标或只有文本，会自动调整布局
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      child: Row(
        // 设置主轴大小，控制 Row 占用的空间
        mainAxisSize: mainAxisSize,
        // 内容居中对齐
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 如果存在图标，则显示图标并添加右边距
          if (iconWidget != null)
            Padding(
              padding: EdgeInsets.only(right: 5.0),
              child: iconWidget,
            ),
          // 如果存在文本，则使用 GlobalText 组件显示
          if (text != null)
            GlobalText(
              text!,
            ),
        ],
      ),
    );
  }
}
