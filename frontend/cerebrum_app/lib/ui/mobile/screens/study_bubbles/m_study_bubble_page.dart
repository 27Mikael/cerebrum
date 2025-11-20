import 'package:flutter/material.dart';

class MStudyBubblePage extends StatefulWidget {
  final bool addMode;

  const MStudyBubblePage({super.key, this.addMode = false});

  @override
  State<MStudyBubblePage> createState() => _MStudyBubblePageState();
}

class _MStudyBubblePageState extends State<MStudyBubblePage> {
  @override
  Widget build(BuildContext context) {
    if (widget.addMode) {
      return (Scaffold(
        appBar: AppBar(title: const Text("Create Study Bubble")),
        body: const Center(child: Text("Project Creation UI here")),
      ));
    }
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          //top content
          Padding(
            padding: const EdgeInsets.only(top: 80, left: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Study Bubble name goes here",
                  style: TextStyle(color: Colors.white),
                ),
                Text(
                  "Description goes here",
                  style: TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),
          // bottom content
          DraggableScrollableSheet(
            initialChildSize: 0.65,
            minChildSize: 0.65,
            maxChildSize: 1,
            builder: (context, scrollController) {
              return Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(35)),
                ),
                child: ListView(
                  controller: scrollController,
                  children: [
                    const SizedBox(height: 20),
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
