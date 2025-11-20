import 'dart:async';
import 'package:flutter/material.dart';
import '../../api/notes_api.dart';

class NoteEditorPage extends StatefulWidget {
  final Map<String, dynamic> note;
  const NoteEditorPage({super.key, required this.note});

  @override
  State<NoteEditorPage> createState() => _NoteEditorPageState();
}

class _NoteEditorPageState extends State<NoteEditorPage> {
  late TextEditingController _controller;
  Timer? _debounce;
  bool isSaving = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.note["content"]);

    // Listen for typing
    _controller.addListener(() {
      _onTextChanged();
    });
  }

  void _onTextChanged() {
    // Cancel existing timer
    _debounce?.cancel();

    // Wait for user to stop typing for 1 second
    _debounce = Timer(const Duration(seconds: 1), () async {
      await _saveNote();
    });
  }

  Future<void> _saveNote() async {
    setState(() => isSaving = true);
    try {
      await NotesApi.updateNote(
        filename: widget.note["filename"],
        title: widget.note["title"],
        content: _controller.text,
      );
    } catch (e) {
      debugPrint("Failed to save note: $e");
    } finally {
      setState(() => isSaving = false);
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.note["title"]),
        actions: [
          if (isSaving)
            const Padding(
              padding: EdgeInsets.only(right: 16),
              child: Center(
                child: SizedBox(
                  width: 12,
                  height: 12,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: TextField(
          controller: _controller,
          maxLines: null,
          keyboardType: TextInputType.multiline,
          decoration: const InputDecoration(border: InputBorder.none),
        ),
      ),
    );
  }
}
