import 'package:flutter/material.dart';
import 'package:cerebrum_app/api/projects_api.dart';
import 'package:cerebrum_app/features/notes/note_editor_page.dart';

class MProjectsPage extends StatefulWidget {
  final bool addMode;
  final Map<String, dynamic>? project;

  const MProjectsPage({super.key, this.addMode = false, this.project});

  @override
  State<MProjectsPage> createState() => _MProjectsPageState();
}

class _MProjectsPageState extends State<MProjectsPage> {
  List<dynamic> notes = [];
  late String projectId;
  final TextEditingController nameCtrl = TextEditingController();
  final TextEditingController descCtrl = TextEditingController();

  bool isLoading = false;

  @override
  void initState() {
    super.initState();

    if (!widget.addMode && widget.project != null) {
      projectId = widget.project!["id"];
      loadNotes(projectId);
    }
  }

  Future<void> loadNotes(projectId) async {
    try {
      final data = await ProjectNotesApi.fetchNotes(projectId);
      setState(() => notes = data);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("$e")));
    }
  }

  Future<void> addNote() async {
    try {
      final note = await ProjectNotesApi.createNote(
        projectId: projectId,
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

  Future<void> createProject() async {
    setState(() => isLoading = true);

    try {
      final result = await ProjectsApi.createProject(
        name: nameCtrl.text.trim(),
        description: descCtrl.text.trim(),
        domains: [],
        userGoals: [],
      );

      // return project back to previous screen
      Navigator.pop(context, result);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.addMode) {
      return Scaffold(
        appBar: AppBar(title: const Text("Create Project")),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(labelText: "Project Name"),
              ),
              TextField(
                controller: descCtrl,
                decoration: const InputDecoration(labelText: "Description"),
              ),
              const SizedBox(height: 20),
              isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                    onPressed: createProject,
                    child: const Text("Create"),
                  ),
            ],
          ),
        ),
      );
    }

    // FOR VIEW-MODE (Later you will add project details here)
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(widget.project?['name'] ?? "Project"),
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white, size: 32),
      ),
      // ADD NOTES
      floatingActionButton: FloatingActionButton(
        onPressed: addNote,
        child: const Icon(Icons.add),
      ),
      body: Stack(
        children: [
          //top content
          Padding(
            padding: const EdgeInsets.only(top: 80, left: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.project?['description'] ?? "",
                  style: TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),
          // bottom content
          DraggableScrollableSheet(
            initialChildSize: 0.70,
            minChildSize: 0.70,
            maxChildSize: 1,
            builder: (context, scrollController) {
              // NOTES DISPLAY SECTION
              return Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
                ),
                child: Padding(
                  padding: const EdgeInsets.only(top: 25),
                  child: ListView.builder(
                    controller: scrollController,
                    itemCount: notes.length,
                    itemBuilder: (context, index) {
                      final note = notes[index];
                      return ListTile(
                        title: Text(note["title"] ?? "Untitled"),
                        subtitle: Text(note["filename"] ?? ""),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => NoteEditorPage(note: note),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
