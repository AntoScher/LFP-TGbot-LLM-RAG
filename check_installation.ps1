# Скрипт проверки установки окружения LFP-TGbot-LLM-RAG
# Запуск: .\check_installation.ps1

Write-Host "🔍 ПРОВЕРКА УСТАНОВКИ ОКРУЖЕНИЯ" -ForegroundColor Cyan
Write-Host "=" * 60 -ForegroundColor Cyan

$envName = "lfp_bot_py311"

# Проверка существования окружения
Write-Host "1️⃣ Проверка conda окружения..." -ForegroundColor Yellow
try {
    $envs = conda env list --json | ConvertFrom-Json
    $envExists = $envs.envs -match $envName -or $envs.envs -match [regex]::Escape($envName)
    
    if ($envExists) {
        Write-Host "   ✅ Окружение '$envName' существует" -ForegroundColor Green
    } else {
        Write-Host "   ❌ Окружение '$envName' не найдено" -ForegroundColor Red
        Write-Host "   💡 Запустите .\setup_env.ps1" -ForegroundColor Cyan
        exit 1
    }
} catch {
    Write-Host "   ❌ Ошибка проверки окружения: $_" -ForegroundColor Red
    exit 1
}

# Проверка Python версии
Write-Host "`n2️⃣ Проверка Python версии..." -ForegroundColor Yellow
try {
    $pythonVersion = conda run -n $envName python --version
    Write-Host "   ✅ Python версия: $pythonVersion" -ForegroundColor Green
    
    # Проверка что это Python 3.11
    if ($pythonVersion -match "Python 3\.11") {
        Write-Host "   ✅ Правильная версия Python 3.11" -ForegroundColor Green
    } else {
        Write-Host "   ⚠️  Неправильная версия Python (нужна 3.11)" -ForegroundColor Yellow
    }
} catch {
    Write-Host "   ❌ Ошибка проверки Python: $_" -ForegroundColor Red
    exit 1
}

# Проверка критических пакетов
Write-Host "`n3️⃣ Проверка критических пакетов..." -ForegroundColor Yellow
$criticalPackages = @(
    "torch",
    "transformers", 
    "python-telegram-bot",
    "flask",
    "langchain",
    "chromadb"
)

$missingPackages = @()
foreach ($pkg in $criticalPackages) {
    try {
        $installed = conda run -n $envName pip show $pkg
        if ($installed) {
            $version = ($installed | Select-String "Version:").ToString().Split(":")[1].Trim()
            Write-Host "   ✅ $pkg (версия: $version)" -ForegroundColor Green
        } else {
            $missingPackages += $pkg
        }
    } catch {
        $missingPackages += $pkg
    }
}

if ($missingPackages.Count -gt 0) {
    Write-Host "   ❌ Отсутствуют пакеты: $($missingPackages -join ', ')" -ForegroundColor Red
    Write-Host "   💡 Переустановите зависимости: .\setup_env.ps1" -ForegroundColor Cyan
} else {
    Write-Host "   ✅ Все критические пакеты установлены" -ForegroundColor Green
}

# Проверка Intel XPU пакетов
Write-Host "`n4️⃣ Проверка Intel XPU пакетов..." -ForegroundColor Yellow
$xpuPackages = @(
    "intel-extension-for-pytorch",
    "ipex-llm"
)

$xpuMissing = @()
foreach ($pkg in $xpuPackages) {
    try {
        $installed = conda run -n $envName pip show $pkg
        if ($installed) {
            $version = ($installed | Select-String "Version:").ToString().Split(":")[1].Trim()
            Write-Host "   ✅ $pkg (версия: $version)" -ForegroundColor Green
        } else {
            $xpuMissing += $pkg
        }
    } catch {
        $xpuMissing += $pkg
    }
}

if ($xpuMissing.Count -gt 0) {
    Write-Host "   ⚠️  Отсутствуют XPU пакеты: $($xpuMissing -join ', ')" -ForegroundColor Yellow
    Write-Host "   💡 Intel Arc будет недоступен" -ForegroundColor Cyan
} else {
    Write-Host "   ✅ Intel XPU пакеты установлены" -ForegroundColor Green
}

# Проверка .env файла
Write-Host "`n5️⃣ Проверка конфигурации..." -ForegroundColor Yellow
$envFile = ".\.env"
if (Test-Path $envFile) {
    Write-Host "   ✅ Файл .env существует" -ForegroundColor Green
    
    # Проверка обязательных переменных
    $envContent = Get-Content $envFile
    $requiredVars = @("TELEGRAM_TOKEN", "HUGGINGFACEHUB_API_TOKEN")
    $missingVars = @()
    
    foreach ($var in $requiredVars) {
        if ($envContent -match "^$var=") {
            Write-Host "   ✅ $var настроен" -ForegroundColor Green
        } else {
            $missingVars += $var
        }
    }
    
    if ($missingVars.Count -gt 0) {
        Write-Host "   ⚠️  Не настроены: $($missingVars -join ', ')" -ForegroundColor Yellow
        Write-Host "   💡 Отредактируйте файл .env" -ForegroundColor Cyan
    }
} else {
    Write-Host "   ❌ Файл .env не найден" -ForegroundColor Red
    Write-Host "   💡 Запустите .\setup_env.ps1 для создания" -ForegroundColor Cyan
}

# Проверка структуры проекта
Write-Host "`n6️⃣ Проверка структуры проекта..." -ForegroundColor Yellow
$requiredFiles = @(
    "bot.py",
    "chains.py", 
    "embeddings.py",
    "requirements.txt",
    "start_bot.ps1"
)

$missingFiles = @()
foreach ($file in $requiredFiles) {
    if (Test-Path $file) {
        Write-Host "   ✅ $file" -ForegroundColor Green
    } else {
        $missingFiles += $file
    }
}

if ($missingFiles.Count -gt 0) {
    Write-Host "   ❌ Отсутствуют файлы: $($missingFiles -join ', ')" -ForegroundColor Red
} else {
    Write-Host "   ✅ Все основные файлы на месте" -ForegroundColor Green
}

# Проверка базы знаний
Write-Host "`n7️⃣ Проверка базы знаний..." -ForegroundColor Yellow
$knowledgeDir = ".\knowledge_base"
if (Test-Path $knowledgeDir) {
    $files = Get-ChildItem $knowledgeDir -File
    Write-Host "   ✅ Папка knowledge_base существует" -ForegroundColor Green
    Write-Host "   📁 Файлов в базе знаний: $($files.Count)" -ForegroundColor Green
    
    foreach ($file in $files) {
        Write-Host "     - $($file.Name)" -ForegroundColor Gray
    }
} else {
    Write-Host "   ⚠️  Папка knowledge_base не найдена" -ForegroundColor Yellow
}

Write-Host "`n" + "=" * 60 -ForegroundColor Cyan
Write-Host "📊 РЕЗУЛЬТАТ ПРОВЕРКИ УСТАНОВКИ" -ForegroundColor Cyan

if ($missingPackages.Count -eq 0 -and $missingFiles.Count -eq 0) {
    Write-Host "✅ Установка прошла успешно!" -ForegroundColor Green
    Write-Host "`n💡 Следующий шаг: запустите python test_intel_arc.py" -ForegroundColor Yellow
} else {
    Write-Host "⚠️  Есть проблемы с установкой" -ForegroundColor Yellow
    Write-Host "💡 Исправьте ошибки и повторите проверку" -ForegroundColor Cyan
} 