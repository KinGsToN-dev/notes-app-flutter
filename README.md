# рџ“ќ Notes App вЂ” Full-Stack CRUD

РџРѕР»РЅРѕС†РµРЅРЅРѕРµ РїСЂРёР»РѕР¶РµРЅРёРµ РґР»СЏ Р·Р°РјРµС‚РѕРє: **Flutter + FastAPI + SQLite + JWT**.

# рџ“ќ Notes App вЂ” Full-Stack CRUD

![Backend Tests](https://github.com/KinGsToN-dev/notes-app-flutter/actions/workflows/backend-tests.yml/badge.svg)
![Flutter Tests](https://github.com/KinGsToN-dev/notes-app-flutter/actions/workflows/flutter-tests.yml/badge.svg)

РџРѕР»РЅРѕС†РµРЅРЅРѕРµ РїСЂРёР»РѕР¶РµРЅРёРµ РґР»СЏ Р·Р°РјРµС‚РѕРє: **Flutter + FastAPI + SQLite + JWT**.
...
## вњЁ Р’РѕР·РјРѕР¶РЅРѕСЃС‚Рё

- рџ”ђ Р РµРіРёСЃС‚СЂР°С†РёСЏ Рё РІС…РѕРґ (JWT, bcrypt)
- рџ‘¤ РР·РѕР»СЏС†РёСЏ РґР°РЅРЅС‹С…: РєР°Р¶РґС‹Р№ РїРѕР»СЊР·РѕРІР°С‚РµР»СЊ РІРёРґРёС‚ С‚РѕР»СЊРєРѕ СЃРІРѕРё Р·Р°РјРµС‚РєРё
- рџ“ќ CRUD: СЃРѕР·РґР°РЅРёРµ, С‡С‚РµРЅРёРµ, РѕР±РЅРѕРІР»РµРЅРёРµ, СѓРґР°Р»РµРЅРёРµ
- рџ”Ќ РџРѕРёСЃРє РїРѕ Р·Р°РіРѕР»РѕРІРєСѓ Рё С‚РµРєСЃС‚Сѓ
- рџ”Ђ РЎРѕСЂС‚РёСЂРѕРІРєР°: РїРѕ РґР°С‚Рµ (в†‘в†“) Рё РїРѕ Р°Р»С„Р°РІРёС‚Сѓ (Рђв†’РЇ, РЇв†’Рђ)
- рџЊ™ РЎРІРµС‚Р»Р°СЏ / С‚С‘РјРЅР°СЏ С‚РµРјР°
- рџЋ¬ РђРЅРёРјР°С†РёРё, СЃРІР°Р№Рї-СѓРґР°Р»РµРЅРёРµ, SnackBar-СѓРІРµРґРѕРјР»РµРЅРёСЏ

## рџЏ—пёЏ РЎС‚РµРє

| РЎР»РѕР№ | РўРµС…РЅРѕР»РѕРіРёРё |
|---|---|
| Frontend | Flutter, Dart, http, shared_preferences, intl |
| Backend | Python 3.12, FastAPI, SQLModel, python-jose, bcrypt |
| Р‘Р” | SQLite (Р»РµРіРєРѕ Р·Р°РјРµРЅРёС‚СЊ РЅР° PostgreSQL) |
| РўРµСЃС‚С‹ | pytest (18 С‚РµСЃС‚РѕРІ), flutter_test (5 С‚РµСЃС‚РѕРІ) |

## рџљЂ Р‘С‹СЃС‚СЂС‹Р№ СЃС‚Р°СЂС‚

### Backend
```bash
cd backend
pip install fastapi uvicorn sqlmodel "python-jose[cryptography]" bcrypt email-validator
uvicorn main:app --reload
API Р±СѓРґРµС‚ РґРѕСЃС‚СѓРїРЅРѕ РЅР° http://127.0.0.1:8000, РґРѕРєСѓРјРµРЅС‚Р°С†РёСЏ вЂ” http://127.0.0.1:8000/docs

Frontend
bash
flutter pub get
flutter run -d chrome
рџ§Є РўРµСЃС‚С‹
bash
# Backend
cd backend
python -m pytest

# Frontend
flutter test
рџ“Ѓ РЎС‚СЂСѓРєС‚СѓСЂР°
text
notes_app_flutter/
в”њв”Ђв”Ђ backend/
в”‚   в”њв”Ђв”Ђ main.py              # FastAPI РїСЂРёР»РѕР¶РµРЅРёРµ
в”‚   в””в”Ђв”Ђ tests/               # pytest С‚РµСЃС‚С‹
в”њв”Ђв”Ђ lib/
в”‚   в”њв”Ђв”Ђ models/              # Note
в”‚   в”њв”Ђв”Ђ services/            # API, TokenStore
в”‚   в”њв”Ђв”Ђ screens/             # AuthScreen, NotesPage
в”‚   в””в”Ђв”Ђ theme/               # AppTheme
в””в”Ђв”Ђ test/                    # flutter_test
рџ“ё РЎРєСЂРёРЅС€РѕС‚С‹
(РґРѕР±Р°РІСЊС‚Рµ СЃСЋРґР° СЃРєСЂРёРЅС€РѕС‚С‹ С‚С‘РјРЅРѕР№ Рё СЃРІРµС‚Р»РѕР№ С‚РµРјС‹)

рџ“„ Р›РёС†РµРЅР·РёСЏ
MIT