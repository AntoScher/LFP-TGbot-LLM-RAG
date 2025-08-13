# Упрощенная проверка системы для диагностики
Write-Host "🔍 ДИАГНОСТИКА СИСТЕМЫ" -ForegroundColor Cyan
Write-Host "=" * 40 -ForegroundColor Cyan

# Тест 1: PowerShell
Write-Host "1️⃣ PowerShell..." -ForegroundColor Yellow
try {
    $psVersion = $PSVersionTable.PSVersion
    Write-Host "   ✅ Версия: $psVersion" -ForegroundColor Green
} catch {
    Write-Host "   ❌ Ошибка: $_" -ForegroundColor Red
}

# Тест 2: Windows
Write-Host "`n2️⃣ Windows..." -ForegroundColor Yellow
try {
    $osInfo = Get-ComputerInfo | Select-Object WindowsProductName, WindowsVersion
    Write-Host "   ✅ ОС: $($osInfo.WindowsProductName)" -ForegroundColor Green
} catch {
    Write-Host "   ❌ Ошибка: $_" -ForegroundColor Red
}

# Тест 3: Архитектура
Write-Host "`n3️⃣ Архитектура..." -ForegroundColor Yellow
try {
    $arch = [Environment]::Is64BitOperatingSystem
    Write-Host "   ✅ 64-битная: $arch" -ForegroundColor Green
} catch {
    Write-Host "   ❌ Ошибка: $_" -ForegroundColor Red
}

# Тест 4: Память
Write-Host "`n4️⃣ Память..." -ForegroundColor Yellow
try {
    $memory = Get-CimInstance -ClassName Win32_ComputerSystem | Select-Object TotalPhysicalMemory
    $memoryGB = [math]::Round($memory.TotalPhysicalMemory / 1GB, 1)
    Write-Host "   ✅ RAM: $memoryGB GB" -ForegroundColor Green
} catch {
    Write-Host "   ❌ Ошибка: $_" -ForegroundColor Red
}

# Тест 5: Диск
Write-Host "`n5️⃣ Диск..." -ForegroundColor Yellow
try {
    $drive = Get-PSDrive C
    $freeSpaceGB = [math]::Round($drive.Free / 1GB, 1)
    Write-Host "   ✅ Свободно: $freeSpaceGB GB" -ForegroundColor Green
} catch {
    Write-Host "   ❌ Ошибка: $_" -ForegroundColor Red
}

# Тест 6: Conda
Write-Host "`n6️⃣ Conda..." -ForegroundColor Yellow
try {
    $condaVersion = conda --version
    Write-Host "   ✅ Conda: $condaVersion" -ForegroundColor Green
} catch {
    Write-Host "   ❌ Conda не найден" -ForegroundColor Red
}

# Тест 7: Интернет
Write-Host "`n7️⃣ Интернет..." -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri "https://www.google.com" -TimeoutSec 5 -UseBasicParsing
    Write-Host "   ✅ Интернет работает" -ForegroundColor Green
} catch {
    Write-Host "   ❌ Проблемы с интернетом" -ForegroundColor Red
}

Write-Host "`n" + "=" * 40 -ForegroundColor Cyan
Write-Host "✅ ДИАГНОСТИКА ЗАВЕРШЕНА" -ForegroundColor Green 