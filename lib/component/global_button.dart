import 'package:flutter/material.dart';

import 'global_text.dart';

class GlobalButton extends StatelessWidget {
  final VoidCallback? onPressed;

  final Widget? iconWidget;

  final String? text;

  final MainAxisSize mainAxisSize;

  const GlobalButton({
    super.key,
    this.onPressed,
    this.iconWidget,
    this.text,
    this.mainAxisSize = MainAxisSize.min,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      child: Row(
        mainAxisSize: mainAxisSize,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (iconWidget != null)
            Padding(
              padding: EdgeInsets.only(right: 5.0),
              child: iconWidget,
            ),
          if (text != null)
            GlobalText(
              text: text!,
            ),
        ],
      ),
    );
  }
}
