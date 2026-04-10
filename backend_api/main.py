from fastapi import FastAPI, Depends, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from sqlalchemy import create_engine, Column, Integer, String, Float, DateTime, ForeignKey
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker, Session, relationship
from datetime import datetime
from pydantic import BaseModel
from typing import List, Optional
import uvicorn
import subprocess
import os

# --- DATABASE CONFIG ---
# Your specific credentials for chiku
DATABASE_URL = "mysql+mysqlconnector://root:chiku222@127.0.0.1:3306/ai_workout_db"
engine = create_engine(DATABASE_URL)
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)
Base = declarative_base()

# --- MODELS ---
class User(Base):
    __tablename__ = "users"
    id = Column(Integer, primary_key=True, index=True)
    username = Column(String(50), unique=True, nullable=False)
    password = Column(String(100), nullable=False)
    security_answer = Column(String(255), nullable=False)
    profile_image = Column(String(255))
    total_points = Column(Float, default=0.0)
    calories_burned = Column(Float, default=0.0)
    # Relationship to logs
    logs = relationship("WorkoutLog", back_populates="owner")

class WorkoutLog(Base):
    __tablename__ = "workout_logs"
    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id"))
    exercise = Column(String(50))
    reps = Column(Integer)
    timestamp = Column(DateTime, default=datetime.utcnow)
    # Link back to user
    owner = relationship("User", back_populates="logs")

Base.metadata.create_all(bind=engine)

# --- SCHEMAS (Matches your Swagger UI screenshot) ---
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

# --- API ---
app = FastAPI(title="Chiku AI Hero API")

# 🟢 CRITICAL: CORS fix for Chrome
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

def get_db():
    db = SessionLocal()
    try: yield db
    finally: db.close()

# 🛡️ AUTH ENDPOINTS
@app.post("/register")
def register(data: AuthData, db: Session = Depends(get_db)):
    try:
        # 1. Check if user exists
        existing = db.query(User).filter(User.username == data.username).first()
        if existing:
            print(f"🚩 Denied: {data.username} already exists in DB.")
            raise HTTPException(status_code=400, detail="Username taken")

        # 2. Try to create the user
        avatar = f"https://ui-avatars.com/api/?name={data.username}&background=00FF99&color=000"
        new_user = User(
            username=data.username, 
            password=data.password, 
            security_answer=data.security_answer, 
            profile_image=avatar
        )
        
        db.add(new_user)
        db.commit()
        print(f"✅ Success: {data.username} is now registered!")
        return {"status": "success"}

    except Exception as e:
        db.rollback()
        print(f"❌ DATABASE CRASH: {str(e)}") # 👈 CHECK YOUR TERMINAL FOR THIS!
        raise HTTPException(status_code=500, detail="Database Error")

@app.post("/login")
def login(data: AuthData, db: Session = Depends(get_db)):
    user = db.query(User).filter(User.username == data.username).first()
    if not user: raise HTTPException(status_code=404, detail="Not Found")
    if user.password != data.password: raise HTTPException(status_code=401, detail="Wrong Pass")
    return {
        "user_id": user.id, 
        "username": user.username, 
        "profile_image": user.profile_image, 
        "points": user.total_points, 
        "calories": user.calories_burned
    }

@app.post("/reset-password")
def reset(data: ResetData, db: Session = Depends(get_db)):
    user = db.query(User).filter(User.username == data.username).first()
    if user and user.security_answer.lower() == data.answer.lower():
        user.password = data.new_password
        db.commit()
        return {"status": "success"}
    raise HTTPException(status_code=401, detail="Invalid Answer")

# 📊 DATA ENDPOINTS (Needed for Dashboard)
@app.get("/user/{user_id}")
def get_profile(user_id: int, db: Session = Depends(get_db)):
    user = db.query(User).filter(User.id == user_id).first()
    if not user: raise HTTPException(status_code=404)
    return {"total_points": user.total_points, "calories_burned": user.calories_burned}

@app.get("/user/{user_id}/history")
def get_history(user_id: int, db: Session = Depends(get_db)):
    return db.query(WorkoutLog).filter(WorkoutLog.user_id == user_id).order_by(WorkoutLog.id.desc()).all()

# 🦾 AI ENGINE SYNC
@app.post("/sync-workout")
def sync_workout(data: WorkoutRequest, db: Session = Depends(get_db)):
    user = db.query(User).filter(User.id == data.user_id).first()
    if not user: raise HTTPException(status_code=404)
    
    # Update Stats
    user.total_points += (data.reps * 10.5)
    user.calories_burned += (data.reps * 0.5)
    
    # Save Log
    new_log = WorkoutLog(user_id=data.user_id, exercise=data.exercise, reps=data.reps)
    db.add(new_log); db.commit()
    return {"new_balance": user.total_points, "calories": user.calories_burned}

@app.get("/launch-ai")
def launch_ai(exercise: str, difficulty: str, user_id: int):
    try:
        # This command runs your ai_engine script as a separate process
        # Use 'python' or 'python3' depending on your environment
        script_path = os.path.join(os.getcwd(), "ai_engine.py")
        
        subprocess.Popen([
            "python", script_path, 
            str(user_id), exercise, difficulty
        ])
        
        return {"status": "started", "message": f"AI Engine active for {exercise}"}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=8000)