#!/usr/bin/env python3
"""
Simple test script to check basic bot structure without external dependencies
"""

import os
import sys

def test_file_structure():
    """Test if all required files exist"""
    print("=== Testing File Structure ===")
    
    required_files = [
        "bot.py",
        "chains.py", 
        "embeddings.py",
        "requirements.txt",
        "knowledge_base/system_prompt.txt"
    ]
    
    missing_files = []
    for file_path in required_files:
        if os.path.exists(file_path):
            print(f"✅ {file_path}")
        else:
            print(f"❌ {file_path}")
            missing_files.append(file_path)
    
    if missing_files:
        print(f"\n❌ Missing files: {', '.join(missing_files)}")
        return False
    
    print("✅ All required files found")
    return True

def test_python_syntax():
    """Test if Python files have valid syntax"""
    print("\n=== Testing Python Syntax ===")
    
    python_files = ["bot.py", "chains.py", "embeddings.py"]
    
    for file_path in python_files:
        try:
            with open(file_path, 'r', encoding='utf-8') as f:
                content = f.read()
            
            # Try to compile the code
            compile(content, file_path, 'exec')
            print(f"✅ {file_path} - Valid syntax")
            
        except SyntaxError as e:
            print(f"❌ {file_path} - Syntax error: {e}")
            return False
        except Exception as e:
            print(f"❌ {file_path} - Error reading file: {e}")
            return False
    
    return True

def test_import_structure():
    """Test if import statements are valid (without actually importing)"""
    print("\n=== Testing Import Structure ===")
    
    # Check bot.py imports
    try:
        with open("bot.py", 'r', encoding='utf-8') as f:
            content = f.read()
        
        # Check for common import patterns
        required_imports = [
            "from telegram import",
            "from telegram.ext import",
            "from embeddings import",
            "from chains import"
        ]
        
        missing_imports = []
        for imp in required_imports:
            if imp in content:
                print(f"✅ Found: {imp}")
            else:
                print(f"❌ Missing: {imp}")
                missing_imports.append(imp)
        
        if missing_imports:
            print(f"❌ Missing imports in bot.py: {', '.join(missing_imports)}")
            return False
            
    except Exception as e:
        print(f"❌ Error checking bot.py imports: {e}")
        return False
    
    return True

def test_environment_files():
    """Test environment configuration files"""
    print("\n=== Testing Environment Files ===")
    
    env_files = [".env.example", ".env.temp"]
    
    for env_file in env_files:
        if os.path.exists(env_file):
            print(f"✅ {env_file} exists")
            
            # Check if it contains required variables
            try:
                with open(env_file, 'r', encoding='utf-8') as f:
                    content = f.read()
                
                if "TELEGRAM_TOKEN" in content:
                    print(f"  ✅ Contains TELEGRAM_TOKEN")
                else:
                    print(f"  ❌ Missing TELEGRAM_TOKEN")
                
                if "HUGGINGFACEHUB_API_TOKEN" in content:
                    print(f"  ✅ Contains HUGGINGFACEHUB_API_TOKEN")
                else:
                    print(f"  ❌ Missing HUGGINGFACEHUB_API_TOKEN")
                    
            except Exception as e:
                print(f"  ❌ Error reading {env_file}: {e}")
        else:
            print(f"❌ {env_file} not found")
    
    return True

def test_knowledge_base():
    """Test knowledge base files"""
    print("\n=== Testing Knowledge Base ===")
    
    kb_files = [
        "knowledge_base/system_prompt.txt",
        "knowledge_base/product_catalog.md",
        "knowledge_base/delivery_terms.md"
    ]
    
    for file_path in kb_files:
        if os.path.exists(file_path):
            try:
                with open(file_path, 'r', encoding='utf-8') as f:
                    content = f.read()
                
                if len(content.strip()) > 0:
                    print(f"✅ {file_path} - {len(content)} characters")
                else:
                    print(f"⚠️ {file_path} - Empty file")
                    
            except Exception as e:
                print(f"❌ {file_path} - Error reading: {e}")
        else:
            print(f"❌ {file_path} - Not found")
    
    return True

def main():
    """Run all tests"""
    print("🤖 Simple Bot Structure Test")
    print("=" * 50)
    
    tests = [
        ("File Structure", test_file_structure),
        ("Python Syntax", test_python_syntax),
        ("Import Structure", test_import_structure),
        ("Environment Files", test_environment_files),
        ("Knowledge Base", test_knowledge_base)
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
        print("\n🎉 Basic structure tests passed!")
        print("Next steps:")
        print("1. Create a .env file with your API tokens")
        print("2. Install required dependencies")
        print("3. Run the bot")
    else:
        print("\n⚠️ Some structure tests failed. Please fix the issues.")
    
    return all_passed

if __name__ == "__main__":
    success = main()
    sys.exit(0 if success else 1)