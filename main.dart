import 'package:http/http.dart' as http;
import 'dart:convert';

// Пример получения списка заметок
Future<void> fetchNotes() async {
  final response = await http.get(Uri.parse('http://127.0.0.1:8000/notes/'));
  if (response.statusCode == 200) {
    List<dynamic> notes = jsonDecode(response.body);
    // Обновляем UI...
  }
}