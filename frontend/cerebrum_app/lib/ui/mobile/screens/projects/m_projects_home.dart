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

  Future<void> addProject({
    required String name,
    required String description,
  }) async {
    try {
      final project = await ProjectsApi.createProject(
        name: name,
        description: description,
        domains: [],
        userGoals: [],
      );

      setState(() {
        projects.insert(0, project);
      });

      final newProject = Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => MProjectsPage(addMode: true)),
      );
      if (newProject != null) {
        setState(() => projects.insert(0, newProject));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("$e")));
    }
  }

  Future<void> fetchProjects() async {
    try {
      final data = await ProjectsApi.fetchProjects();
      setState(() => projects = data);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("$e")));
    }
  }

  void addProjectWidget() async {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder:
          (_) => Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
              left: 16,
              right: 16,
              top: 16,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Project Name'),
                ),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(labelText: 'Description'),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    addProject(
                      name: nameController.text,
                      description: descriptionController.text,
                    );
                  },
                  child: const Text("Create Project"),
                ),
              ],
            ),
          ),
    );
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
            title: Text(project['title'] ?? 'Untitled'),
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
          );
        },
      ),
    );
  }
}
