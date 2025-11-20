import 'package:flutter/material.dart';
import './note_editor_page.dart';
import '../../api/notes_api.dart';

class NotesPage extends StatefulWidget {
  const NotesPage({super.key});

  @override
  State<NotesPage> createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {
  List<dynamic> notes = [];

  @override
  void initState() {
    super.initState();
    loadNotes();
  }

  Future<void> loadNotes() async {
    try {
      final data = await NotesApi.fetchNotes();
      setState(() => notes = data);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("$e")));
    }
  }

  Future<void> addNote() async {
    try {
      final note = await NotesApi.createNote(
        title: "Untitled Note",
        content: " # Untitled Note\n\n",
      );

      setState(() {
        notes.insert(0, note);
      });

      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => NoteEditorPage(note: note)),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("$e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Notes")),
      body: ListView.builder(
        itemCount: notes.length,
        itemBuilder: (context, index) {
          final note = notes[index];
          return ListTile(
            title: Text(note["title"] ?? "Untitled"),
            subtitle: Text(note["filename"] ?? ""),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => NoteEditorPage(note: note)),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: addNote,
        child: Icon(Icons.add),
      ),
    );
  }
}
