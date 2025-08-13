#!/usr/bin/env python3
"""
Тестовый скрипт для проверки работы с Intel Arc iGPU
"""

import torch
import os
import sys

def test_xpu_availability():
    """Проверка доступности Intel XPU"""
    print("🔍 Проверка Intel XPU...")
    
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

def test_ipex_installation():
    """Проверка установки Intel Extension for PyTorch"""
    print("\n🔍 Проверка Intel Extension for PyTorch...")
    
    try:
        import intel_extension_for_pytorch as ipex
        print("✅ Intel Extension for PyTorch установлен")
        print(f"  Версия: {ipex.__version__}")
        return True
    except ImportError as e:
        print(f"❌ Intel Extension for PyTorch не установлен: {e}")
        return False

def test_model_loading():
    """Тест загрузки модели на Intel Arc"""
    print("\n🔍 Тест загрузки модели...")
    
    try:
        from transformers import AutoModelForCausalLM, AutoTokenizer, BitsAndBytesConfig
        
        # Оптимизация аллокатора памяти
        torch.xpu.set_allocator(torch.xpu.XPUCachingAllocator)
        torch.xpu.empty_cache()
        
        # 4-битная квантование с оптимизациями для 2 ГБ VRAM
        bnb_config = BitsAndBytesConfig(
            load_in_4bit=True,
            bnb_4bit_quant_type="nf4",
            bnb_4bit_compute_dtype=torch.bfloat16,
            bnb_4bit_use_double_quant=True,
            cpu_embedding=True  # КРИТИЧНО для экономии VRAM
        )
        
        # Загрузка легкой модели
        model_id = "microsoft/phi-2"
        print(f"Загружаем модель: {model_id}")
        
        tokenizer = AutoTokenizer.from_pretrained(model_id)
        model = AutoModelForCausalLM.from_pretrained(
            model_id,
            quantization_config=bnb_config,
            max_memory={"xpu": "1.8GB", "cpu": "8GB"},
            torch_dtype=torch.bfloat16,
            trust_remote_code=False,
            low_cpu_mem_usage=True
        )
        
        # Применение IPEX оптимизаций
        import intel_extension_for_pytorch as ipex
        model = ipex.llm.optimize(
            model,
            dtype=torch.bfloat16,
            inplace=True,
            auto_cast="matmul",
            graph_mode=True,
            weights_prepack=True
        )
        
        print("✅ Модель успешно загружена на Intel Arc")
        
        # Тест генерации
        prompt = "Как работает квантование 4-битных моделей?"
        inputs = tokenizer(prompt, return_tensors="pt").to("xpu")
        
        with torch.no_grad():
            outputs = model.generate(**inputs, max_new_tokens=50)
        
        response = tokenizer.decode(outputs[0], skip_special_tokens=True)
        print(f"✅ Генерация работает: {response[:100]}...")
        
        return True
        
    except Exception as e:
        print(f"❌ Ошибка загрузки модели: {e}")
        import traceback
        traceback.print_exc()
        return False

def main():
    """Основная функция тестирования"""
    print("🚀 Тестирование Intel Arc iGPU для LFP-TGbot-LLM-RAG")
    print("=" * 60)
    
    # Проверка переменных окружения
    print("🔍 Проверка переменных окружения...")
    env_vars = [
        "SYCL_CACHE_PERSISTENT",
        "ENABLE_LP64", 
        "SYCL_DEVICE_FILTER",
        "ONEAPI_DEVICE_SELECTOR",
        "OMP_NUM_THREADS",
        "KMP_BLOCKTIME"
    ]
    
    for var in env_vars:
        value = os.getenv(var)
        if value:
            print(f"  ✅ {var}={value}")
        else:
            print(f"  ⚠️  {var} не установлена")
    
    # Тесты
    tests = [
        test_xpu_availability,
        test_ipex_installation,
        test_model_loading
    ]
    
    results = []
    for test in tests:
        try:
            result = test()
            results.append(result)
        except Exception as e:
            print(f"❌ Ошибка в тесте {test.__name__}: {e}")
            results.append(False)
    
    # Итоговый результат
    print("\n" + "=" * 60)
    print("📊 РЕЗУЛЬТАТЫ ТЕСТИРОВАНИЯ:")
    
    test_names = ["XPU доступность", "IPEX установка", "Загрузка модели"]
    for i, (name, result) in enumerate(zip(test_names, results)):
        status = "✅ ПРОЙДЕН" if result else "❌ ПРОВАЛЕН"
        print(f"  {i+1}. {name}: {status}")
    
    if all(results):
        print("\n🎉 ВСЕ ТЕСТЫ ПРОЙДЕНЫ! Intel Arc готов к работе.")
        print("💡 Рекомендации:")
        print("  - Используйте start_optimized.ps1 для запуска")
        print("  - Модель microsoft/phi-2 оптимальна для 2 ГБ VRAM")
        print("  - Ожидаемая скорость: 8-12 токенов/сек")
    else:
        print("\n⚠️  НЕКОТОРЫЕ ТЕСТЫ ПРОВАЛЕНЫ!")
        print("💡 Рекомендации:")
        print("  - Проверьте установку Intel Arc драйверов")
        print("  - Переустановите зависимости: setup_env.ps1")
        print("  - Убедитесь в правильности переменных окружения")

if __name__ == "__main__":
    main() 