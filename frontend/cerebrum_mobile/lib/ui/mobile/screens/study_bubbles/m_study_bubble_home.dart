import 'package:flutter/material.dart';
import 'package:cerebrum_app/api/bubbles_api.dart';
import 'package:cerebrum_app/ui/mobile/screens/study_bubbles/m_study_bubble_page.dart';

class MStudyBubbleHome extends StatefulWidget {
  const MStudyBubbleHome({super.key});

  @override
  State<MStudyBubbleHome> createState() => _MStudyBubbleHomeState();
}

class _MStudyBubbleHomeState extends State<MStudyBubbleHome> {
  List<dynamic> bubbles = [];

  @override
  void initState() {
    super.initState();
    fetchBubbles();
  }

  Future<void> fetchBubbles() async {
    try {
      final data = await BubblesApi.fetchBubbles();
      setState(() => bubbles = data);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("$e")));
    }
  }

  Future<void> deleteBubbles(bubbleId) async {
    try {
      await BubblesApi.deleteBubble(bubbleId);
      final updatedBubbles = await BubblesApi.fetchBubbles();
      setState(() => bubbles = updatedBubbles);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("$e")));
    }
  }

  void addBubbleWidget() async {
    final newBubble = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const MStudyBubblePage(addMode: true)),
    );

    // When creation page returns a project
    if (newBubble != null) {
      setState(() => bubbles.insert(0, newBubble));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: addBubbleWidget,
        child: const Icon(Icons.add),
      ),
      body: ListView.builder(
        itemCount: bubbles.length,
        itemBuilder: (context, index) {
          final bubble = bubbles[index];
          return ListTile(
            title: Text(bubble['name'] ?? 'Untitled'),
            subtitle: Text(bubble['description'] ?? ''),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (_) => MStudyBubblePage(addMode: false, bubble: bubble),
                ),
              );
            },
            trailing: IconButton(
              icon: const Icon(Icons.delete, color: Colors.grey),
              onPressed: () async {
                setState(() async {
                  // CONFIRMATION SCREEN
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder:
                        (context) => AlertDialog(
                          title: const Text("Delete Study Bubble"),
                          content: const Text(
                            "Are you sure you want to delete this study bubble",
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: const Text(
                                "Delete",
                                style: TextStyle(color: Colors.red),
                              ),
                            ),
                          ],
                        ),
                  );
                  if (confirm != true) return;
                  await deleteBubbles(bubble['id']);
                });
              },
            ),
          );
        },
      ),
    );
  }
}
