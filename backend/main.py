from fastapi import FastAPI, Depends, HTTPException, Query, status
from fastapi.middleware.cors import CORSMiddleware
from fastapi.security import OAuth2PasswordBearer, OAuth2PasswordRequestForm
from sqlmodel import Session, select, SQLModel, Field, create_engine
from typing import Optional, List
from datetime import datetime, timezone, timedelta
import bcrypt
from jose import JWTError, jwt
from pydantic import BaseModel, EmailStr

# --- Конфиг ---
SECRET_KEY = "CHANGE_ME_IN_PRODUCTION_9f8a7b6c5d4e3f2a1b0c"
ALGORITHM = "HS256"
ACCESS_TOKEN_EXPIRE_MINUTES = 60 * 24 * 7  # 7 дней


oauth2_scheme = OAuth2PasswordBearer(tokenUrl="/auth/login")

# --- Модели ---
class User(SQLModel, table=True):
    id: Optional[int] = Field(default=None, primary_key=True)
    email: str = Field(index=True, unique=True)
    hashed_password: str

class Note(SQLModel, table=True):
    id: Optional[int] = Field(default=None, primary_key=True)
    title: str = Field(default="")
    text: str
    created_at: datetime = Field(default_factory=lambda: datetime.now(timezone.utc))
    user_id: int = Field(foreign_key="user.id", index=True)

class UserCreate(BaseModel):
    email: EmailStr
    password: str

class NoteCreate(BaseModel):
    title: str = ""
    text: str

class NoteUpdate(BaseModel):
    title: Optional[str] = None
    text: Optional[str] = None

class Token(BaseModel):
    access_token: str
    token_type: str = "bearer"

# --- БД ---
engine = create_engine("sqlite:///notes.db")
SQLModel.metadata.create_all(engine)

app = FastAPI(title="Notes API with Auth")
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

def get_session():
    with Session(engine) as session:
        yield session

# --- Утилиты ---
def hash_password(password: str) -> str:
    """Хеширует пароль с использованием bcrypt"""
    pwd_bytes = password.encode('utf-8')
    salt = bcrypt.gensalt()
    hashed = bcrypt.hashpw(pwd_bytes, salt)
    return hashed.decode('utf-8')

def verify_password(plain_password: str, hashed_password: str) -> bool:
    """Проверяет пароль против хеша"""
    return bcrypt.checkpw(
        plain_password.encode('utf-8'),
        hashed_password.encode('utf-8')
    )

def create_access_token(user_id: int) -> str:
    expire = datetime.now(timezone.utc) + timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES)
    payload = {"sub": str(user_id), "exp": expire}
    return jwt.encode(payload, SECRET_KEY, algorithm=ALGORITHM)

def get_current_user(
    token: str = Depends(oauth2_scheme),
    session: Session = Depends(get_session),
) -> User:
    cred_exc = HTTPException(
        status_code=status.HTTP_401_UNAUTHORIZED,
        detail="Неверный или истёкший токен",
        headers={"WWW-Authenticate": "Bearer"},
    )
    try:
        payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
        user_id = int(payload.get("sub"))
    except (JWTError, TypeError, ValueError):
        raise cred_exc
    user = session.get(User, user_id)
    if not user:
        raise cred_exc
    return user

# --- Auth ---
@app.post("/auth/register", response_model=Token)
def register(payload: UserCreate, session: Session = Depends(get_session)):
    existing = session.exec(select(User).where(User.email == payload.email)).first()
    if existing:
        raise HTTPException(400, "Email уже занят")
    user = User(email=payload.email, hashed_password=hash_password(payload.password))
    session.add(user)
    session.commit()
    session.refresh(user)
    return Token(access_token=create_access_token(user.id))

@app.post("/auth/login", response_model=Token)
def login(form: OAuth2PasswordRequestForm = Depends(), session: Session = Depends(get_session)):
    user = session.exec(select(User).where(User.email == form.username)).first()
    if not user or not verify_password(form.password, user.hashed_password):
        raise HTTPException(401, "Неверный email или пароль")
    return Token(access_token=create_access_token(user.id))

@app.get("/auth/me")
def me(current: User = Depends(get_current_user)):
    return {"id": current.id, "email": current.email}

# --- CRUD заметок (только для владельца) ---
@app.get("/notes/", response_model=List[Note])
def read_notes(
    search: Optional[str] = Query(None),
    sort: str = Query("date_desc"),
    session: Session = Depends(get_session),
    current: User = Depends(get_current_user),
):
    stmt = select(Note).where(Note.user_id == current.id)
    if search:
        s = f"%{search.lower()}%"
        stmt = stmt.where((Note.title.ilike(s)) | (Note.text.ilike(s)))
    if sort == "date_asc":
        stmt = stmt.order_by(Note.created_at.asc())
    elif sort == "alpha_asc":
        stmt = stmt.order_by(Note.title.asc())
    elif sort == "alpha_desc":
        stmt = stmt.order_by(Note.title.desc())
    else:
        stmt = stmt.order_by(Note.created_at.desc())
    return session.exec(stmt).all()

@app.post("/notes/", response_model=Note)
def create_note(
    payload: NoteCreate,
    session: Session = Depends(get_session),
    current: User = Depends(get_current_user),
):
    note = Note(title=payload.title, text=payload.text, user_id=current.id)
    session.add(note)
    session.commit()
    session.refresh(note)
    return note

@app.put("/notes/{note_id}", response_model=Note)
def update_note(
    note_id: int,
    payload: NoteUpdate,
    session: Session = Depends(get_session),
    current: User = Depends(get_current_user),
):
    note = session.get(Note, note_id)
    if not note or note.user_id != current.id:
        raise HTTPException(404, "Заметка не найдена")
    if payload.title is not None:
        note.title = payload.title
    if payload.text is not None:
        note.text = payload.text
    session.add(note)
    session.commit()
    session.refresh(note)
    return note

@app.delete("/notes/{note_id}")
def delete_note(
    note_id: int,
    session: Session = Depends(get_session),
    current: User = Depends(get_current_user),
):
    note = session.get(Note, note_id)
    if not note or note.user_id != current.id:
        raise HTTPException(404, "Заметка не найдена")
    session.delete(note)
    session.commit()
    return {"ok": True}