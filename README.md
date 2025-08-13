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

- Python 3.11 (обязательно, не 3.12+)
- 8+ GB RAM (для работы с 1.5B-моделью)
- NVIDIA GPU с 8+ GB VRAM (опционально)
- Intel Arc GPU с 2+ GB VRAM (опционально, для XPU)

## 🛠️ Установка

### 1. Клонирование репозитория
```bash
git clone https://github.com/yourusername/LFP-TGbot-LLM-RAG.git
cd LFP-TGbot-LLM-RAG
```

### 2. Настройка окружения

#### Windows (PowerShell) - Рекомендуется:
```powershell
.\setup_env.ps1
```

#### Для Intel Arc GPU (дополнительно):
```powershell
# Запуск тестирования Intel Arc
python test_intel_arc.py

# Оптимизированный запуск
.\start_optimized.ps1 bot.py
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
# Telegram Bot
TELEGRAM_TOKEN=your_telegram_token_here
ADMIN_TELEGRAM_ID=your_admin_id

# Hugging Face
HUGGINGFACEHUB_API_TOKEN=your_hf_token_here
MODEL_NAME=Qwen/Qwen2-1.5B-Instruct
EMBEDDING_MODEL=sentence-transformers/all-MiniLM-L6-v2

# Device (cpu, cuda, xpu, mps)
DEVICE=cpu

# Database
DATABASE_URI=sqlite:///flask_app.db
# Для PostgreSQL: postgresql://user:pass@localhost/dbname

# Vector Store
CHROMA_DB_PATH=./chroma_db
```

### 4. Тестирование установки

#### Быстрая проверка (рекомендуется):
```powershell
.\run_all_tests.ps1
```

#### Пошаговая проверка:
```powershell
# 1. Проверка системы
.\check_system.ps1

# 2. Установка окружения
.\setup_env.ps1

# 3. Проверка установки
.\check_installation.ps1

# 4. Быстрый тест Intel Arc
conda run -n lfp_bot_py311 python test_intel_arc_simple.py

# 5. Полный тест Intel Arc (5-10 минут)
conda run -n lfp_bot_py311 python test_intel_arc.py

# 6. Тест компонентов бота
conda run -n lfp_bot_py311 python test_bot_components.py
```

### 5. Индексация базы знаний

Перед первым запуском создайте векторную БД из текстов в `knowledge_base` (используются только .txt и .md):
```powershell
python .\ingest.py
```

### 6. Запуск бота
Запуск в двух режимах на CPU.

```powershell
# Вариант A: Чистый CPU (PyTorch)
$env:INFERENCE_BACKEND="cpu"
$env:DEVICE="cpu"
$env:PYTHONUNBUFFERED="1"
python .\bot.py

# Вариант B: OpenVINO (ускоренный CPU)
# Требуется установить пакеты (один раз):
# python -m pip install -U openvino optimum-intel transformers huggingface_hub
$env:INFERENCE_BACKEND="openvino"
$env:OPENVINO_DEVICE="CPU"
$env:PYTHONUNBUFFERED="1"
python .\bot.py
```

## 🐳 Docker развертывание

### Сборка и запуск:
```bash
docker-compose up --build
```

### Только с Docker:
```bash
docker build -t lfp-bot .
docker run -d --name lfp-bot --env-file .env lfp-bot
```

## 📁 Структура проекта

```
LFP-TGbot-LLM-RAG/
├── bot.py                 # Основной файл бота
├── chains.py              # LangChain цепи и LLM
├── embeddings.py          # Векторное хранилище
├── flask_app/             # Flask приложение
│   ├── __init__.py
│   └── models.py          # Модели базы данных
├── knowledge_base/        # База знаний
│   ├── system_prompt.txt  # Системный промпт
│   └── *.md              # Документы знаний
├── requirements.txt       # Зависимости
├── requirements_xpu.txt   # Зависимости для XPU
├── test_bot.py           # Тесты
├── Dockerfile            # Docker конфигурация
└── docker-compose.yml    # Docker Compose
```

## 🔧 Конфигурация

### Модели
- **LLM**: microsoft/phi-2 (для Intel Arc), Qwen2-1.5B-Instruct (для CPU/CUDA)
- **Embeddings**: all-MiniLM-L6-v2
- **Vector Store**: ChromaDB

### Устройства
- **CPU**: Стандартная работа
- **XPU**: Ускорение на Intel Arc (2+ GB VRAM, 4-битное квантование)
- **CUDA**: Ускорение на NVIDIA GPU

## 📊 Мониторинг

### Логи
- Файл: `bot.log`
- Уровень: INFO
- Формат: Временная метка, уровень, сообщение

### База данных
- **SQLite**: Для разработки
- **PostgreSQL**: Для продакшена

## 🚨 Устранение неполадок

### Частые проблемы:

1. **Ошибка импорта модулей**
   ```bash
   pip install -r requirements.txt
   ```

2. **Недостаточно памяти**
   - Уменьшите размер модели
   - Используйте квантование

3. **Ошибки Telegram API**
   - Проверьте токен бота
   - Убедитесь в правах бота

4. **Проблемы с базой данных**
   ```bash
   python -c "from flask_app import create_app, db; app = create_app(); app.app_context().push(); db.create_all()"
   ```

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
