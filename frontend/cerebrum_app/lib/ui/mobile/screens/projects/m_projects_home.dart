import 'package:flutter/material.dart';

class MStudyBubbleHome extends StatefulWidget {
  const MStudyBubbleHome({super.key});

  @override
  State<MStudyBubbleHome> createState() => _MStudyBubbleHomeState();
}

class _MStudyBubbleHomeState extends State<MStudyBubbleHome> {
  List<Map<String, dynamic>> bubbles = [];

  @override
  void initState() {
    super.initState();
    fetchBubbles();
  }

  Future<void> fetchBubbles() async {
    // TODO: Replace with your API call
    await Future.delayed(const Duration(milliseconds: 100));
    setState(() {
      bubbles = [
        {'title': 'Bubble 1', 'description': 'Description 1'},
        {'title': 'Bubble 2', 'description': 'Description 2'},
      ];
    });
  }

  void addBubble() async {
    await showModalBottomSheet(
      context: context,
      builder:
          (_) => SizedBox(
            height: 150,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ListTile(
                  leading: const Icon(Icons.add),
                  title: const Text("Add Study Bubble"),
                  onTap: () {
                    Navigator.pop(context);
                    // TODO: call API to create bubble
                    fetchBubbles(); // refresh list after creation
                  },
                ),
              ],
            ),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: addBubble,
        child: const Icon(Icons.add),
      ),
      body: ListView.builder(
        itemCount: bubbles.length,
        itemBuilder: (context, index) {
          final bubble = bubbles[index];
          return ListTile(
            title: Text(bubble['title'] ?? 'Untitled'),
            subtitle: Text(bubble['description'] ?? ''),
            onTap: () {
              // Optional: open bubble detail
            },
          );
        },
      ),
    );
  }
}
