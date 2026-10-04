# 📝 Notes App — Full-Stack CRUD

Полноценное приложение для заметок: **Flutter + FastAPI + SQLite + JWT**.

# 📝 Notes App — Full-Stack CRUD

![Backend Tests](https://github.com/KinGsToN-dev/notes-app-flutter/actions/workflows/backend-tests.yml/badge.svg)
![Flutter Tests](https://github.com/KinGsToN-dev/notes-app-flutter/actions/workflows/flutter-tests.yml/badge.svg)

Полноценное приложение для заметок: **Flutter + FastAPI + SQLite + JWT**.
...
## ✨ Возможности

- 🔐 Регистрация и вход (JWT, bcrypt)
- 👤 Изоляция данных: каждый пользователь видит только свои заметки
- 📝 CRUD: создание, чтение, обновление, удаление
- 🔍 Поиск по заголовку и тексту
- 🔀 Сортировка: по дате (↑↓) и по алфавиту (А→Я, Я→А)
- 🌙 Светлая / тёмная тема
- 🎬 Анимации, свайп-удаление, SnackBar-уведомления

## 🏗️ Стек

| Слой | Технологии |
|---|---|
| Frontend | Flutter, Dart, http, shared_preferences, intl |
| Backend | Python 3.12, FastAPI, SQLModel, python-jose, bcrypt |
| БД | SQLite (легко заменить на PostgreSQL) |
| Тесты | pytest (18 тестов), flutter_test (5 тестов) |

## 🚀 Быстрый старт

### Backend
```bash
cd backend
pip install fastapi uvicorn sqlmodel "python-jose[cryptography]" bcrypt email-validator
uvicorn main:app --reload
API будет доступно на http://127.0.0.1:8000, документация — http://127.0.0.1:8000/docs

Frontend
bash
flutter pub get
flutter run -d chrome
🧪 Тесты
bash
# Backend
cd backend
python -m pytest

# Frontend
flutter test
📁 Структура
text
notes_app_flutter/
├── backend/
│   ├── main.py              # FastAPI приложение
│   └── tests/               # pytest тесты
├── lib/
│   ├── models/              # Note
│   ├── services/            # API, TokenStore
│   ├── screens/             # AuthScreen, NotesPage
│   └── theme/               # AppTheme
└── test/                    # flutter_test
📸 Скриншоты
(добавьте сюда скриншоты тёмной и светлой темы)

📄 Лицензия
MIT