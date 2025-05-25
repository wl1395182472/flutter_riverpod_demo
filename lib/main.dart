import 'package:flutter/material.dart';

import 'view/my_app.dart';
import 'service/storage_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await StorageService.instance.init();

  runApp(const MyApp());
}
