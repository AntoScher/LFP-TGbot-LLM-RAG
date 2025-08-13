# Скрипт проверки системы перед установкой LFP-TGbot-LLM-RAG
# Запуск: .\check_system.ps1

Write-Host "🔍 ПРОВЕРКА СИСТЕМЫ ДЛЯ LFP-TGbot-LLM-RAG" -ForegroundColor Cyan
Write-Host "=" * 60 -ForegroundColor Cyan

# Проверка PowerShell версии
Write-Host "1️⃣ Проверка PowerShell..." -ForegroundColor Yellow
$psVersion = $PSVersionTable.PSVersion
Write-Host "   PowerShell версия: $psVersion" -ForegroundColor Green

if ($psVersion.Major -lt 5) {
    Write-Host "   ⚠️  Рекомендуется PowerShell 5.1 или выше" -ForegroundColor Yellow
} else {
    Write-Host "   ✅ PowerShell версия подходит" -ForegroundColor Green
}

# Проверка Windows версии
Write-Host "`n2️⃣ Проверка Windows..." -ForegroundColor Yellow
$osInfo = Get-ComputerInfo | Select-Object WindowsProductName, WindowsVersion
Write-Host "   ОС: $($osInfo.WindowsProductName)" -ForegroundColor Green
Write-Host "   Версия: $($osInfo.WindowsVersion)" -ForegroundColor Green

# Проверка архитектуры
$arch = [Environment]::Is64BitOperatingSystem
if ($arch) {
    Write-Host "   ✅ 64-битная система" -ForegroundColor Green
} else {
    Write-Host "   ❌ Требуется 64-битная система" -ForegroundColor Red
    exit 1
}

# Проверка доступной памяти
Write-Host "`n3️⃣ Проверка памяти..." -ForegroundColor Yellow
$memory = Get-CimInstance -ClassName Win32_ComputerSystem | Select-Object TotalPhysicalMemory
$memoryGB = [math]::Round($memory.TotalPhysicalMemory / 1GB, 1)
Write-Host "   Доступная память: $memoryGB GB" -ForegroundColor Green

if ($memoryGB -lt 8) {
    Write-Host "   ⚠️  Рекомендуется минимум 8 GB RAM" -ForegroundColor Yellow
} else {
    Write-Host "   ✅ Достаточно памяти" -ForegroundColor Green
}

# Проверка свободного места на диске
Write-Host "`n4️⃣ Проверка свободного места..." -ForegroundColor Yellow
$drive = Get-PSDrive C
$freeSpaceGB = [math]::Round($drive.Free / 1GB, 1)
Write-Host "   Свободное место на C: $freeSpaceGB GB" -ForegroundColor Green

if ($freeSpaceGB -lt 10) {
    Write-Host "   ⚠️  Рекомендуется минимум 10 GB свободного места" -ForegroundColor Yellow
} else {
    Write-Host "   ✅ Достаточно места" -ForegroundColor Green
}

# Проверка Conda
Write-Host "`n5️⃣ Проверка Conda..." -ForegroundColor Yellow
try {
    $condaVersion = conda --version
    Write-Host "   ✅ Conda установлен: $condaVersion" -ForegroundColor Green
    
    # Проверка доступности conda
    $condaPath = Get-Command conda -ErrorAction SilentlyContinue
    if ($condaPath) {
        Write-Host "   ✅ Conda доступен в PATH" -ForegroundColor Green
    } else {
        Write-Host "   ⚠️  Conda не найден в PATH" -ForegroundColor Yellow
    }
} catch {
    Write-Host "   ❌ Conda не установлен" -ForegroundColor Red
    Write-Host "   💡 Установите Miniconda: https://docs.conda.io/en/latest/miniconda.html" -ForegroundColor Cyan
    exit 1
}

# Проверка Git
Write-Host "`n6️⃣ Проверка Git..." -ForegroundColor Yellow
try {
    $gitVersion = git --version
    Write-Host "   ✅ Git установлен: $gitVersion" -ForegroundColor Green
} catch {
    Write-Host "   ⚠️  Git не установлен (не критично)" -ForegroundColor Yellow
}

# Проверка интернет-соединения
Write-Host "`n7️⃣ Проверка интернет-соединения..." -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri "https://www.google.com" -TimeoutSec 10 -UseBasicParsing
    Write-Host "   ✅ Интернет-соединение работает" -ForegroundColor Green
} catch {
    Write-Host "   ❌ Проблемы с интернет-соединением" -ForegroundColor Red
    Write-Host "   💡 Проверьте подключение к интернету" -ForegroundColor Cyan
}

# Проверка Intel Arc (если есть)
Write-Host "`n8️⃣ Проверка Intel Arc..." -ForegroundColor Yellow
try {
    $gpuInfo = Get-CimInstance -ClassName Win32_VideoController -ErrorAction SilentlyContinue | Where-Object { $_.Name -like "*Intel*Arc*" }
    if ($gpuInfo) {
        Write-Host "   ✅ Intel Arc обнаружен: $($gpuInfo.Name)" -ForegroundColor Green
        if ($gpuInfo.AdapterRAM) {
            Write-Host "   💾 Видеопамять: $([math]::Round($gpuInfo.AdapterRAM / 1GB, 1)) GB" -ForegroundColor Green
        }
    } else {
        Write-Host "   ℹ️  Intel Arc не обнаружен (будет использоваться CPU)" -ForegroundColor Blue
    }
} catch {
    Write-Host "   ⚠️  Не удалось проверить GPU" -ForegroundColor Yellow
}

Write-Host "`n" + "=" * 60 -ForegroundColor Cyan
Write-Host "📊 РЕЗУЛЬТАТ ПРОВЕРКИ СИСТЕМЫ" -ForegroundColor Cyan
Write-Host "✅ Система готова к установке LFP-TGbot-LLM-RAG" -ForegroundColor Green
Write-Host "`n💡 Следующий шаг: запустите .\setup_env.ps1" -ForegroundColor Yellow 