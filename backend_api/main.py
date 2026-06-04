from fastapi import FastAPI, Depends, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from sqlalchemy import create_engine, Column, Integer, String, Float, DateTime, ForeignKey
from sqlalchemy.orm import DeclarativeBase, sessionmaker, Session, relationship
from datetime import datetime
from pydantic import BaseModel
from typing import Optional
from dotenv import load_dotenv
import os
import hashlib


load_dotenv()
DATABASE_URL = os.getenv("DATABASE_URL")

if not DATABASE_URL:
    raise RuntimeError("DATABASE_URL environment variable is missing")

# Supabase requires SSL. If your URL doesn't include it, add it automatically.
if "sslmode=" not in DATABASE_URL:
    separator = "&" if "?" in DATABASE_URL else "?"
    DATABASE_URL = f"{DATABASE_URL}{separator}sslmode=require"

engine = create_engine(
    DATABASE_URL,
    pool_pre_ping=True,
    pool_recycle=300,
)

SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)


# ── ORM Models ────────────────────────────────────────────────────────────────

class Base(DeclarativeBase):
    pass


class User(Base):
    __tablename__ = "users"

    id = Column(Integer, primary_key=True, index=True)
    username = Column(String(50), unique=True, nullable=False, index=True)
    password_hash = Column(String(64), nullable=False)
    security_answer = Column(String(255), nullable=False)
    profile_image = Column(String(255))
    total_points = Column(Float, default=0.0)
    calories_burned = Column(Float, default=0.0)

    logs = relationship("WorkoutLog", back_populates="owner", cascade="all, delete-orphan")
    runs = relationship("RunningLog", back_populates="owner", cascade="all, delete-orphan")


class WorkoutLog(Base):
    __tablename__ = "workout_logs"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id"), nullable=False, index=True)
    exercise = Column(String(50))
    reps = Column(Integer)
    difficulty = Column(String(20), default="Medium")
    points = Column(Float, default=0.0)
    calories = Column(Float, default=0.0)
    timestamp = Column(DateTime, default=datetime.utcnow)

    owner = relationship("User", back_populates="logs")


class RunningLog(Base):
    __tablename__ = "running_logs"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id"), nullable=False, index=True)
    distance_meters = Column(Float, default=0.0)
    duration_seconds = Column(Integer, default=0)
    avg_speed_ms = Column(Float, default=0.0)
    points = Column(Float, default=0.0)
    calories = Column(Float, default=0.0)
    timestamp = Column(DateTime, default=datetime.utcnow)

    owner = relationship("User", back_populates="runs")


Base.metadata.create_all(bind=engine)


# ── Pydantic Schemas ──────────────────────────────────────────────────────────

class AuthData(BaseModel):
    username: str
    password: str
    security_answer: Optional[str] = ""


class ResetData(BaseModel):
    username: str
    answer: str
    new_password: str


class WorkoutRequest(BaseModel):
    user_id: int
    exercise: str
    reps: int
    difficulty: Optional[str] = "Medium"
    points: Optional[float] = None
    calories: Optional[float] = None


class RunningRequest(BaseModel):
    user_id: int
    distance_meters: float
    duration_seconds: int
    avg_speed_ms: float
    points: Optional[float] = None
    calories: Optional[float] = None


# ── Helpers ───────────────────────────────────────────────────────────────────

def _hash(password: str) -> str:
    return hashlib.sha256(password.encode()).hexdigest()


def _difficulty_multiplier(difficulty: str) -> float:
    return {"Hard": 2.5, "Medium": 1.5, "Easy": 1.0}.get(difficulty, 1.0)


def _workout_points(reps: int, difficulty: str) -> float:
    return reps * 10.0 * _difficulty_multiplier(difficulty)


def _workout_calories(reps: int, difficulty: str) -> float:
    base = 0.8 if difficulty == "Hard" else 0.5
    return reps * base


def _running_points(distance_meters: float, avg_speed_ms: float) -> float:
    if avg_speed_ms > 4.5:
        multiplier = 3.0
    elif avg_speed_ms > 2.5:
        multiplier = 2.0
    else:
        multiplier = 1.0
    return (distance_meters / 100.0) * multiplier


def _running_calories(distance_meters: float) -> float:
    return (distance_meters / 1000.0) * 60.0


# ── App ───────────────────────────────────────────────────────────────────────

app = FastAPI(title="TitanTrack AI API")

origins = [
    "https://codebiswa07.github.io",
    "http://localhost:3212",
    "http://127.0.0.1:3212",
    "http://localhost:8000",
    "http://127.0.0.1:8000",
]

app.add_middleware(
    CORSMiddleware,
    allow_origins=origins,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()


# ── Routes ────────────────────────────────────────────────────────────────────

@app.get("/")
def home():
    return {"status": "TitanTrack API running with Supabase PostgreSQL"}


@app.post("/register")
def register(data: AuthData, db: Session = Depends(get_db)):
    if db.query(User).filter(User.username == data.username).first():
        raise HTTPException(status_code=400, detail="Username already taken")

    avatar = (
        f"https://ui-avatars.com/api/"
        f"?name={data.username}&background=00FF99&color=000"
    )

    user = User(
        username=data.username,
        password_hash=_hash(data.password),
        security_answer=data.security_answer.lower().strip(),
        profile_image=avatar,
        total_points=0.0,
        calories_burned=0.0,
    )

    db.add(user)
    db.commit()
    db.refresh(user)

    return {
        "status": "success",
        "user_id": user.id,
        "username": user.username,
    }


@app.post("/login")
def login(data: AuthData, db: Session = Depends(get_db)):
    user = db.query(User).filter(User.username == data.username).first()

    if not user:
        raise HTTPException(status_code=404, detail="User not found")

    if user.password_hash != _hash(data.password):
        raise HTTPException(status_code=401, detail="Wrong password")

    return {
        "user_id": user.id,
        "username": user.username,
        "profile_image": user.profile_image,
        "points": user.total_points,
        "calories": user.calories_burned,
    }


@app.post("/reset-password")
def reset_password(data: ResetData, db: Session = Depends(get_db)):
    user = db.query(User).filter(User.username == data.username).first()

    if user and user.security_answer == data.answer.lower().strip():
        user.password_hash = _hash(data.new_password)
        db.commit()
        return {"status": "success"}

    raise HTTPException(status_code=401, detail="Invalid answer")


@app.get("/user/{user_id}")
def get_profile(user_id: int, db: Session = Depends(get_db)):
    user = db.query(User).filter(User.id == user_id).first()

    if not user:
        raise HTTPException(status_code=404, detail="User not found")

    return {
        "username": user.username,
        "profile_image": user.profile_image,
        "total_points": user.total_points,
        "calories_burned": user.calories_burned,
    }


@app.get("/user/{user_id}/history")
def get_history(user_id: int, db: Session = Depends(get_db)):
    workouts = (
        db.query(WorkoutLog)
        .filter(WorkoutLog.user_id == user_id)
        .order_by(WorkoutLog.timestamp.desc())
        .limit(50)
        .all()
    )

    runs = (
        db.query(RunningLog)
        .filter(RunningLog.user_id == user_id)
        .order_by(RunningLog.timestamp.desc())
        .limit(20)
        .all()
    )

    workout_entries = [
        {
            "type": "workout",
            "exercise": w.exercise,
            "reps": w.reps,
            "difficulty": w.difficulty,
            "points": w.points,
            "calories": w.calories,
            "timestamp": w.timestamp.isoformat() if w.timestamp else None,
        }
        for w in workouts
    ]

    run_entries = [
        {
            "type": "running",
            "exercise": "Running",
            "distance_meters": r.distance_meters,
            "duration_seconds": r.duration_seconds,
            "avg_speed_ms": r.avg_speed_ms,
            "points": r.points,
            "calories": r.calories,
            "timestamp": r.timestamp.isoformat() if r.timestamp else None,
        }
        for r in runs
    ]

    return sorted(
        workout_entries + run_entries,
        key=lambda x: x["timestamp"] or "",
        reverse=True,
    )


@app.post("/sync-workout")
def sync_workout(data: WorkoutRequest, db: Session = Depends(get_db)):
    user = db.query(User).filter(User.id == data.user_id).first()

    if not user:
        raise HTTPException(status_code=404, detail="User not found")

    earned_points = data.points if data.points is not None else _workout_points(data.reps, data.difficulty)
    earned_calories = data.calories if data.calories is not None else _workout_calories(data.reps, data.difficulty)

    user.total_points = (user.total_points or 0.0) + earned_points
    user.calories_burned = (user.calories_burned or 0.0) + earned_calories

    log = WorkoutLog(
        user_id=data.user_id,
        exercise=data.exercise,
        reps=data.reps,
        difficulty=data.difficulty,
        points=earned_points,
        calories=earned_calories,
    )

    db.add(log)
    db.commit()
    db.refresh(user)

    return {
        "status": "success",
        "new_points": user.total_points,
        "calories": user.calories_burned,
    }


@app.post("/sync-running")
def sync_running(data: RunningRequest, db: Session = Depends(get_db)):
    user = db.query(User).filter(User.id == data.user_id).first()

    if not user:
        raise HTTPException(status_code=404, detail="User not found")

    earned_points = data.points if data.points is not None else _running_points(data.distance_meters, data.avg_speed_ms)
    earned_calories = data.calories if data.calories is not None else _running_calories(data.distance_meters)

    user.total_points = (user.total_points or 0.0) + earned_points
    user.calories_burned = (user.calories_burned or 0.0) + earned_calories

    log = RunningLog(
        user_id=data.user_id,
        distance_meters=data.distance_meters,
        duration_seconds=data.duration_seconds,
        avg_speed_ms=data.avg_speed_ms,
        points=earned_points,
        calories=earned_calories,
    )

    db.add(log)
    db.commit()
    db.refresh(user)

    return {
        "status": "success",
        "distance_km": round(data.distance_meters / 1000, 2),
        "earned_points": round(earned_points, 2),
        "earned_calories": round(earned_calories, 2),
        "new_points": user.total_points,
    }


@app.get("/leaderboard")
def leaderboard(limit: int = 10, db: Session = Depends(get_db)):
    top = (
        db.query(User)
        .order_by(User.total_points.desc())
        .limit(limit)
        .all()
    )

    return [
        {
            "rank": i + 1,
            "username": u.username,
            "profile_image": u.profile_image,
            "total_points": u.total_points,
            "calories": u.calories_burned,
        }
        for i, u in enumerate(top)
    ]
