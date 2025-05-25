import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';

class Toast {
  static showLoading() {
    return BotToast.showLoading();
  }

  static closeAllLoading() {
    return BotToast.closeAllLoading();
  }

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
              child: Text(
                message,
                maxLines: null,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Barlow',
                  color: Colors.white,
                  fontSize: 14.0,
                  height: 1.2,
                  letterSpacing: 0.2,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
