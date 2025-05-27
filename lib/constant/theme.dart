import 'dart:ui' show Color;

import 'package:flutter/material.dart' show ThemeData;

/// 主题管理类
/// 使用单例模式管理应用程序的主题配置
/// 便于全局统一样式管理
class Theme {
  /// 私有构造函数，防止外部直接实例化
  Theme._privateConstructor();

  /// 单例实例
  static final instance = Theme._privateConstructor();

  /// 工厂构造函数，返回单例实例
  factory Theme() {
    return instance;
  }

  /// TODO: 应用程序主题配置
  /// 使用Material 3设计系统
  /// 主色调为粉红色 (#F64E83)
  final theme = ThemeData(
    useMaterial3: true,
    primaryColor: Color(0xffF64E83),
  );
}
