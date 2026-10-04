import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:notes_app_flutter/models/note.dart';
import 'package:notes_app_flutter/screens/auth_screen.dart';

void main() {
  group('Note model', () {
    test('fromJson корректно парсит данные', () {
      final note = Note.fromJson({
        'id': 1,
        'title': 'Заголовок',
        'text': 'Текст',
        'created_at': '2026-10-05T12:00:00',
      });
      expect(note.id, 1);
      expect(note.title, 'Заголовок');
      expect(note.text, 'Текст');
      expect(note.createdAt.year, 2026);
    });

    test('fromJson обрабатывает пустые title и text', () {
      final note = Note.fromJson({
        'id': 2,
        'title': null,
        'text': null,
        'created_at': null,
      });
      expect(note.title, '');
      expect(note.text, '');
    });
  });

  group('AuthScreen widgets', () {
    testWidgets('показывает поля Email и Пароль', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: AuthScreen(onLoggedIn: () {}),
      ));

      expect(find.text('Вход'), findsOneWidget);
      expect(find.widgetWithText(TextField, 'Email'), findsOneWidget);
      expect(find.widgetWithText(TextField, 'Пароль'), findsOneWidget);
      expect(find.text('Войти'), findsOneWidget);
    });

    testWidgets('переключается между Вход и Регистрация', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: AuthScreen(onLoggedIn: () {}),
      ));

      expect(find.text('Вход'), findsOneWidget);

      await tester.tap(find.text('Нет аккаунта? Зарегистрироваться'));
      await tester.pumpAndSettle();

      expect(find.text('Регистрация'), findsOneWidget);
      expect(find.text('Зарегистрироваться'), findsWidgets);
    });

    testWidgets('показывает ошибку при коротком пароле', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: AuthScreen(onLoggedIn: () {}),
      ));

      await tester.enterText(find.byType(TextField).at(0), 'test@example.com');
      await tester.enterText(find.byType(TextField).at(1), '123');
      await tester.tap(find.text('Войти'));
      await tester.pump();

      expect(find.textContaining('минимум 6 символов'), findsOneWidget);
    });
  });
}