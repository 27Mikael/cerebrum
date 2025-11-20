import 'package:flutter/material.dart';
import './responsive_layout.dart';
import 'ui/desktop/desktop_main.dart';
import 'ui/mobile/mobile_main.dart';

void main() {
  runApp(const CerebrumApp());
}

class CerebrumApp extends StatelessWidget {
  const CerebrumApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: ResponsiveLayout(
        desktop: const DesktopUI(),
        mobile: const MobileUI(),
        // TODO: tablet: const TabletUI()
      ),
    );
  }
}
