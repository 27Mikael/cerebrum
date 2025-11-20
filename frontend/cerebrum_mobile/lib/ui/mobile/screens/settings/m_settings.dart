import 'package:flutter/material.dart';

class MSettings extends StatefulWidget {
  const MSettings({super.key});

  @override
  State<MSettings> createState() => _MSettingsState();
}

class _MSettingsState extends State<MSettings> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Text("user settings"));
  }
}
