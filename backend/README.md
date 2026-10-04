# Backend — Notes API

REST API на FastAPI + SQLModel + SQLite с JWT-аутентификацией.

## 🚀 Запуск

```bash
pip install fastapi uvicorn sqlmodel "python-jose[cryptography]" bcrypt email-validator
uvicorn main:app --reload
API: http://127.0.0.1:8000

Swagger UI: http://127.0.0.1:8000/docs

ReDoc: http://127.0.0.1:8000/redoc

🔌 Эндпоинты
Аутентификация
Метод	Путь	Описание
POST	/auth/register	Регистрация (email + password) → JWT
POST	/auth/login	Логин (form-data: username=email, password) → JWT
GET	/auth/me	Текущий пользователь (требует токен)
Заметки (все требуют Authorization: Bearer <token>)
Метод	Путь	Описание
GET	/notes/	Список заметок. Query: ?search=...&sort=date_desc|date_asc|alpha_asc|alpha_desc
POST	/notes/	Создать заметку {title, text}
PUT	/notes/{id}	Обновить {title?, text?}
DELETE	/notes/{id}	Удалить
🧪 Тесты
bash
python -m pytest
18 тестов: регистрация, логин, JWT, CRUD, поиск, сортировка, изоляция пользователей.

🗄️ БД
SQLite, файл notes.db создаётся автоматически при первом запуске.

⚠️ Файлы *.db не коммитятся — они локальные. Для сброса БД просто удалите notes.db и перезапустите сервер.

🔐 Безопасность
JWT — токен живёт 7 дней

bcrypt — хеширование паролей

CORS — открыт для всех (*), для продакшена ограничьте

⚠️ SECRET_KEY в main.py — заглушка. Для продакшена сгенерируйте:

bash
python -c "import secrets; print(secrets.token_urlsafe(64))"
и вынесите в переменные окружения.

text

---

## 🎯 Что дальше

После пуша `backend/README.md` у вас **полностью оформленный репозиторий** с:
- ✅ Корневым `README.md`
- ✅ `backend/README.md` с описанием API
- ✅ 23 тестами
- ✅ `.gitignore` (без БД)
- ✅ Чистой историей Git

Теперь можно двигаться дальше. Вот варианты:

| # | Направление | Сложность | Что даст |
|---|---|---|---|
| **4** | 🚀 CI/CD с GitHub Actions | ⭐⭐ | Автозапуск тестов на каждый push |
| **1** | 🐳 Docker | ⭐⭐ | Запуск одной командой |
| **2** | ☁️ Деплой в интернет | ⭐⭐⭐ | Ссылка, доступная с любого устройства |
| **3** | 🐘 PostgreSQL | ⭐⭐ | Production-ready БД |

**Рекомендую #4 (CI/CD)** — он логично продолжает то, что вы только что сделали (Git + GitHub). Настроим GitHub Actions так, чтобы при каждом `git push` автоматически запускались `pytest` и `flutter test`, и вы видели ✅ или ❌ рядом с коммитом.