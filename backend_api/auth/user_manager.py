from fastapi import APIRouter

router = APIRouter()

@router.post("/login")
def login(username: str, password: str):
    # Placeholder authentication
    return {"status": "success", "user": username}