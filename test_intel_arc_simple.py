#!/usr/bin/env python3
"""
Упрощенный тест Intel Arc iGPU для быстрой проверки
"""

import torch
import os
import sys

def test_basic_xpu():
    """Базовая проверка Intel XPU"""
    print("🔍 Базовая проверка Intel XPU...")
    
    if not hasattr(torch, 'xpu'):
        print("❌ PyTorch не поддерживает XPU")
        return False
    
    if not torch.xpu.is_available():
        print("❌ Intel XPU недоступен")
        return False
    
    device_count = torch.xpu.device_count()
    print(f"✅ Intel XPU доступен, устройств: {device_count}")
    
    for i in range(device_count):
        device_name = torch.xpu.get_device_name(i)
        memory_info = torch.xpu.get_device_properties(i)
        print(f"  Устройство {i}: {device_name}")
        print(f"  Память: {memory_info.total_memory / 1024**3:.1f} GB")
    
    return True

def test_ipex_import():
    """Проверка импорта Intel Extension for PyTorch"""
    print("\n🔍 Проверка Intel Extension for PyTorch...")
    
    try:
        import intel_extension_for_pytorch as ipex
        print("✅ Intel Extension for PyTorch импортирован")
        print(f"  Версия: {ipex.__version__}")
        return True
    except ImportError as e:
        print(f"❌ Intel Extension for PyTorch не установлен: {e}")
        return False

def test_simple_tensor_ops():
    """Тест простых операций с тензорами на XPU"""
    print("\n🔍 Тест операций с тензорами...")
    
    try:
        # Создание тензора на XPU
        x = torch.randn(100, 100).to("xpu")
        y = torch.randn(100, 100).to("xpu")
        
        # Простые операции
        z = torch.matmul(x, y)
        w = torch.relu(z)
        
        print("✅ Операции с тензорами работают")
        print(f"  Результат: {w.shape}, тип: {w.dtype}")
        
        # Очистка памяти
        torch.xpu.empty_cache()
        
        return True
        
    except Exception as e:
        print(f"❌ Ошибка операций с тензорами: {e}")
        return False

def test_environment_vars():
    """Проверка переменных окружения"""
    print("\n🔍 Проверка переменных окружения...")
    
    env_vars = [
        "SYCL_CACHE_PERSISTENT",
        "ENABLE_LP64", 
        "SYCL_DEVICE_FILTER",
        "ONEAPI_DEVICE_SELECTOR",
        "OMP_NUM_THREADS",
        "KMP_BLOCKTIME"
    ]
    
    missing_vars = []
    for var in env_vars:
        value = os.getenv(var)
        if value:
            print(f"  ✅ {var}={value}")
        else:
            print(f"  ⚠️  {var} не установлена")
            missing_vars.append(var)
    
    if missing_vars:
        print(f"  💡 Установите переменные окружения для оптимизации")
        return False
    else:
        print("  ✅ Все переменные окружения установлены")
        return True

def main():
    """Основная функция тестирования"""
    print("🚀 БЫСТРЫЙ ТЕСТ Intel Arc iGPU")
    print("=" * 50)
    
    # Тесты
    tests = [
        ("XPU доступность", test_basic_xpu),
        ("IPEX импорт", test_ipex_import),
        ("Операции с тензорами", test_simple_tensor_ops),
        ("Переменные окружения", test_environment_vars)
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
    print("📊 РЕЗУЛЬТАТЫ БЫСТРОГО ТЕСТА:")
    
    passed = 0
    for i, (name, result) in enumerate(results):
        status = "✅ ПРОЙДЕН" if result else "❌ ПРОВАЛЕН"
        print(f"  {i+1}. {name}: {status}")
        if result:
            passed += 1
    
    print(f"\n📈 Пройдено тестов: {passed}/{len(results)}")
    
    if passed == len(results):
        print("\n🎉 Intel Arc готов к работе!")
        print("💡 Можете запускать полный тест: python test_intel_arc.py")
    elif passed >= 2:
        print("\n⚠️  Intel Arc частично работает")
        print("💡 Проверьте установку драйверов и зависимостей")
    else:
        print("\n❌ Intel Arc не работает")
        print("💡 Переустановите зависимости: .\setup_env.ps1")

if __name__ == "__main__":
    main() 