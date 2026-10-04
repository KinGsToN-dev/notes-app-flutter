def test_create_note(auth_client):
    client, _, _ = auth_client
    r = client.post("/notes/", json={"title": "Заголовок", "text": "Тело"})
    assert r.status_code == 200
    data = r.json()
    assert data["title"] == "Заголовок"
    assert data["text"] == "Тело"
    assert "id" in data
    assert "created_at" in data


def test_list_notes_empty(auth_client):
    client, _, _ = auth_client
    r = client.get("/notes/")
    assert r.status_code == 200
    assert r.json() == []


def test_list_notes_after_create(auth_client):
    client, _, _ = auth_client
    client.post("/notes/", json={"title": "A", "text": "1"})
    client.post("/notes/", json={"title": "B", "text": "2"})
    r = client.get("/notes/")
    assert r.status_code == 200
    assert len(r.json()) == 2


def test_update_note(auth_client):
    client, _, _ = auth_client
    note_id = client.post("/notes/", json={"title": "Old", "text": "Old"}).json()["id"]
    r = client.put(f"/notes/{note_id}", json={"title": "New"})
    assert r.status_code == 200
    assert r.json()["title"] == "New"
    assert r.json()["text"] == "Old"  # текст не изменился


def test_delete_note(auth_client):
    client, _, _ = auth_client
    note_id = client.post("/notes/", json={"title": "X", "text": "Y"}).json()["id"]
    r = client.delete(f"/notes/{note_id}")
    assert r.status_code == 200
    r2 = client.get("/notes/")
    assert r2.json() == []


def test_search_notes(auth_client):
    client, _, _ = auth_client
    client.post("/notes/", json={"title": "Купить хлеб", "text": "вечером"})
    client.post("/notes/", json={"title": "Позвонить маме", "text": ""})
    r = client.get("/notes/?search=хлеб")
    assert r.status_code == 200
    assert len(r.json()) == 1
    assert "хлеб" in r.json()[0]["title"]


def test_sort_alpha_asc(auth_client):
    client, _, _ = auth_client
    client.post("/notes/", json={"title": "Яблоко", "text": ""})
    client.post("/notes/", json={"title": "Арбуз", "text": ""})
    client.post("/notes/", json={"title": "Банан", "text": ""})
    r = client.get("/notes/?sort=alpha_asc")
    titles = [n["title"] for n in r.json()]
    assert titles == ["Арбуз", "Банан", "Яблоко"]


def test_sort_alpha_desc(auth_client):
    client, _, _ = auth_client
    client.post("/notes/", json={"title": "Яблоко", "text": ""})
    client.post("/notes/", json={"title": "Арбуз", "text": ""})
    r = client.get("/notes/?sort=alpha_desc")
    titles = [n["title"] for n in r.json()]
    assert titles == ["Яблоко", "Арбуз"]


def test_users_isolated(client):
    """Пользователь A не видит заметки пользователя B."""
    # A
    r = client.post("/auth/register", json={"email": "a@example.com", "password": "secret123"})
    token_a = r.json()["access_token"]
    client.headers["Authorization"] = f"Bearer {token_a}"
    client.post("/notes/", json={"title": "Секрет A", "text": ""})

    # B
    r = client.post("/auth/register", json={"email": "b@example.com", "password": "secret123"})
    token_b = r.json()["access_token"]
    client.headers["Authorization"] = f"Bearer {token_b}"
    notes_b = client.get("/notes/").json()
    assert notes_b == []

    # B не может обновить заметку A
    note_a_id = 1
    r = client.put(f"/notes/{note_a_id}", json={"title": "Взлом"})
    assert r.status_code == 404

    # B не может удалить заметку A
    r = client.delete(f"/notes/{note_a_id}")
    assert r.status_code == 404


def test_notes_require_auth(client):
    r = client.get("/notes/")
    assert r.status_code == 401