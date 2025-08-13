#!/usr/bin/env python3
"""
Тест компонентов бота без запуска Telegram API
"""

import os
import sys
import logging
from dotenv import load_dotenv

# Настройка логирования
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

def test_environment_variables():
    """Проверка переменных окружения"""
    print("🔍 Проверка переменных окружения...")
    
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
        print(f"❌ Отсутствуют переменные: {', '.join(missing_vars)}")
        return False
    
    print("✅ Все переменные окружения настроены")
    return True

def test_flask_app():
    """Проверка Flask приложения"""
    print("\n🔍 Проверка Flask приложения...")
    
    try:
        from flask_app import create_app, db
        app = create_app()
        
        with app.app_context():
            db.create_all()
            print("✅ База данных инициализирована")
        
        print("✅ Flask приложение работает")
        return True
        
    except Exception as e:
        print(f"❌ Ошибка Flask приложения: {e}")
        return False

def test_embeddings_module():
    """Проверка модуля эмбеддингов"""
    print("\n🔍 Проверка модуля эмбеддингов...")
    
    try:
        from embeddings import init_vector_store
        
        # Тест инициализации векторного хранилища
        retriever = init_vector_store()
        print("✅ Векторное хранилище инициализировано")
        
        # Тест поиска (если есть документы)
        try:
            results = retriever.get_relevant_documents("тест")
            print(f"✅ Поиск работает, найдено документов: {len(results)}")
        except Exception as e:
            print(f"⚠️  Поиск не работает (возможно, нет документов): {e}")
        
        return True
        
    except Exception as e:
        print(f"❌ Ошибка модуля эмбеддингов: {e}")
        return False

def test_chains_module():
    """Проверка модуля цепочек"""
    print("\n🔍 Проверка модуля цепочек...")
    
    try:
        from chains import init_llm_pipeline, load_system_prompt
        
        # Проверка загрузки системного промпта
        system_prompt = load_system_prompt()
        print(f"✅ Системный промпт загружен ({len(system_prompt)} символов)")
        
        # Проверка инициализации LLM (без загрузки модели)
        print("⚠️  Пропускаем загрузку модели (займет время)")
        print("   Для полной проверки запустите: python test_intel_arc.py")
        
        return True
        
    except Exception as e:
        print(f"❌ Ошибка модуля цепочек: {e}")
        return False

def test_knowledge_base():
    """Проверка базы знаний"""
    print("\n🔍 Проверка базы знаний...")
    
    knowledge_dir = "knowledge_base"
    if not os.path.exists(knowledge_dir):
        print("❌ Папка knowledge_base не найдена")
        return False
    
    files = os.listdir(knowledge_dir)
    if not files:
        print("❌ База знаний пуста")
        return False
    
    print(f"✅ Найдено файлов в базе знаний: {len(files)}")
    
    # Проверка системного промпта
    system_prompt_file = os.path.join(knowledge_dir, "system_prompt.txt")
    if os.path.exists(system_prompt_file):
        with open(system_prompt_file, 'r', encoding='utf-8') as f:
            content = f.read()
            print(f"✅ Системный промпт: {len(content)} символов")
    else:
        print("⚠️  Файл system_prompt.txt не найден")
    
    return True

def test_imports():
    """Проверка импортов основных модулей"""
    print("\n🔍 Проверка импортов...")
    
    modules = [
        ("telegram", "python-telegram-bot"),
        ("transformers", "transformers"),
        ("torch", "PyTorch"),
        ("langchain", "LangChain"),
        ("chromadb", "ChromaDB"),
        ("flask", "Flask")
    ]
    
    failed_imports = []
    for module_name, display_name in modules:
        try:
            __import__(module_name)
            print(f"✅ {display_name}")
        except ImportError as e:
            print(f"❌ {display_name}: {e}")
            failed_imports.append(display_name)
    
    if failed_imports:
        print(f"⚠️  Проблемы с импортом: {', '.join(failed_imports)}")
        return False
    
    print("✅ Все модули импортируются")
    return True

def test_file_structure():
    """Проверка структуры файлов"""
    print("\n🔍 Проверка структуры файлов...")
    
    required_files = [
        "bot.py",
        "chains.py",
        "embeddings.py",
        "requirements.txt",
        "start_bot.ps1"
    ]
    
    missing_files = []
    for file in required_files:
        if os.path.exists(file):
            print(f"✅ {file}")
        else:
            print(f"❌ {file}")
            missing_files.append(file)
    
    if missing_files:
        print(f"⚠️  Отсутствуют файлы: {', '.join(missing_files)}")
        return False
    
    print("✅ Все основные файлы на месте")
    return True

def main():
    """Основная функция тестирования"""
    print("🚀 ТЕСТ КОМПОНЕНТОВ БОТА")
    print("=" * 50)
    
    # Тесты
    tests = [
        ("Переменные окружения", test_environment_variables),
        ("Импорты модулей", test_imports),
        ("Структура файлов", test_file_structure),
        ("База знаний", test_knowledge_base),
        ("Flask приложение", test_flask_app),
        ("Модуль эмбеддингов", test_embeddings_module),
        ("Модуль цепочек", test_chains_module)
    ]
    
    results = []
    for name, test_func in tests:
        try:
            result = test_func()
            results.append((name, result))
        except Exception as e:
            print(f"❌ Ошибка в тесте {name}: {e}")
            results.append((name, False))
    
    # Итоговый результат
    print("\n" + "=" * 50)
    print("📊 РЕЗУЛЬТАТЫ ТЕСТА КОМПОНЕНТОВ:")
    
    passed = 0
    for i, (name, result) in enumerate(results):
        status = "✅ ПРОЙДЕН" if result else "❌ ПРОВАЛЕН"
        print(f"  {i+1}. {name}: {status}")
        if result:
            passed += 1
    
    print(f"\n📈 Пройдено тестов: {passed}/{len(results)}")
    
    if passed == len(results):
        print("\n🎉 Все компоненты работают!")
        print("💡 Можете запускать бота: .\start_optimized.ps1 bot.py")
    elif passed >= len(results) - 1:
        print("\n⚠️  Есть незначительные проблемы")
        print("💡 Проверьте настройки и повторите тест")
    else:
        print("\n❌ Критические проблемы")
        print("💡 Переустановите зависимости: .\setup_env.ps1")

if __name__ == "__main__":
    main() 