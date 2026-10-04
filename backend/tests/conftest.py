import os
import sys
import pytest
from fastapi.testclient import TestClient
from sqlmodel import SQLModel, Session, create_engine
from sqlmodel.pool import StaticPool

# Добавляем корень backend в sys.path
sys.path.insert(0, os.path.dirname(os.path.dirname(__file__)))

import main as main_module
from main import app, get_session


@pytest.fixture(name="engine")
def engine_fixture():
    """In-memory SQLite для каждого теста."""
    engine = create_engine(
        "sqlite://",
        connect_args={"check_same_thread": False},
        poolclass=StaticPool,
    )
    SQLModel.metadata.create_all(engine)
    yield engine
    SQLModel.metadata.drop_all(engine)


@pytest.fixture(name="client")
def client_fixture(engine):
    """TestClient с подменённой сессией."""
    def override_get_session():
        with Session(engine) as session:
            yield session

    app.dependency_overrides[get_session] = override_get_session
    client = TestClient(app)
    yield client
    app.dependency_overrides.clear()


@pytest.fixture(name="auth_client")
def auth_client_fixture(client):
    """Клиент, уже прошедший регистрацию. Возвращает (client, email, password)."""
    email = "test@example.com"
    password = "secret123"
    r = client.post("/auth/register", json={"email": email, "password": password})
    assert r.status_code == 200, r.text
    token = r.json()["access_token"]
    client.headers["Authorization"] = f"Bearer {token}"
    return client, email, password