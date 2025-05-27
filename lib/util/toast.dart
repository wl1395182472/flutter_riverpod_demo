import 'package:bot_toast/bot_toast.dart' show BotToast;
import 'package:flutter/material.dart'
    show
        Container,
        Alignment,
        EdgeInsets,
        MainAxisAlignment,
        MainAxisSize,
        BorderRadius,
        Colors,
        BoxDecoration,
        TextAlign,
        FontWeight,
        Column;

import '../component/global_text.dart' show GlobalText;

/// Toast 工具类
///
/// 基于 bot_toast 包的 Toast 通知工具
/// 提供加载提示和消息显示功能
///
/// 使用示例：
/// ```dart
/// // 显示加载框
/// final cancel = Toast.showLoading();
///
/// // 关闭所有加载框
/// Toast.closeAllLoading();
///
/// // 显示消息
/// Toast.show('操作成功');
/// ```
class Toast {
  /// 显示加载提示框
  ///
  /// 返回一个取消函数，可用于手动关闭加载框
  static showLoading() {
    return BotToast.showLoading();
  }

  /// 关闭所有加载提示框
  static closeAllLoading() {
    return BotToast.closeAllLoading();
  }

  /// 显示消息提示
  ///
  /// [message] 要显示的消息内容
  /// [allowClick] 是否允许点击穿透，默认为true
  /// [durationSeconds] 显示持续时间（秒），默认3秒
  /// [onlyOne] 是否只显示一个Toast，默认为true
  /// [onClose] Toast关闭时的回调函数
  static void show(
    String message, {
    bool allowClick = true,
    int durationSeconds = 3,
    bool onlyOne = true,
    void Function()? onClose,
  }) {
    BotToast.showEnhancedWidget(
      duration: Duration(seconds: durationSeconds),
      allowClick: allowClick,
      onlyOne: onlyOne,
      onClose: () {
        Future(() => onClose?.call());
      },
      toastBuilder: (closeFunc) => Container(
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: [
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 30.0),
              padding: const EdgeInsets.symmetric(
                horizontal: 30.0,
                vertical: 15.0,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8.0),
                color: Colors.black38,
              ),
              child: GlobalText(
                message,
                maxLines: null,
                textAlign: TextAlign.center,
                fontFamily: 'Barlow',
                color: Colors.white,
                fontSize: 14.0,
                height: 1.2,
                letterSpacing: 0.2,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
