import 'dart:convert';
import 'package:http/http.dart' as http;

class ProjectsApi {
  static const baseUrl = "http://localhost:8000";
  static const String projectsEndpoint = "$baseUrl/projects";

  // list all projects
  static Future<List<dynamic>> fetchProjects() async {
    final response = await http.get(Uri.parse("$projectsEndpoint/"));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to fetch projects");
    }
  }

  // fetch a project
  static Future<Map<String, dynamic>> fetchProjectById(String projectId) async {
    final response = await http.get(Uri.parse("$projectsEndpoint/$projectId"));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Project not found");
    }
  }

  // create a new project
  static Future<Map<String, dynamic>> createProject({
    required String name,
    required String description,
    required List<String> domains,
    required List<String> userGoals,
  }) async {
    final project = {
      "name": name,
      "description": description,
      "domains": domains,
      "user_goals": userGoals,
    };

    final response = await http.post(
      Uri.parse("$projectsEndpoint/create"),

      headers: {"Content-Type": "application/json"},
      body: jsonEncode(project),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to create project ${response.statusCode}");
    }
  }

  // delete a project
  static Future<void> deleteProject(String projectId) async {
    final response = await http.delete(
      Uri.parse("$projectsEndpoint/$projectId"),
    );

    if (response.statusCode != 200 &&
        response.statusCode != 204 &&
        response.statusCode != 202) {
      throw Exception("Failed to delete project");
    }
  }
}

class ProjectNotesApi {
  static const baseUrl = "http://localhost:8000";

  static String notesApi(String projectId) {
    return "$baseUrl/projects/$projectId/notes";
  }

  // list all notes
  static Future<List<dynamic>> fetchNotes(String projectId) async {
    final response = await http.get(Uri.parse(notesApi(projectId)));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to fetch notes");
    }
  }

  // fetch a note
  static Future<Map<String, dynamic>> fetchNoteByFileName(
    String projectId,
    String filename,
  ) async {
    final response = await http.get(
      Uri.parse("${notesApi(projectId)}/get/$filename"),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Note not found");
    }
  }

  // create a new note
  static Future<Map<String, dynamic>> createNote({
    required String projectId,
    required String title,
    required String content,
  }) async {
    final note = {"title": title, "content": content};

    final response = await http.post(
      Uri.parse("${notesApi(projectId)}/create"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(note),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to create note");
    }
  }

  // update a note
  static Future<Map<String, dynamic>> updateNote({
    required String projectId,
    required String filename,
    required String title,
    required String content,
  }) async {
    final note = {"title": title, "content": content};

    final response = await http.put(
      Uri.parse("${notesApi(projectId)}/update/$filename"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(note),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to update note");
    }
  }

  // delete a note
  static Future<void> deleteNote(String projectId, String filename) async {
    final response = await http.delete(
      Uri.parse("${notesApi(projectId)}/delete/$filename"),
    );

    if (response.statusCode != 200 &&
        response.statusCode != 204 &&
        response.statusCode != 202) {
      throw Exception("Failed to delete note");
    }
  }
}

class ProjectChatApi {
  static const baseUrl = "http://localhost:8000";

  /// Helper to build the base project chat endpoint
  static String chatApi(String projectId) {
    return "$baseUrl/projects/$projectId/chat";
  }

  /// Send a chat query to the LLM for this project
  static Future<Map<String, dynamic>> sendMessage({
    required String projectId,
    required String message,
  }) async {
    final body = {"query": message};

    final response = await http.post(
      Uri.parse(chatApi(projectId)),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }

    throw Exception(
      "Chat request failed (${response.statusCode}): ${response.body}",
    );
  }

  /// Retrieve past chat history for a project
  static Future<List<dynamic>> fetchChatHistory(String projectId) async {
    final response = await http.get(Uri.parse("${chatApi(projectId)}/history"));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }

    throw Exception("Failed to fetch chat history (${response.statusCode})");
  }

  /// Clear the chat history for a project
  static Future<void> clearChatHistory(String projectId) async {
    final response = await http.delete(
      Uri.parse("${chatApi(projectId)}/clear"),
    );

    if (response.statusCode != 200 &&
        response.statusCode != 204 &&
        response.statusCode != 202) {
      throw Exception("Failed to clear chat history (${response.statusCode})");
    }
  }
}
