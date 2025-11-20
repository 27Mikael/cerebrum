import 'package:flutter/material.dart';
import 'package:cerebrum_app/ui/mobile/screens/projects/m_projects_home.dart';
import 'package:cerebrum_app/ui/mobile/screens/study_bubbles/m_study_bubble_home.dart';

class MLibraryPage extends StatefulWidget {
  const MLibraryPage({super.key});

  @override
  State<MLibraryPage> createState() => _MLibraryPageState();
}

class _MLibraryPageState extends State<MLibraryPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<Tab> tabs = const [
    Tab(text: "Projects"),
    Tab(text: "Study Bubbles"),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: tabs.length, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Library"),
        bottom: TabBar(controller: _tabController, tabs: tabs),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [MProjectsHome(), MStudyBubbleHome()],
      ),
    );
  }
}

