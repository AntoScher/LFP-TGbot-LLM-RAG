# Главный скрипт для пошаговой проверки проекта LFP-TGbot-LLM-RAG
# Запуск: .\run_all_tests.ps1

Write-Host "🚀 ПОШАГОВАЯ ПРОВЕРКА LFP-TGbot-LLM-RAG" -ForegroundColor Cyan
Write-Host "=" * 70 -ForegroundColor Cyan

$currentStep = 0
$totalSteps = 6

function Show-Step {
    param($step, $title)
    $global:currentStep = $step
    Write-Host "`n📋 ЭТАП $step из $totalSteps: $title" -ForegroundColor Yellow
    Write-Host "-" * 50 -ForegroundColor Gray
}

function Show-Result {
    param($success, $message)
    if ($success) {
        Write-Host "✅ $message" -ForegroundColor Green
    } else {
        Write-Host "❌ $message" -ForegroundColor Red
    }
}

# Этап 1: Проверка системы
Show-Step 1 "Проверка системы"
try {
    & .\check_system.ps1
    $systemOk = $LASTEXITCODE -eq 0
    Show-Result $systemOk "Проверка системы завершена"
} catch {
    Show-Result $false "Ошибка проверки системы: $_"
    $systemOk = $false
}

if (-not $systemOk) {
    Write-Host "`n❌ Система не готова. Исправьте проблемы и повторите." -ForegroundColor Red
    exit 1
}

# Этап 2: Установка окружения
Show-Step 2 "Установка окружения"
$installChoice = Read-Host "`nУстановить окружение? (y/n)"
if ($installChoice -eq "y" -or $installChoice -eq "Y") {
    try {
        Write-Host "Запуск установки окружения..." -ForegroundColor Cyan
        & .\setup_env.ps1
        $installOk = $LASTEXITCODE -eq 0
        Show-Result $installOk "Установка окружения завершена"
    } catch {
        Show-Result $false "Ошибка установки: $_"
        $installOk = $false
    }
} else {
    Write-Host "Пропуск установки окружения" -ForegroundColor Yellow
    $installOk = $true
}

# Этап 3: Проверка установки
Show-Step 3 "Проверка установки"
try {
    & .\check_installation.ps1
    $installationOk = $LASTEXITCODE -eq 0
    Show-Result $installationOk "Проверка установки завершена"
} catch {
    Show-Result $false "Ошибка проверки установки: $_"
    $installationOk = $false
}

if (-not $installationOk) {
    Write-Host "`n❌ Проблемы с установкой. Исправьте и повторите этап 2." -ForegroundColor Red
    exit 1
}

# Этап 4: Быстрый тест Intel Arc
Show-Step 4 "Быстрый тест Intel Arc"
$arcChoice = Read-Host "`nЗапустить быстрый тест Intel Arc? (y/n)"
if ($arcChoice -eq "y" -or $arcChoice -eq "Y") {
    try {
        conda run -n lfp_bot_py311 python test_intel_arc_simple.py
        $arcOk = $LASTEXITCODE -eq 0
        Show-Result $arcOk "Быстрый тест Intel Arc завершен"
    } catch {
        Show-Result $false "Ошибка теста Intel Arc: $_"
        $arcOk = $false
    }
} else {
    Write-Host "Пропуск теста Intel Arc" -ForegroundColor Yellow
    $arcOk = $true
}

# Этап 5: Полный тест Intel Arc
Show-Step 5 "Полный тест Intel Arc"
$fullArcChoice = Read-Host "`nЗапустить полный тест Intel Arc? (займет 5-10 минут) (y/n)"
if ($fullArcChoice -eq "y" -or $fullArcChoice -eq "Y") {
    try {
        conda run -n lfp_bot_py311 python test_intel_arc.py
        $fullArcOk = $LASTEXITCODE -eq 0
        Show-Result $fullArcOk "Полный тест Intel Arc завершен"
    } catch {
        Show-Result $false "Ошибка полного теста Intel Arc: $_"
        $fullArcOk = $false
    }
} else {
    Write-Host "Пропуск полного теста Intel Arc" -ForegroundColor Yellow
    $fullArcOk = $true
}

# Этап 6: Тест компонентов бота
Show-Step 6 "Тест компонентов бота"
try {
    conda run -n lfp_bot_py311 python test_bot_components.py
    $componentsOk = $LASTEXITCODE -eq 0
    Show-Result $componentsOk "Тест компонентов бота завершен"
} catch {
    Show-Result $false "Ошибка теста компонентов: $_"
    $componentsOk = $false
}

# Итоговый результат
Write-Host "`n" + "=" * 70 -ForegroundColor Cyan
Write-Host "📊 ИТОГОВЫЙ РЕЗУЛЬТАТ ПРОВЕРКИ" -ForegroundColor Cyan

$results = @(
    @{Name="Система"; Ok=$systemOk},
    @{Name="Установка"; Ok=$installOk},
    @{Name="Проверка установки"; Ok=$installationOk},
    @{Name="Быстрый тест Intel Arc"; Ok=$arcOk},
    @{Name="Полный тест Intel Arc"; Ok=$fullArcOk},
    @{Name="Компоненты бота"; Ok=$componentsOk}
)

$passed = 0
foreach ($result in $results) {
    $status = if ($result.Ok) { "✅ ПРОЙДЕН" } else { "❌ ПРОВАЛЕН" }
    Write-Host "  $($result.Name): $status" -ForegroundColor $(if ($result.Ok) { "Green" } else { "Red" })
    if ($result.Ok) { $passed++ }
}

Write-Host "`n📈 Пройдено этапов: $passed/$totalSteps" -ForegroundColor Cyan

if ($passed -eq $totalSteps) {
    Write-Host "`n🎉 ВСЕ ТЕСТЫ ПРОЙДЕНЫ!" -ForegroundColor Green
    Write-Host "💡 Проект готов к работе!" -ForegroundColor Green
    Write-Host "`n🚀 Для запуска бота используйте:" -ForegroundColor Yellow
    Write-Host "   .\start_optimized.ps1 bot.py" -ForegroundColor Cyan
} elseif ($passed -ge 4) {
    Write-Host "`n⚠️  БОЛЬШИНСТВО ТЕСТОВ ПРОЙДЕНО" -ForegroundColor Yellow
    Write-Host "💡 Проект может работать с ограничениями" -ForegroundColor Yellow
    Write-Host "`n🚀 Для запуска бота используйте:" -ForegroundColor Yellow
    Write-Host "   .\start_optimized.ps1 bot.py" -ForegroundColor Cyan
} else {
    Write-Host "`n❌ КРИТИЧЕСКИЕ ПРОБЛЕМЫ" -ForegroundColor Red
    Write-Host "💡 Исправьте ошибки и повторите проверку" -ForegroundColor Red
}

Write-Host "`n📝 ЛОГИ ТЕСТОВ:" -ForegroundColor Cyan
Write-Host "   - Система: check_system.ps1" -ForegroundColor Gray
Write-Host "   - Установка: setup_env.ps1" -ForegroundColor Gray
Write-Host "   - Проверка: check_installation.ps1" -ForegroundColor Gray
Write-Host "   - Intel Arc: test_intel_arc_simple.py" -ForegroundColor Gray
Write-Host "   - Полный тест: test_intel_arc.py" -ForegroundColor Gray
Write-Host "   - Компоненты: test_bot_components.py" -ForegroundColor Gray 