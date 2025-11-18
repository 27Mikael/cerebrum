import 'package:flutter/material.dart';

class MProjectsPage extends StatefulWidget {
  final bool addMode;

  const MProjectsPage({super.key, this.addMode = false});

  @override
  State<MProjectsPage> createState() => _MProjectsPageState();
}

class _MProjectsPageState extends State<MProjectsPage> {
  @override
  Widget build(BuildContext context) {
    if (widget.addMode) {
      return Scaffold(
        appBar: AppBar(title: const Text("Create Project")),
        body: const Center(child: Text("Project Creation UI here")),
      );
    }
    return const Scaffold();
  }
}
