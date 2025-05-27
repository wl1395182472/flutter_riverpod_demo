import 'package:flutter/material.dart'
    show
        StatelessWidget,
        TextAlign,
        Color,
        FontWeight,
        BuildContext,
        Widget,
        TextStyle,
        Text;

/// 全局文本组件
///
/// 一个可定制的文本 Widget，提供了统一的文本样式管理
/// 基于 Flutter 的 Text 组件封装，支持自定义字体、颜色、大小等样式属性
class GlobalText extends StatelessWidget {
  /// 文本内容
  ///
  /// 要显示的文本字符串
  final String text;

  /// 最大行数
  ///
  /// 文本可以显示的最大行数，超出部分会被截断
  final int? maxLines;

  /// 文本对齐方式
  ///
  /// 控制文本在容器中的对齐方式（左对齐、居中、右对齐等）
  final TextAlign? textAlign;

  /// 字体族名称
  ///
  /// 指定文本使用的字体族，如果未指定则默认使用 'Bitter' 字体
  final String? fontFamily;

  /// 文本颜色
  ///
  /// 指定文本的颜色
  final Color? color;

  /// 字体大小
  ///
  /// 指定文本的字体大小
  final double? fontSize;

  /// 行高倍数
  ///
  /// 行高与字体大小的比值，用于控制行间距
  final double? height;

  /// 字符间距
  ///
  /// 字符之间的额外间距
  final double? letterSpacing;

  /// 字体粗细
  ///
  /// 控制文本的粗细程度（正常、粗体等）
  final FontWeight? fontWeight;

  /// 构造函数
  ///
  /// 创建一个全局文本组件实例
  ///
  /// [text] - 要显示的文本内容，必需参数
  /// [key] - Widget 的键值
  /// [maxLines] - 文本最大行数
  /// [textAlign] - 文本对齐方式
  /// [fontFamily] - 字体族名称，默认为 'Bitter'
  /// [color] - 文本颜色
  /// [fontSize] - 字体大小
  /// [height] - 行高倍数
  /// [letterSpacing] - 字符间距
  /// [fontWeight] - 字体粗细
  const GlobalText(
    this.text, {
    super.key,
    this.maxLines,
    this.textAlign,
    this.fontFamily,
    this.color,
    this.fontSize,
    this.height,
    this.letterSpacing,
    this.fontWeight,
  });

  /// 构建 Widget
  ///
  /// 返回一个配置了自定义样式的 Text Widget
  /// 如果未指定字体族，则默认使用 'Bitter' 字体
  @override
  Widget build(BuildContext context) {
    return Text(
      text, // 显示的文本内容
      maxLines: maxLines, // 设置最大行数
      textAlign: textAlign, // 设置文本对齐方式
      style: TextStyle(
        // 设置字体族，如果未指定则使用默认的 'Bitter' 字体
        fontFamily: fontFamily ?? 'Bitter',
        color: color, // 设置文本颜色
        fontSize: fontSize, // 设置字体大小
        height: height, // 设置行高倍数
        letterSpacing: letterSpacing, // 设置字符间距
        fontWeight: fontWeight, // 设置字体粗细
      ),
    );
  }
}
