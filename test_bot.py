#!/usr/bin/env python3
"""
Тестовый скрипт для проверки работоспособности основных компонентов бота
"""

import os
import sys
import logging
from dotenv import load_dotenv

# Настройка логирования
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

def test_environment():
    """Проверка переменных окружения"""
    logger.info("🔍 Проверка переменных окружения...")
    
    load_dotenv()
    
    required_vars = [
        "TELEGRAM_TOKEN",
        "HUGGINGFACEHUB_API_TOKEN"
    ]
    
    missing_vars = []
    for var in required_vars:
        if not os.getenv(var):
            missing_vars.append(var)
    
    if missing_vars:
        logger.error(f"❌ Отсутствуют обязательные переменные: {', '.join(missing_vars)}")
        return False
    
    logger.info("✅ Переменные окружения настроены корректно")
    return True

def test_imports():
    """Проверка импортов основных модулей"""
    logger.info("🔍 Проверка импортов...")
    
    try:
        import telegram
        logger.info("✅ python-telegram-bot импортирован")
    except ImportError as e:
        logger.error(f"❌ Ошибка импорта python-telegram-bot: {e}")
        return False
    
    try:
        import transformers
        logger.info("✅ transformers импортирован")
    except ImportError as e:
        logger.error(f"❌ Ошибка импорта transformers: {e}")
        return False
    
    try:
        import torch
        logger.info(f"✅ PyTorch импортирован (версия: {torch.__version__})")
    except ImportError as e:
        logger.error(f"❌ Ошибка импорта PyTorch: {e}")
        return False
    
    try:
        import langchain
        logger.info(f"✅ LangChain импортирован (версия: {langchain.__version__})")
    except ImportError as e:
        logger.error(f"❌ Ошибка импорта LangChain: {e}")
        return False
    
    try:
        import chromadb
        logger.info(f"✅ ChromaDB импортирован (версия: {chromadb.__version__})")
    except ImportError as e:
        logger.error(f"❌ Ошибка импорта ChromaDB: {e}")
        return False
    
    return True

def test_flask_app():
    """Проверка Flask приложения"""
    logger.info("🔍 Проверка Flask приложения...")
    
    try:
        from flask_app import create_app, db
        app = create_app()
        
        with app.app_context():
            db.create_all()
            logger.info("✅ База данных инициализирована")
        
        logger.info("✅ Flask приложение работает корректно")
        return True
        
    except Exception as e:
        logger.error(f"❌ Ошибка Flask приложения: {e}")
        return False

def test_embeddings():
    """Проверка модуля эмбеддингов"""
    logger.info("🔍 Проверка модуля эмбеддингов...")
    
    try:
        from embeddings import init_vector_store
        logger.info("✅ Модуль эмбеддингов импортирован")
        return True
        
    except Exception as e:
        logger.error(f"❌ Ошибка модуля эмбеддингов: {e}")
        return False

def test_chains():
    """Проверка модуля цепей"""
    logger.info("🔍 Проверка модуля цепей...")
    
    try:
        from chains import init_qa_chain, load_system_prompt
        system_prompt = load_system_prompt()
        logger.info(f"✅ Системный промпт загружен ({len(system_prompt)} символов)")
        return True
        
    except Exception as e:
        logger.error(f"❌ Ошибка модуля цепей: {e}")
        return False

def main():
    """Основная функция тестирования"""
    logger.info("🚀 Начинаем тестирование компонентов бота...")
    
    tests = [
        test_environment,
        test_imports,
        test_flask_app,
        test_embeddings,
        test_chains
    ]
    
    passed = 0
    total = len(tests)
    
    for test in tests:
        try:
            if test():
                passed += 1
        except Exception as e:
            logger.error(f"❌ Критическая ошибка в тесте {test.__name__}: {e}")
    
    logger.info(f"\n📊 Результаты тестирования: {passed}/{total} тестов пройдено")
    
    if passed == total:
        logger.info("🎉 Все тесты пройдены! Бот готов к запуску.")
        return True
    else:
        logger.error("❌ Некоторые тесты не пройдены. Проверьте конфигурацию.")
        return False

if __name__ == "__main__":
    success = main()
    sys.exit(0 if success else 1) 