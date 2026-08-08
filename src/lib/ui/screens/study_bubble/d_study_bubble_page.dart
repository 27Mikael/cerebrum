import 'package:flutter/material.dart';
import 'package:cerebrum_app/api/bubbles_api.dart';
import 'package:cerebrum_app/ui/editor/editor_scaffold.dart';
import 'package:cerebrum_app/ui/widgets/editable_title.dart';

class DStudyBubblePage extends StatefulWidget {
  final bool addMode;
  final Map<String, dynamic>? bubble;
  final VoidCallback? onBack;

  const DStudyBubblePage({
    super.key,
    this.addMode = false,
    this.bubble,
    this.onBack,
  });

  @override
  State<DStudyBubblePage> createState() => _DStudyBubblePageState();
}

class _DStudyBubblePageState extends State<DStudyBubblePage> {
  List<Map<String, dynamic>> notes = [];
  late String bubbleId;
  final TextEditingController nameCtrl = TextEditingController();
  final TextEditingController descCtrl = TextEditingController();
  bool isLoading = false;

  // Filename of whichever note row currently has a fetch-full-note request
  // in flight, so the tapped tile can show a spinner instead of the whole
  // list looking frozen while we go get its ink.
  String? _openingFilename;

  @override
  void initState() {
    super.initState();

    if (!widget.addMode && widget.bubble != null) {
      bubbleId = widget.bubble!["id"].toString();
      loadNotes(bubbleId);
    }
  }

  // -----------------------
  // Load notes
  // -----------------------
  // NOTE: this hits the LIST endpoint, which deliberately returns
  // `ink: []` for every note (see backend comment on list_notes_in_bubble
  // — ink is intentionally excluded from the list response to keep it
  // cheap). Never build an EditorScaffold's `note:` param straight from
  // an entry in `notes` — go through `_openNote` below instead, which
  // fetches the detail endpoint first.
  Future<void> loadNotes(String bubbleId) async {
    try {
      final data = await BubbleNotesApi.fetchNotes(bubbleId);

      // Ensure each note has bubbleId and proper content structure
      for (var note in data) {
        // Ensure bubbleId is set
        note['bubble_id'] = bubbleId;

        // Ensure content has document key
        if (note['content'] is Map &&
            !note['content'].containsKey('document')) {
          note['content'] = {'document': note['content']};
        }
      }

      setState(() => notes = List<Map<String, dynamic>>.from(data));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("$e")));
      }
    }
  }

  // -----------------------
  // Open an existing note in the editor
  // -----------------------
  // Fetches the full note (content + ink) via the detail endpoint before
  // navigating, since the list-view `note` map passed in here always has
  // `ink: []`. This is the fix for ink not loading when reopening a note.
  Future<void> _openNote(Map<String, dynamic> listNote) async {
    final filename = listNote['filename'] as String?;
    if (filename == null) return;

    setState(() => _openingFilename = filename);

    try {
      final fullNote = await BubbleNotesApi.fetchNoteByFileName(
        bubbleId,
        filename,
      );
      fullNote['bubble_id'] = bubbleId;

      if (!mounted) return;

      await Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => EditorScaffold(note: fullNote)),
      );

      // Reload notes when returning from editor
      loadNotes(bubbleId);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Failed to open note: $e")));
      }
    } finally {
      if (mounted) setState(() => _openingFilename = null);
    }
  }

  // -----------------------
  // Add a new note
  // -----------------------
  Future<void> addNote() async {
    try {
      // 1️⃣ Blank AppFlowy document structure
      final Map<String, dynamic> blankDoc = {
        "document": {
          "type": "page",
          "children": [
            {
              "type": "paragraph",
              "data": {
                "delta": [
                  {"insert": ""},
                ],
              },
            },
          ],
        },
      };

      // 2️⃣ Payload for backend - only include fields backend expects
      final Map<String, dynamic> notePayload = {
        "title": "Untitled Note",
        "content": blankDoc,
        "ink": <Map<String, dynamic>>[],
      };

      // 3️⃣ Create note in backend with proper type casts
      final Map<String, dynamic> createdNote = await BubbleNotesApi.createNote(
        bubbleId: bubbleId,
        title: notePayload['title'] as String,
        content: notePayload['content'] as Map<String, dynamic>,
        ink:
            (notePayload['ink'] as List<dynamic>)
                .map((e) => e as Map<String, dynamic>)
                .toList(),
      );

      // 4️⃣ Build frontend note object
      // (createNote returns the full note it just wrote, including real
      // ink — [] here, since it's brand new — so this one's fine as-is;
      // it's not the ink-stripped list-endpoint shape.)
      final Map<String, dynamic> newNote = {
        "title": createdNote['title'] as String,
        "content": createdNote['content'] as Map<String, dynamic>,
        "ink":
            (createdNote['ink'] as List<dynamic>)
                .map((e) => e as Map<String, dynamic>)
                .toList(),
        "filename": createdNote['filename'] as String,
        "bubble_id": bubbleId,
      };

      // 5️⃣ Insert into local notes list
      setState(() {
        notes.insert(0, newNote);
      });

      // 6️⃣ Open editor
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (_) => EditorScaffold(
                  note: newNote,
                  initialTextJson: newNote['content'],
                  initialInkJson: List<Map<String, dynamic>>.from(
                    newNote['ink'],
                  ),
                ),
          ),
        ).then((_) {
          // Reload notes after returning from editor
          loadNotes(bubbleId);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("$e")));
      }
    }
  }

  // -----------------------
  //  Rename a note
  // -----------------------
  Future<void> renameNote(
    String bubbleId,
    String oldFilename,
    String newFilename,
  ) async {
    try {
      await BubbleNotesApi.renameNote(bubbleId, oldFilename, newFilename);
      await loadNotes(bubbleId);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("$e")));
      }
    }
  }

  // -----------------------
  // Delete note
  // -----------------------
  Future<void> deleteNote(String bubbleId, String filename) async {
    try {
      await BubbleNotesApi.deleteNote(bubbleId, filename);
      await loadNotes(bubbleId);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("$e")));
      }
    }
  }

  // -----------------------
  // Create bubble (add mode)
  // -----------------------
  Future<void> createBubble() async {
    setState(() => isLoading = true);
    try {
      final result = await BubblesApi.createBubble(
        name: nameCtrl.text.trim(),
        description: descCtrl.text.trim(),
        domains: [],
        userGoals: [],
      );
      if (mounted) {
        Navigator.pop(context, result);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("$e")));
      }
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.addMode) {
      return Scaffold(
        appBar: AppBar(title: const Text("Create Study Bubble")),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(labelText: "Bubble Name"),
              ),
              TextField(
                controller: descCtrl,
                decoration: const InputDecoration(labelText: "Description"),
              ),
              const SizedBox(height: 20),
              isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                    onPressed: createBubble,
                    child: const Text("Create"),
                  ),
            ],
          ),
        ),
      );
    }

    // Desktop view
    return Scaffold(
      backgroundColor: Colors.black,
      body: Row(
        children: [
          // CENTER: notes list
          Expanded(
            flex: 2,
            child: Container(
              color: Colors.white,
              child: ListView.builder(
                itemCount: notes.length + 1,
                itemBuilder: (context, index) {
                  if (index == 0) {
                    // TODO: add rename buttom
                    return ListTile(
                      leading: const Icon(Icons.add, color: Colors.blue),
                      title: const Text(
                        "Add New Note",
                        style: TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      onTap: addNote,
                    );
                  }

                  final note = notes[index - 1];
                  final isOpening = _openingFilename == note['filename'];

                  return ListTile(
                    key: ValueKey(note["filename"]),
                    title: EditableTitle(
                      initialTitle: note['title'] ?? 'Untitled',
                      onTitleChanged: (newTitle) async {
                        if (newTitle.isNotEmpty && newTitle != note['title']) {
                          final oldTitle = note['filename'];
                          setState(() {
                            note['title'] = newTitle;
                          });
                          await renameNote(bubbleId, oldTitle, newTitle);
                        }
                      },
                    ),
                    subtitle: Text(
                      note["filename"] ?? "",
                      style: TextStyle(fontSize: 12),
                    ),
                    // Was previously: build EditorScaffold directly from
                    // `note` (the list-view entry, ink always []). Now
                    // routes through `_openNote`, which fetches the full
                    // note — content + real ink — via the detail endpoint
                    // first.
                    onTap: isOpening ? null : () => _openNote(note),
                    trailing:
                        isOpening
                            ? const Padding(
                              padding: EdgeInsets.all(12),
                              child: SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              ),
                            )
                            : IconButton(
                              icon: const Icon(Icons.delete_rounded),
                              onPressed: () async {
                                final confirm = await showDialog<bool>(
                                  context: context,
                                  builder:
                                      (dialogContext) => AlertDialog(
                                        title: const Text("Delete Note"),
                                        content: const Text(
                                          "Are you sure you want to delete this note?",
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed:
                                                () => Navigator.of(
                                                  dialogContext,
                                                ).pop(true),
                                            child: const Text(
                                              "Delete",
                                              style: TextStyle(
                                                color: Colors.red,
                                              ),
                                            ),
                                          ),
                                          TextButton(
                                            onPressed:
                                                () => Navigator.of(
                                                  dialogContext,
                                                ).pop(false),
                                            child: const Text("Cancel"),
                                          ),
                                        ],
                                      ),
                                );

                                if (confirm == true) {
                                  await deleteNote(bubbleId, note["filename"]);
                                }
                              },
                            ),
                  );
                },
              ),
            ),
          ),

          // RIGHT: bubble info
          Container(
            width: 400,
            color: Colors.black,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.arrow_back, color: Colors.white),
                      tooltip: "Back to Study Bubbles",
                      onPressed: () {
                        if (widget.onBack != null) {
                          widget.onBack!();
                        } else {
                          Navigator.pop(context);
                        }
                      },
                    ),
                    Text(
                      widget.bubble?['name'] ?? "No name",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  widget.bubble?['description'] ?? "No description yet.",
                  style: const TextStyle(color: Colors.white),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
