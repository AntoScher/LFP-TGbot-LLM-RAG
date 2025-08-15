# LFP-TGbot-LLM-RAG Interactive Launcher
# This script provides an easy way to launch the bot with different backends

Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass -Force

function Write-Info {
    param([string]$Message)
    Write-Host "[INFO] $Message" -ForegroundColor Cyan
}

function Write-Success {
    param([string]$Message)
    Write-Host "[OK  ] $Message" -ForegroundColor Green
}

function Write-Warn {
    param([string]$Message)
    Write-Host "[WARN] $Message" -ForegroundColor Yellow
}

function Write-Err {
    param([string]$Message)
    Write-Host "[ERR ] $Message" -ForegroundColor Red
}

function Ensure-Venv {
    Write-Info "Activating venv..."
    
    if (-not (Test-Path ".venv")) {
        Write-Err "Virtual environment not found. Please run: python -m venv .venv"
        exit 1
    }
    
    & ".venv\Scripts\Activate.ps1"
    
    Write-Info "Upgrading pip..."
    python -m pip install --upgrade pip > $null 2>&1
}

function Install-RequirementsIfChanged {
    $requirementsFile = if (Test-Path "requirements.lock.txt") { "requirements.lock.txt" } else { "requirements.txt" }
    
    # Simple check - if FORCE_DEPS is set, always install
    if ($env:FORCE_DEPS -eq "1") {
        Write-Info "Force installing requirements from $requirementsFile"
        python -m pip install -r $requirementsFile
        return
    }
    
    # Check if we have a hash file
    $hashFile = ".venv\.requirements_hash"
    if (Test-Path $hashFile) {
        try {
            $storedHash = Get-Content $hashFile -ErrorAction Stop
            $currentHash = (Get-FileHash $requirementsFile -Algorithm SHA256 -ErrorAction Stop).Hash
            if ($storedHash -eq $currentHash) {
                Write-Success "Requirements unchanged (skip install). Set FORCE_DEPS=1 to force reinstall."
                return
            }
        } catch {
            Write-Warn "Hash check failed, installing requirements..."
        }
    }
    
    Write-Info "Installing requirements from $requirementsFile"
    python -m pip install -r $requirementsFile
    
    # Save new hash
    try {
        $newHash = (Get-FileHash $requirementsFile -Algorithm SHA256).Hash
        $newHash | Out-File $hashFile -Encoding UTF8
    } catch {
        Write-Warn "Could not save requirements hash"
    }
}

function Ensure-OpenVINO {
    $markerFile = ".venv\.openvino_installed"
    
    # Check if already installed
    if (Test-Path $markerFile -and $env:FORCE_OPENVINO -ne "1") {
        Write-Success "OpenVINO packages already installed. Set FORCE_OPENVINO=1 to force reinstall."
        return
    }
    
    Write-Info "Installing OpenVINO packages..."
    try {
        python -m pip install "openvino>=2024.2.0" "optimum-intel>=1.17.0"
        "installed" | Out-File $markerFile -Encoding UTF8
        Write-Success "OpenVINO packages installed successfully"
    } catch {
        Write-Err "Failed to install OpenVINO packages"
        Write-Info "You can try: Set-Item -Path Env:FORCE_OPENVINO -Value '1' and run again"
        exit 1
    }
}

function Check-Environment {
    Write-Info "Checking environment..."
    
    # Check Python version
    try {
        $pythonVersion = python -c "import sys; print(f'{sys.version_info.major}.{sys.version_info.minor}')" 2>$null
        if ($pythonVersion) {
            Write-Info "Python version: $pythonVersion"
        } else {
            Write-Err "Python not found or not working"
            exit 1
        }
    } catch {
        Write-Err "Failed to check Python version: $_"
        exit 1
    }
    
    # Check key packages
    Write-Info "Checking key packages..."
    $packages = @("torch", "transformers", "langchain", "telegram", "flask", "chromadb")
    foreach ($pkg in $packages) {
        try {
            $version = python -c "import $pkg; print($pkg.__version__)" 2>$null
            if ($version) {
                Write-Success "$pkg version: $version"
            } else {
                Write-Warn "$pkg not found"
            }
        } catch {
            Write-Warn "$pkg not found or error checking version"
        }
    }
}

function Start-BotCpu {
    Write-Info "Setting up CPU (PyTorch) mode..."
    $env:INFERENCE_BACKEND = "cpu"
    $env:DEVICE = "cpu"
    $env:PYTHONUNBUFFERED = "1"
    $env:ANONYMIZED_TELEMETRY = "false"
    
    Write-Success "Starting bot in CPU (PyTorch) mode..."
    Write-Info "Expected performance: ~7s initialization, ~30s per response"
    python .\bot.py
}

function Start-BotOpenVinoCpu {
    Write-Info "Setting up OpenVINO + CPU mode..."
    $env:INFERENCE_BACKEND = "openvino"
    $env:OPENVINO_DEVICE = "CPU"
    $env:PYTHONUNBUFFERED = "1"
    $env:ANONYMIZED_TELEMETRY = "false"
    
    Write-Success "Starting bot in OpenVINO + CPU mode..."
    Write-Info "Expected performance: ~23s initialization, ~2.5min per response"
    python .\bot.py
}

function Show-PerformanceComparison {
    Write-Host ""
    Write-Host "Performance Comparison:" -ForegroundColor Yellow
    Write-Host "+-----------------+-------------+-----------------+"
    Write-Host "| Mode            | Init Time   | Response Time   |"
    Write-Host "+-----------------+-------------+-----------------+"
    Write-Host "| CPU (PyTorch)   | ~7 seconds  | ~30 seconds     |"
    Write-Host "| OpenVINO + CPU  | ~23 seconds | ~2.5 minutes    |"
    Write-Host "+-----------------+-------------+-----------------+"
    Write-Host ""
    Write-Host "Recommendation: Use CPU mode for faster responses" -ForegroundColor Green
    Write-Host ""
}

try {
    Write-Host "==============================" -ForegroundColor Green
    Write-Host " LFP-TGbot-LLM-RAG Launcher" -ForegroundColor Green
    Write-Host "==============================" -ForegroundColor Green

    Ensure-Venv
    Install-RequirementsIfChanged
    Check-Environment

    if (-not (Test-Path .\.env)) {
        Write-Warn ".env not found. Create it with TELEGRAM_TOKEN and HUGGINGFACEHUB_API_TOKEN before running."
        Write-Info "Example .env content:"
        Write-Host "TELEGRAM_TOKEN=your_token_here" -ForegroundColor Gray
        Write-Host "HUGGINGFACEHUB_API_TOKEN=your_token_here" -ForegroundColor Gray
        Write-Host "INFERENCE_BACKEND=cpu" -ForegroundColor Gray
        Write-Host "DEVICE=cpu" -ForegroundColor Gray
    }

    Show-PerformanceComparison

    Write-Host "Select mode:" -ForegroundColor Green
    Write-Host "  [1] CPU (PyTorch) - Fast responses, recommended"
    Write-Host "  [2] OpenVINO + CPU - Slower but optimized for Intel"
    $choice = Read-Host "Enter 1 or 2"

    switch ($choice) {
        "1" { Start-BotCpu }
        "2" {
            Ensure-OpenVINO
            Start-BotOpenVinoCpu
        }
        default {
            Write-Err "Unknown choice: $choice"
            exit 1
        }
    }
}
catch {
    Write-Err $_
    Write-Info "If you encounter issues, try:"
    Write-Host "  - Set FORCE_DEPS=1 to reinstall dependencies" -ForegroundColor Gray
    Write-Host "  - Set FORCE_OPENVINO=1 to reinstall OpenVINO" -ForegroundColor Gray
    Write-Host "  - Delete .venv folder to start fresh" -ForegroundColor Gray
    exit 1
}
