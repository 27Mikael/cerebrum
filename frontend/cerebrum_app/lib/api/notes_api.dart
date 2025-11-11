import 'dart:convert';
import 'package:http/http.dart' as http;

const String API_BASE = "http://localhost:8000";

Future<String> fetchNotes(String question) async {
  final url = Uri.parse("http://localhost:8000/");
  final response = await http.post(
  url,
    headers: {"Content-Type": "application/json"},
    body: jsonEncode({"question": question),
  );

  if (response.statusCode == 200) {
    }
}
