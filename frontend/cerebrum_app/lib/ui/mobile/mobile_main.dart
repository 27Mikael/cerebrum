import 'package:cerebrum_app/features/home/home_page.dart';
import 'package:cerebrum_app/features/notes/note_page.dart';
import 'package:cerebrum_app/features/chat/chat.dart';
import 'package:cerebrum_app/ui/mobile/screens/study_bubbles/m_study_bubble_home.dart';
import 'package:cerebrum_app/ui/mobile/screens/study_bubbles/m_study_bubble_page.dart';
import 'package:flutter/material.dart';

class MobileUI extends StatefulWidget {
  const MobileUI({super.key});

  @override
  State<MobileUI> createState() => _MobileUIState();
}

class _MobileUIState extends State<MobileUI> {
  int selectedPage = 0;

  void changePage(int index) => setState(() => selectedPage = index);

  Widget _buildPage() {
    switch (selectedPage) {
      case 0:
        return HomePage();
      case 1:
        // replace with librarypage
        return MStudyBubbleHome();
      case 2:
        return Text("User Settings");
      default:
        return Center(child: Text("Unknown Page"));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildPage(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedPage,
        onTap: changePage,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.note_rounded),
            label: 'Studdy Bubble',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_rounded),
            label: 'Projects',
          ),
        ],
      ),
    );
  }
}
