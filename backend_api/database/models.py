from sqlalchemy import Column, Integer, String, Float, DateTime, ForeignKey
from sqlalchemy.sql import func
from .db_config import Base # We will set this config up next

class User(Base):
    __tablename__ = "users"
    id = Column(Integer, primary_key=True, index=True)
    username = Column(String(50), unique=True)
    total_points = Column(Float, default=0.0)
    current_streak = Column(Integer, default=0)

class WorkoutLog(Base):
    __tablename__ = "workout_logs"
    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id"))
    exercise_name = Column(String(50))
    difficulty_level = Column(Integer)
    reps_completed = Column(Integer)
    points_earned = Column(Float)
    created_at = Column(DateTime, server_default=func.now())