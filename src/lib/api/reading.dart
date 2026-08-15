import 'dart:convert';
import 'package:http/http.dart';
import 'api_config.dart';

class Reading {
  static String get baseUrl => ApiConfig.baseUrl;
  static String get readingEndpoint => "$baseUrl/suggested-reading";
}
