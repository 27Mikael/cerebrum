import 'package:cerebrum_app/features/chat/chat.dart';
import 'package:flutter/material.dart';
import './features/home/home_page.dart';

class Cerebrum extends StatefulWidget {
  const Cerebrum({super.key});

  @override
  State<Cerebrum> createState() => _CerebrumState();
}

class _CerebrumState extends State<Cerebrum> {
  int selectedPage = 0;

  void changePage(int page) {
    setState(() {
      selectedPage = page;
    });
  }

  Widget _buildPage() {
    if (selectedPage == 0) {
      return HomePage();
    } else if (selectedPage == 1) {
      return Center(child: Text('Learn'));
    } else if (selectedPage == 2) {
      return Center(child: Text("Mika Stinks,Also, Cugushi"));
    } else if (selectedPage == 3) {
      return ChatPage();
    }

    return Center(child: Text('Unknown Page'));
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Colors.black,
        body: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Left side: buttons
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  TextButton(
                    style: ButtonStyle(
                      foregroundColor: WidgetStateProperty.all<Color>(
                        Colors.blue,
                      ),
                    ),
                    onPressed: () => changePage(0),
                    child: Text('Home'),
                  ),
                  TextButton(
                    style: ButtonStyle(
                      foregroundColor: WidgetStateProperty.all<Color>(
                        Colors.blue,
                      ),
                    ),
                    onPressed: () => changePage(1),
                    child: Text('Learn'),
                  ),
                  TextButton(
                    style: ButtonStyle(
                      foregroundColor: WidgetStateProperty.all<Color>(
                        Colors.blue,
                      ),
                    ),
                    onPressed: () => changePage(2),
                    child: Text("Review"),
                  ),
                  TextButton(
                    style: ButtonStyle(
                      foregroundColor: WidgetStateProperty.all<Color>(
                        Colors.blue,
                      ),
                    ),
                    onPressed: () => changePage(3),
                    child: Text("Chat"),
                  ),
                ],
              ),

              SizedBox(width: 12), // spacing between buttons and window
              // Right side: main window
              Expanded(
                child: Container(
                  height: MediaQuery.of(context).size.height * 0.98,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: _buildPage(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
