import 'package:flutter/material.dart';

class Theme {
  Theme._privateConstructor();

  static final instance = Theme._privateConstructor();

  factory Theme() {
    return instance;
  }
  final theme = ThemeData(
    useMaterial3: true,
    primaryColor: Color(0xffF64E83),
  );
}
