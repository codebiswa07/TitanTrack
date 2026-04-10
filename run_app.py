import subprocess
import time
import sys
import os

def run_backend():
    print("🚀 Starting FastAPI Server...")
    # Change 'backend_api' to your actual folder name if different
    subprocess.Popen([sys.executable, "-m", "uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"], 
                     cwd="backend_api")

def run_ai_engine():
    print("👀 Starting AI Engine (Webcam)...")
    time.sleep(5) # Give the server 5 seconds to wake up
    subprocess.Popen([sys.executable, "ai_engine.py"], cwd="backend_api")

def run_flutter():
    print("📱 Launching Flutter App...")
    # Change 'mobile_desktop_app' to your actual folder name
    subprocess.Popen(["flutter", "run", "-d", "windows"], cwd="mobile_desktop_app")

if __name__ == "__main__":
    try:
        run_backend()
        run_ai_engine()
        run_flutter()
        
        print("\n✅ All systems online. Press CTRL+C in this terminal to stop everything.")
        
        # Keep the master script alive
        while True:
            time.sleep(1)
    except KeyboardInterrupt:
        print("\n🛑 Shutting down Chiku AI Hero...")
        sys.exit()