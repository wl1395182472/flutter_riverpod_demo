import 'package:flutter/material.dart';

class GlobalText extends StatelessWidget {
  final String text;

  const GlobalText({
    super.key,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
    );
  }
}
