import 'package:flutter/material.dart';
import 'package:cerebrum_app/ui/mobile/screens/m_library_page.dart';
import 'package:cerebrum_app/ui/mobile/screens/home/m_home_screen.dart';
import 'package:cerebrum_app/ui/mobile/screens/settings/m_settings.dart';

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
        return MHomeScreen();
      case 1:
        // replace with librarypage
        return MLibraryPage();
      case 2:
        return MSettings();
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
            icon: Icon(Icons.library_books_rounded),
            label: 'Library',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
