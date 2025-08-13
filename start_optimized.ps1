# Оптимизированный скрипт запуска для Intel Arc iGPU
# Установка переменных окружения для Intel XPU
$env:SYCL_CACHE_PERSISTENT = "1"
$env:ENABLE_LP64 = "1"
$env:SYCL_DEVICE_FILTER = "level_zero:gpu"
$env:ONEAPI_DEVICE_SELECTOR = "level_zero:*"
$env:OMP_NUM_THREADS = "8"
$env:KMP_BLOCKTIME = "0"

# Создание кэша SYCL
$cacheDir = "$pwd\.sycl_cache"
if (-not (Test-Path $cacheDir)) {
    New-Item -Path $cacheDir -ItemType Directory -Force | Out-Null
}
$env:SYCL_CACHE_DIR = $cacheDir

# Активация conda окружения
$envName = "lfp_bot_py311"
conda activate $envName

# Запуск Python с высоким приоритетом
Start-Process -FilePath "python" -ArgumentList $args -NoNewWindow -Wait -PriorityClass High 