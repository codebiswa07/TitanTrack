Write-Host "Initializing Chiku AI Hero Platform..." -ForegroundColor Green

# 1. Activate Virtual Environment if it exists
if (Test-Path ".\backend_api\venv\Scripts\activate") {
    . .\backend_api\venv\Scripts\activate
}

# 2. Run the Master Controller
python run_app.py