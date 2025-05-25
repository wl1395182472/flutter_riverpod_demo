import 'package:flutter/material.dart';

import '../../component/global_text.dart';

class NotFoundPage extends StatelessWidget {
  const NotFoundPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Page Not Found'),
      ),
      body: Center(
        child: GlobalText(
          text: '404 - Page Not Found',
        ),
      ),
    );
  }
}
