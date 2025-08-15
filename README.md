# AI-ассистент для отдела продаж

Telegram-бот с RAG-архитектурой для ответов на вопросы клиентов с использованием:
- Языковой модели Qwen2-1.5B-Instruct
- Векторного поиска по базе знаний (ChromaDB)
- Логирования диалогов в SQLite/PostgreSQL

## 🚀 Возможности

- **RAG-архитектура**: Поиск релевантной информации в базе знаний
- **Мультиплатформенность**: Поддержка CPU, XPU (Intel Arc), CUDA
- **Логирование**: Сохранение всех диалогов в базу данных
- **Docker**: Готовая конфигурация для развертывания
- **Масштабируемость**: Поддержка PostgreSQL для продакшена

## 📋 Требования

- Python 3.10+ (рекомендуется 3.10)
- 8+ GB RAM (для работы с 1.5B-моделью)
- NVIDIA GPU с 8+ GB VRAM (опционально)
- Intel Arc GPU с 2+ GB VRAM (опционально, для XPU)
- (Для OpenVINO) `openvino>=2024.2.0`, `optimum-intel>=1.17.0`

## 🛠️ Установка

### 1. Клонирование репозитория
```bash
git clone https://github.com/yourusername/LFP-TGbot-LLM-RAG.git
cd LFP-TGbot-LLM-RAG
```

### 2. Настройка окружения

#### Windows (PowerShell) - Рекомендуется:
```powershell
python -m venv .venv
.venv\Scripts\Activate.ps1
pip install -r requirements.txt
```

#### Linux/macOS:
```bash
python -m venv venv
source venv/bin/activate  # Linux/macOS
# или
venv\Scripts\activate  # Windows
pip install -r requirements.txt
```

### 3. Настройка переменных окружения

Создайте файл `.env`:
```env
# Обязательные
TELEGRAM_TOKEN=your_telegram_token_here
HUGGINGFACEHUB_API_TOKEN=your_hf_token_here

# Настройки базы данных (если используется)
DATABASE_URI=sqlite:///./sql_app.db

# Настройки ChromaDB
CHROMA_DB_PATH=./chroma_db

# Настройки модели (опционально)
MODEL_NAME=Qwen/Qwen2-1.5B-Instruct
DEVICE=cpu
INFERENCE_BACKEND=cpu

# Отключение телеметрии
ANONYMIZED_TELEMETRY=false
```

### 4. Индексация базы знаний

**Важно:** Индексация нужна только один раз и при обновлении базы знаний:
```powershell
python .\ingest.py
```

### 5. Запуск бота

#### 🚀 Рекомендуемый способ - Стартовый скрипт:
```powershell
.\start_simple.ps1
```

Скрипт автоматически:
- ✅ Активирует виртуальное окружение
- ✅ Проверяет Python
- ✅ Показывает сравнение производительности
- ✅ Предлагает выбор режима работы (CPU/OpenVINO)
- ✅ Устанавливает переменные окружения
- ✅ Запускает бота

#### 🔧 Ручной запуск:

```powershell
# Активация окружения
.venv\Scripts\Activate.ps1

# Вариант A: CPU (PyTorch) - РЕКОМЕНДУЕТСЯ
$env:INFERENCE_BACKEND="cpu"
$env:DEVICE="cpu"
$env:PYTHONUNBUFFERED="1"
$env:ANONYMIZED_TELEMETRY="false"
python .\bot.py

# Вариант B: OpenVINO + CPU
$env:INFERENCE_BACKEND="openvino"
$env:OPENVINO_DEVICE="CPU"
$env:PYTHONUNBUFFERED="1"
$env:ANONYMIZED_TELEMETRY="false"
python .\bot.py
```

## ⚙️ Режимы работы

Проект поддерживает два основных режима инференса:

### 📊 Сравнение производительности (тестировано на Qwen2-1.5B-Instruct)

| Режим | Инициализация | Время ответа | Рекомендация |
|-------|---------------|--------------|--------------|
| **CPU (PyTorch)** | ~7 секунд | ~30 секунд | ✅ **Рекомендуется** |
| **OpenVINO + CPU** | ~25 секунд | ~2.5 минуты | ⚠️ Медленнее |

### 🔧 Описание режимов:

#### **CPU (PyTorch)** - **РЕКОМЕНДУЕТСЯ**
- ✅ Быстрая инициализация (~7 сек)
- ✅ Быстрые ответы (~30 сек)
- ✅ Стабильная работа
- ✅ Меньше зависимостей
- ✅ Простая отладка
- ✅ Совместимость с большинством систем

#### **OpenVINO + CPU**
- ⚠️ Медленная инициализация (~25 сек)
- ⚠️ Медленные ответы (~2.5 мин)
- ✅ Оптимизация для Intel CPU
- ✅ Меньше потребление памяти
- ⚠️ Больше зависимостей
- ✅ Поддержка квантования

#### **XPU (Intel Arc)** - **ЭКСПЕРИМЕНТАЛЬНЫЙ**
- 🚧 **Экспериментальный режим** - может не работать
- 🚧 Требует сложной настройки PyTorch с Intel GPU поддержкой
- 🚧 Зависит от версий Intel Extension for Transformers
- 🚧 Может требовать дополнительных драйверов
- ⚠️ **Не рекомендуется для продакшена**

### 🎯 Когда выбирать режим?

**CPU (PyTorch) - рекомендуется для:**
- Быстрых ответов
- Разработки и отладки
- Продакшн с ограниченными ресурсами
- Простоты настройки
- Первого знакомства с ботом
- **Стабильной работы**

**OpenVINO + CPU - для:**
- Оптимизации памяти
- Долгосрочной работы
- Intel-специфичных оптимизаций
- Экспериментов с квантованием

**XPU (Intel Arc) - только для экспериментов:**
- **Не рекомендуется для обычного использования**
- Требует специальной настройки
- Может не работать на всех системах
- Для продвинутых пользователей

### 🔄 Переключение между режимами

**Через стартовый скрипт (рекомендуется):**
```powershell
.\start_simple.ps1
# Выберите режим 1 (CPU) или 2 (OpenVINO)
```

**Ручное переключение:**
```powershell
# Остановите бота (Ctrl+C), затем:

# CPU режим
$env:INFERENCE_BACKEND="cpu"; $env:DEVICE="cpu"; python .\bot.py

# OpenVINO режим
$env:INFERENCE_BACKEND="openvino"; $env:OPENVINO_DEVICE="CPU"; python .\bot.py

# XPU режим (экспериментальный)
$env:DEVICE="xpu"; $env:INFERENCE_BACKEND="cpu"; python .\bot.py
```

## 📁 Структура проекта

```
LFP-TGbot-LLM-RAG/
├── bot.py                 # Основной файл бота
├── chains.py              # LangChain цепи и LLM
├── embeddings.py          # Векторное хранилище
├── ingest.py              # Скрипт индексации базы знаний
├── start_simple.ps1       # Стартовый скрипт (рекомендуется)
├── flask_app/             # Flask приложение
│   ├── __init__.py
│   └── models.py          # Модели базы данных
├── knowledge_base/        # База знаний
│   ├── system_prompt.txt  # Системный промпт
│   └── *.txt, *.md        # Документы знаний
├── logs/                  # Логи бота
├── chroma_db/             # Векторная база данных
├── requirements.txt       # Зависимости
├── requirements.lock.txt  # Замороженные зависимости
├── .env                   # Переменные окружения
└── README.md              # Документация
```

## 🔧 Конфигурация

### Модели
- **LLM**: Qwen2-1.5B-Instruct (по умолчанию)
- **Embeddings**: sentence-transformers/all-MiniLM-L6-v2
- **Vector Store**: ChromaDB

### Устройства
- **CPU**: Стандартная работа (PyTorch)
- **CPU (OpenVINO)**: Оптимизированная работа на Intel CPU

## 📊 Мониторинг

### Логи
- Файл: `logs/bot.log`
- Уровень: INFO
- Формат: Временная метка, уровень, сообщение

### База данных
- **SQLite**: Для разработки (`sql_app.db`)
- **PostgreSQL**: Для продакшена (настройте `DATABASE_URI`)

### Health Check
- Endpoint: `http://localhost:5000/health`
- Статус: 200 OK при работе бота

## 🚨 Устранение неполадок

### Частые проблемы:

1. **Ошибка импорта модулей**
   ```bash
   pip install -r requirements.txt
   ```

2. **Недостаточно памяти**
   - Уменьшите размер модели в `.env`
   - Используйте CPU режим

3. **Ошибки Telegram API**
   - Проверьте `TELEGRAM_TOKEN` в `.env`
   - Убедитесь в правах бота

4. **Проблемы с ChromaDB**
   ```bash
   # Удалите старую базу и пересоздайте
   Remove-Item -Recurse -Force chroma_db
   python .\ingest.py
   ```

5. **Ошибки стартового скрипта**
   ```powershell
   # Проверьте политику выполнения
   Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
   .\start_simple.ps1
   ```

### 🔍 Диагностика

**Проверка окружения:**
```powershell
python -c "import telegram, flask, langchain, transformers; print('OK')"
```

**Проверка переменных:**
```powershell
python -c "from dotenv import load_dotenv; import os; load_dotenv(); print('TELEGRAM_TOKEN:', 'OK' if os.getenv('TELEGRAM_TOKEN') else 'MISSING')"
```

**Проверка базы знаний:**
```powershell
python .\ingest.py
```

**Проверка XPU (экспериментальный):**
```powershell
python -c "import torch; print('PyTorch version:', torch.__version__); print('XPU available:', hasattr(torch, 'xpu') and torch.xpu.is_available() if hasattr(torch, 'xpu') else False)"
```

### 🚨 Проблемы с XPU режимом

**XPU режим не работает - это нормально!**

Если XPU режим не запускается, это ожидаемо. Проблемы:

1. **"XPU is not available, falling back to CPU"**
   - ✅ **Нормально** - используйте CPU режим
   - XPU требует специальной версии PyTorch

2. **"Intel Extension for Transformers not available"**
   - ✅ **Нормально** - используйте CPU режим
   - ITREX требует сложной настройки

3. **"accelerate not found"**
   - ✅ **Нормально** - используйте CPU режим
   - XPU режим экспериментальный

**Решение:** Используйте **CPU (PyTorch)** режим для стабильной работы.

## 🤝 Вклад в проект

1. Fork репозитория
2. Создайте ветку для фичи
3. Внесите изменения
4. Создайте Pull Request

## 📄 Лицензия

MIT License - см. файл [LICENSE](LICENSE)

## 📞 Поддержка

- Issues: [GitHub Issues](https://github.com/yourusername/LFP-TGbot-LLM-RAG/issues)
- Email: support@example.com
