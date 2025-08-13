#!/usr/bin/env python3
"""
Test script to check bot initialization and identify issues
"""

import os
import sys
import logging
import traceback
from dotenv import load_dotenv

# Setup basic logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)

def test_environment():
    """Test environment variables and basic setup"""
    print("=== Testing Environment ===")
    
    # Load environment variables
    if not load_dotenv():
        print("❌ No .env file found")
        return False
    
    # Check required variables
    required_vars = ["TELEGRAM_TOKEN", "HUGGINGFACEHUB_API_TOKEN"]
    missing_vars = []
    
    for var in required_vars:
        value = os.getenv(var)
        if not value or value == "your_telegram_bot_token_here" or value == "your_huggingface_api_token_here":
            missing_vars.append(var)
            print(f"❌ {var}: Not set or using placeholder value")
        else:
            print(f"✅ {var}: Set")
    
    if missing_vars:
        print(f"\n❌ Missing required environment variables: {', '.join(missing_vars)}")
        return False
    
    print("✅ Environment setup looks good")
    return True

def test_imports():
    """Test if all required modules can be imported"""
    print("\n=== Testing Imports ===")
    
    try:
        import torch
        print(f"✅ PyTorch: {torch.__version__}")
        
        # Check XPU availability
        if hasattr(torch, 'xpu') and torch.xpu.is_available():
            print(f"✅ XPU available: {torch.xpu.get_device_name(0)}")
        else:
            print("⚠️ XPU not available, will use CPU")
            
    except ImportError as e:
        print(f"❌ PyTorch import failed: {e}")
        return False
    
    try:
        from transformers import AutoTokenizer, AutoModelForCausalLM
        print("✅ Transformers imported successfully")
    except ImportError as e:
        print(f"❌ Transformers import failed: {e}")
        return False
    
    try:
        from langchain_community.embeddings import HuggingFaceEmbeddings
        from langchain_community.vectorstores import Chroma
        print("✅ LangChain imports successful")
    except ImportError as e:
        print(f"❌ LangChain import failed: {e}")
        return False
    
    try:
        from telegram import Update
        from telegram.ext import Application
        print("✅ Telegram imports successful")
    except ImportError as e:
        print(f"❌ Telegram import failed: {e}")
        return False
    
    return True

def test_embeddings():
    """Test embeddings initialization"""
    print("\n=== Testing Embeddings ===")
    
    try:
        from embeddings import init_vector_store, VectorStoreInitializationError
        
        print("Initializing vector store...")
        retriever = init_vector_store()
        
        if retriever:
            print("✅ Vector store initialized successfully")
            return True
        else:
            print("❌ Vector store initialization returned None")
            return False
            
    except VectorStoreInitializationError as e:
        print(f"❌ Vector store initialization error: {e}")
        return False
    except Exception as e:
        print(f"❌ Unexpected error in embeddings: {e}")
        print(traceback.format_exc())
        return False

def test_qa_chain():
    """Test QA chain initialization"""
    print("\n=== Testing QA Chain ===")
    
    try:
        from chains import init_qa_chain
        from embeddings import init_vector_store
        
        print("Initializing retriever for QA chain...")
        retriever = init_vector_store()
        
        if not retriever:
            print("❌ Cannot test QA chain without retriever")
            return False
        
        print("Initializing QA chain...")
        qa_chain, system_prompt = init_qa_chain(retriever)
        
        if qa_chain:
            print("✅ QA chain initialized successfully")
            print(f"System prompt length: {len(system_prompt)} characters")
            return True
        else:
            print("❌ QA chain initialization returned None")
            return False
            
    except Exception as e:
        print(f"❌ Error in QA chain initialization: {e}")
        print(traceback.format_exc())
        return False

def main():
    """Run all tests"""
    print("🤖 Bot Initialization Test")
    print("=" * 50)
    
    tests = [
        ("Environment", test_environment),
        ("Imports", test_imports),
        ("Embeddings", test_embeddings),
        ("QA Chain", test_qa_chain)
    ]
    
    results = []
    
    for test_name, test_func in tests:
        try:
            result = test_func()
            results.append((test_name, result))
        except Exception as e:
            print(f"❌ {test_name} test crashed: {e}")
            results.append((test_name, False))
    
    print("\n" + "=" * 50)
    print("📊 Test Results Summary:")
    
    all_passed = True
    for test_name, result in results:
        status = "✅ PASS" if result else "❌ FAIL"
        print(f"{test_name}: {status}")
        if not result:
            all_passed = False
    
    if all_passed:
        print("\n🎉 All tests passed! Bot should be ready to run.")
    else:
        print("\n⚠️ Some tests failed. Please fix the issues before running the bot.")
    
    return all_passed

if __name__ == "__main__":
    success = main()
    sys.exit(0 if success else 1)