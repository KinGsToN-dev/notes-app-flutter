def test_register_success(client):
    r = client.post("/auth/register", json={
        "email": "new@example.com",
        "password": "secret123"
    })
    assert r.status_code == 200
    data = r.json()
    assert "access_token" in data
    assert data["token_type"] == "bearer"


def test_register_duplicate_email(client):
    payload = {"email": "dup@example.com", "password": "secret123"}
    r1 = client.post("/auth/register", json=payload)
    assert r1.status_code == 200

    r2 = client.post("/auth/register", json=payload)
    assert r2.status_code == 400
    assert "занят" in r2.json()["detail"].lower()


def test_register_invalid_email(client):
    r = client.post("/auth/register", json={
        "email": "not-an-email",
        "password": "secret123"
    })
    assert r.status_code == 422


def test_login_success(client):
    client.post("/auth/register", json={
        "email": "user@example.com",
        "password": "secret123"
    })
    r = client.post("/auth/login", data={
        "username": "user@example.com",
        "password": "secret123"
    })
    assert r.status_code == 200
    assert "access_token" in r.json()


def test_login_wrong_password(client):
    client.post("/auth/register", json={
        "email": "user2@example.com",
        "password": "secret123"
    })
    r = client.post("/auth/login", data={
        "username": "user2@example.com",
        "password": "wrongpass"
    })
    assert r.status_code == 401


def test_me_requires_token(client):
    r = client.get("/auth/me")
    assert r.status_code == 401


def test_me_with_token(auth_client):
    client, email, _ = auth_client
    r = client.get("/auth/me")
    assert r.status_code == 200
    assert r.json()["email"] == email


def test_access_with_invalid_token(client):
    client.headers["Authorization"] = "Bearer invalid.token.here"
    r = client.get("/notes/")
    assert r.status_code == 401