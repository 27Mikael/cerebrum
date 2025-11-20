import 'package:flutter/material.dart';
import 'package:cerebrum_app/api/projects_api.dart';
import 'package:cerebrum_app/ui/mobile/screens/projects/m_projects_page.dart';

class MProjectsHome extends StatefulWidget {
  const MProjectsHome({super.key});

  @override
  State<MProjectsHome> createState() => _MProjectsHomeState();
}

class _MProjectsHomeState extends State<MProjectsHome> {
  List<dynamic> projects = [];

  @override
  void initState() {
    super.initState();
    fetchProjects();
  }

  Future<void> fetchProjects() async {
    try {
      final data = await ProjectsApi.fetchProjects();
      setState(() => projects = data);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("$e")));
    }
  }

  Future<void> deleteProjects(projectId) async {
    try {
      await ProjectsApi.deleteProject(projectId);
      final updatedProjects = await ProjectsApi.fetchProjects();
      setState(() => projects = updatedProjects);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("$e")));
    }
  }

  void addProjectWidget() async {
    final newProject = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const MProjectsPage(addMode: true)),
    );

    // When creation page returns a project
    if (newProject != null) {
      setState(() => projects.insert(0, newProject));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: addProjectWidget,
        child: const Icon(Icons.add),
      ),
      body: ListView.builder(
        itemCount: projects.length,
        itemBuilder: (context, index) {
          final project = projects[index];
          return ListTile(
            title: Text(project['name'] ?? 'Untitled'),
            subtitle: Text(project['description'] ?? ''),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (_) => MProjectsPage(addMode: false, project: project),
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
                          title: const Text("Delete Project"),
                          content: const Text(
                            "Are you sure you want to delete this project",
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
                  await deleteProjects(project['id']);
                });
              },
            ),
          );
        },
      ),
    );
  }
}

