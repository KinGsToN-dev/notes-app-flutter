import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'screens/notes_page.dart';
import 'screens/auth_screen.dart';
import 'services/api_service.dart';

void main() => runApp(const MyApp());

class MyApp extends StatefulWidget {
  const MyApp({super.key});
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool darkMode = false;
  bool? loggedIn;

  @override
  void initState() {
    super.initState();
    _check();
  }

  Future<void> _check() async {
    final v = await ApiService.isLoggedIn();
    setState(() => loggedIn = v);
  }

  @override
  Widget build(BuildContext context) {
    if (loggedIn == null) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: darkMode ? AppTheme.dark : AppTheme.light,
        home: const Scaffold(body: Center(child: CircularProgressIndicator())),
      );
    }
    return MaterialApp(
      title: 'Заметки',
      debugShowCheckedModeBanner: false,
      theme: darkMode ? AppTheme.dark : AppTheme.light,
      home: loggedIn!
          ? NotesPage(
              darkMode: darkMode,
              onToggleTheme: () => setState(() => darkMode = !darkMode),
              onLogout: () async {
                await ApiService.logout();
                setState(() => loggedIn = false);
              },
            )
          : AuthScreen(onLoggedIn: () => setState(() => loggedIn = true)),
    );
  }
}