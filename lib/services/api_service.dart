import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/note.dart';
import 'token_store.dart';

const String baseUrl = 'http://127.0.0.1:8000';

class ApiService {
  static Future<Map<String, String>> _headers({bool json = true}) async {
    final h = <String, String>{};
    if (json) h['Content-Type'] = 'application/json';
    final t = await TokenStore.load();
    if (t != null) h['Authorization'] = 'Bearer $t';
    return h;
  }

  // --- Auth ---
  static Future<void> register(String email, String password) async {
    final r = await http.post(
      Uri.parse('$baseUrl/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );
    if (r.statusCode != 200) {
      final msg = jsonDecode(utf8.decode(r.bodyBytes))['detail'] ?? 'Ошибка';
      throw Exception(msg);
    }
    final token = jsonDecode(r.body)['access_token'];
    await TokenStore.save(token);
  }

  static Future<void> login(String email, String password) async {
    final r = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: {'username': email, 'password': password},
    );
    if (r.statusCode != 200) {
      final msg = jsonDecode(utf8.decode(r.bodyBytes))['detail'] ?? 'Ошибка';
      throw Exception(msg);
    }
    final token = jsonDecode(r.body)['access_token'];
    await TokenStore.save(token);
  }

  static Future<void> logout() => TokenStore.clear();

  static Future<bool> isLoggedIn() async {
    final t = await TokenStore.load();
    return t != null;
  }

  // --- Notes ---
  static Future<List<Note>> fetchNotes({
    String? search,
    String sort = 'date_desc',
  }) async {
    final params = <String, String>{'sort': sort};
    if (search != null && search.isNotEmpty) params['search'] = search;
    final uri = Uri.parse('$baseUrl/notes/').replace(queryParameters: params);
    final r = await http.get(uri, headers: await _headers(json: false));
    if (r.statusCode == 401) throw Exception('UNAUTHORIZED');
    if (r.statusCode != 200) throw Exception('Ошибка ${r.statusCode}');
    final List data = jsonDecode(utf8.decode(r.bodyBytes));
    return data.map((j) => Note.fromJson(j)).toList();
  }

  static Future<void> createNote(String title, String text) async {
    final r = await http.post(
      Uri.parse('$baseUrl/notes/'),
      headers: await _headers(),
      body: jsonEncode({'title': title, 'text': text}),
    );
    if (r.statusCode == 401) throw Exception('UNAUTHORIZED');
    if (r.statusCode != 200) throw Exception('Ошибка ${r.statusCode}');
  }

  static Future<void> updateNote(int id, {String? title, String? text}) async {
    final body = <String, dynamic>{};
    if (title != null) body['title'] = title;
    if (text != null) body['text'] = text;
    final r = await http.put(
      Uri.parse('$baseUrl/notes/$id'),
      headers: await _headers(),
      body: jsonEncode(body),
    );
    if (r.statusCode == 401) throw Exception('UNAUTHORIZED');
    if (r.statusCode != 200) throw Exception('Ошибка ${r.statusCode}');
  }

  static Future<void> deleteNote(int id) async {
    final r = await http.delete(
      Uri.parse('$baseUrl/notes/$id'),
      headers: await _headers(json: false),
    );
    if (r.statusCode == 401) throw Exception('UNAUTHORIZED');
    if (r.statusCode != 200) throw Exception('Ошибка ${r.statusCode}');
  }
}