import 'dart:convert';
import 'package:http/http.dart' as http;

class NotesApi {
  static const baseUrl = "http://localhost:8000";
  static const String notesEndpoint = "$baseUrl/{projects_id}/notes";

  // list all notes
  static Future<List<dynamic>> fetchNotes() async {
    final response = await http.get(Uri.parse(notesEndpoint));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to fetch notes");
    }
  }

  // fetch a note
  static Future<Map<String, dynamic>> fetchNoteByFileName(
    String filename,
  ) async {
    final response = await http.get(Uri.parse("$notesEndpoint/$filename"));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Note not found");
    }
  }

  // create a new note
  static Future<Map<String, dynamic>> createNote({
    required String title,
    required String content,
  }) async {
    final note = {"title": title, "content": content};

    final response = await http.post(
      Uri.parse("$notesEndpoint/create"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(note),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to create note ${response.statusCode}");
    }
  }

  // upate a note
  static Future<Map<String, dynamic>> updateNote({
    required String filename,
    required String title,
    required String content,
  }) async {
    final note = {"title": title, "content": content};

    final response = await http.put(
      Uri.parse("$notesEndpoint/$filename"),
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
  static Future<void> deleteNote(String filename) async {
    final response = await http.delete(Uri.parse("$notesEndpoint/$filename"));
    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception("Failed to delete note");
    }
  }
}
