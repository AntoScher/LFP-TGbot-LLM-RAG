# Простой скрипт для запуска LFP-TGbot-LLM-RAG
# Упрощенная версия без сложных проверок

Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass -Force

Write-Host "==============================" -ForegroundColor Green
Write-Host " LFP-TGbot-LLM-RAG Launcher" -ForegroundColor Green
Write-Host "==============================" -ForegroundColor Green

# Активируем виртуальное окружение
Write-Host "[INFO] Activating venv..." -ForegroundColor Cyan
& ".venv\Scripts\Activate.ps1"

# Проверяем Python
Write-Host "[INFO] Checking Python..." -ForegroundColor Cyan
$pythonVersion = python -c "import sys; print(f'{sys.version_info.major}.{sys.version_info.minor}')" 2>$null
if ($pythonVersion) {
    Write-Host "[OK  ] Python version: $pythonVersion" -ForegroundColor Green
} else {
    Write-Host "[ERR ] Python not found" -ForegroundColor Red
    exit 1
}

# Показываем сравнение производительности
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

# Выбор режима
Write-Host "Select mode:" -ForegroundColor Green
Write-Host "  [1] CPU (PyTorch) - Fast responses, recommended"
Write-Host "  [2] OpenVINO + CPU - Slower but optimized for Intel"
$choice = Read-Host "Enter 1 or 2"

# Запуск бота
if ($choice -eq "1") {
    Write-Host "[INFO] Starting bot in CPU (PyTorch) mode..." -ForegroundColor Cyan
    $env:INFERENCE_BACKEND = "cpu"
    $env:DEVICE = "cpu"
    $env:PYTHONUNBUFFERED = "1"
    $env:ANONYMIZED_TELEMETRY = "false"
    python .\bot.py
}
elseif ($choice -eq "2") {
    Write-Host "[INFO] Starting bot in OpenVINO + CPU mode..." -ForegroundColor Cyan
    $env:INFERENCE_BACKEND = "openvino"
    $env:OPENVINO_DEVICE = "CPU"
    $env:PYTHONUNBUFFERED = "1"
    $env:ANONYMIZED_TELEMETRY = "false"
    python .\bot.py
}
else {
    Write-Host "[ERR ] Unknown choice: $choice" -ForegroundColor Red
    exit 1
}
