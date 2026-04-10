import cv2, mediapipe as mp, numpy as np, requests, time, sys
from mediapipe.tasks import python
from mediapipe.tasks.python import vision

# --- 1. SMART ARGUMENTS (Fixes base 10 error) ---
args = sys.argv[1:]
USER_ID = 1
EXERCISE = "Pushups"
DIFFICULTY = "Medium"

# Allowed exercises to check against
EXERCISE_LIST = ["Pushups", "Squats", "Chin-ups", "High Knees", "Lunges", "Jumping Jacks", "Burpees", "Plank"]

for arg in args:
    if arg.isdigit(): 
        USER_ID = int(arg)
    elif arg in EXERCISE_LIST:
        EXERCISE = arg
    elif arg in ["Easy", "Medium", "Hard"]:
        DIFFICULTY = arg

SYNC_URL = "http://127.0.0.1:8000/sync-workout"

# --- 2. THRESHOLD CONFIGURATION ---
CONFIG = {
    "Pushups":      {"Easy": (110, 160), "Medium": (90, 160), "Hard": (70, 160), "j": [11, 13, 15]},
    "Squats":       {"Easy": (120, 160), "Medium": (100, 160), "Hard": (80, 160), "j": [23, 25, 27]},
    "Chin-ups":     {"Easy": (100, 150), "Medium": (70, 150), "Hard": (40, 150), "j": [11, 13, 15]},
    "High Knees":   {"Easy": (110, 150), "Medium": (90, 150), "Hard": (70, 150), "j": [24, 23, 25]},
    "Lunges":       {"Easy": (110, 160), "Medium": (95, 160), "Hard": (85, 160), "j": [23, 25, 27]},
    "Jumping Jacks":{"Easy": (0.6, 0.2), "Medium": (0.8, 0.3), "Hard": (1.0, 0.4), "j": [15, 16]}, 
    "Burpees":      {"Easy": (0.5, 0.2), "Medium": (0.4, 0.2), "Hard": (0.3, 0.2), "j": [11, 23]}, 
    "Plank":        {"Easy": 165, "Medium": 170, "Hard": 175, "j": [11, 23, 25]} 
}

# Load chosen exercise settings
current_cfg = CONFIG.get(EXERCISE, CONFIG["Pushups"])
down_limit, up_limit = current_cfg[DIFFICULTY] if EXERCISE != "Plank" else (current_cfg[DIFFICULTY], 0)
joints = current_cfg["j"]

# Global state
counter = 0
stage = "up"
current_angle = 0
latest_landmarks = None
start_time = None

def calculate_angle(a, b, c):
    a = np.array([a.x, a.y]); b = np.array([b.x, b.y]); c = np.array([c.x, c.y])
    rad = np.arctan2(c[1]-b[1], c[0]-b[0]) - np.arctan2(a[1]-b[1], a[0]-b[0])
    angle = np.abs(rad * 180.0 / np.pi)
    return 360-angle if angle > 180 else angle

def callback(res, img, ts):
    global counter, stage, current_angle, latest_landmarks, start_time
    if not res.pose_landmarks: return
    lm = res.pose_landmarks[0]
    latest_landmarks = lm 

    # --- FULL BODY VALIDATION LOGIC ---
    # We check the relationship between hips, shoulders, and knees to prevent "standing ghost reps"
    
    # 1. SQUATS: Shoulders must drop significantly relative to their standing height
    if EXERCISE == "Squats":
        current_angle = calculate_angle(lm[23], lm[25], lm[27]) # Hip-Knee-Ankle
        # Validation: Hips (23) must be lower than a certain point or moving vertically
        is_squatting = lm[23].y > 0.6  # Adjust this based on your camera distance
        
        if is_squatting:
            if current_angle < down_limit: stage = "down"
            if current_angle > up_limit and stage == "down":
                stage = "up"; counter += 1
        else:
            stage = "stand" # Reset if you just lift a leg while standing high

    # 2. PUSHUPS: Body must be horizontal
    elif EXERCISE == "Pushups":
        current_angle = calculate_angle(lm[11], lm[13], lm[15]) # Shoulder-Elbow-Wrist
        # Validation: Shoulder (11) and Hip (23) should be at similar Y levels (Horizontal)
        is_horizontal = abs(lm[11].y - lm[23].y) < 0.2
        
        if is_horizontal:
            if current_angle < down_limit: stage = "down"
            if current_angle > up_limit and stage == "down":
                stage = "up"; counter += 1
        else:
            stage = "standing"

    # 3. HIGH KNEES: Only counts if the opposite foot is on the ground
    elif EXERCISE == "High Knees":
        current_angle = calculate_angle(lm[24], lm[23], lm[25]) # Shoulder-Hip-Knee
        # Validation: One foot must be significantly lower than the other
        is_jumping = abs(lm[27].y - lm[28].y) > 0.05
        
        if is_jumping:
            if current_angle < down_limit: stage = "down"
            if current_angle > up_limit and stage == "down":
                stage = "up"; counter += 1

    # 4. PLANK: Must be perfectly still and horizontal
    elif EXERCISE == "Plank":
        current_angle = calculate_angle(lm[11], lm[23], lm[25]) # Shoulder-Hip-Knee
        back_straight = current_angle > down_limit
        is_horizontal = abs(lm[11].y - lm[23].y) < 0.15 # Must be lying down
        
        if back_straight and is_horizontal:
            if start_time is None: start_time = time.time()
            counter = int(time.time() - start_time)
            stage = "HOLDING"
        else:
            start_time = None
            stage = "FIX FORM"

    # --- DEFAULT FOR OTHER EXERCISES ---
    else:
        current_angle = calculate_angle(lm[joints[0]], lm[joints[1]], lm[joints[2]])
        if current_angle < down_limit: stage = "down"
        if current_angle > up_limit and stage == "down":
            stage = "up"; counter += 1

# --- 3. MEDIAPIPE PIPELINE ---
base_options = python.BaseOptions(model_asset_path='pose_landmarker_full.task')
options = vision.PoseLandmarkerOptions(
    base_options=base_options, 
    running_mode=vision.RunningMode.LIVE_STREAM, 
    result_callback=callback
)

with vision.PoseLandmarker.create_from_options(options) as landmarker:
    cap = cv2.VideoCapture(0)
    print(f"🔥 AI Engine Live: {EXERCISE} ({DIFFICULTY})")
    
    while cap.isOpened():
        ret, frame = cap.read()
        if not ret: break
        
        frame = cv2.flip(frame, 1)
        h, w, _ = frame.shape
        
        # Detect
        mp_img = mp.Image(image_format=mp.ImageFormat.SRGB, data=frame)
        landmarker.detect_async(mp_img, int(time.time() * 1000))

        # --- VISUAL PIPELINE (Manual Drawing) ---
        if latest_landmarks:
            # Draw Joint Dots
            for lmk in latest_landmarks:
                cx, cy = int(lmk.x * w), int(lmk.y * h)
                cv2.circle(frame, (cx, cy), 3, (0, 255, 153), -1)
            
            # Draw Angle Label attached to the Joint
            if EXERCISE != "Jumping Jacks":
                mid = latest_landmarks[joints[1]]
                cv2.putText(frame, f"{int(current_angle)}deg", 
                            (int(mid.x * w) + 15, int(mid.y * h)), 
                            cv2.FONT_HERSHEY_SIMPLEX, 0.6, (255, 255, 255), 2)

        # --- UI OVERLAY ---
        cv2.rectangle(frame, (0,0), (280, 130), (15, 15, 15), -1)
        cv2.putText(frame, f"{EXERCISE} - {DIFFICULTY}", (15, 30), 1, 1, (0, 255, 153), 1)
        
        stat_label = "REPS" if EXERCISE != "Plank" else "SEC"
        cv2.putText(frame, f"{stat_label}: {counter}", (15, 85), 1, 2.5, (0, 255, 153), 4)
        cv2.putText(frame, f"STAGE: {stage}", (15, 120), 1, 1, (255, 255, 255), 1)

        cv2.imshow('Chiku AI Hero Pro', frame)
        if cv2.waitKey(1) & 0xFF == ord('q'): break

    cap.release()
    cv2.destroyAllWindows()

# --- FINAL SYNC ---
try:
    requests.post(SYNC_URL, json={
        "user_id": USER_ID, "exercise": EXERCISE, "reps": counter, "difficulty": DIFFICULTY
    })
    print(f"✅ Synced {counter} {EXERCISE} to Database.")
except:
    print("❌ Sync Failed: Backend offline.")