import 'package:flutter/material.dart';

class MHomeScreen extends StatefulWidget {
  const MHomeScreen({super.key});

  @override
  State<MHomeScreen> createState() => _MHomeScreenState();
}

class _MHomeScreenState extends State<MHomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [Text("suggested reading"), Text("Upcoming quizzes")],
      ),
    );
  }
}
