import 'package:logger/logger.dart';

class Log {
  Log._privateConstructor();

  static final instance = Log._privateConstructor();

  factory Log() {
    return instance;
  }

  final logger = Logger();
}
