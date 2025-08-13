#!/bin/bash

# Setup script for AntZerBot
# This script helps configure and run the bot

set -e  # Exit on any error

echo "🤖 AntZerBot Setup Script"
echo "=========================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️ $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

# Check if .env file exists
if [ ! -f ".env" ]; then
    print_warning "No .env file found. Creating from template..."
    if [ -f ".env.example" ]; then
        cp .env.example .env
        print_status "Created .env file from template"
        print_warning "Please edit .env file and add your API tokens:"
        echo "  1. TELEGRAM_TOKEN - Get from @BotFather"
        echo "  2. HUGGINGFACEHUB_API_TOKEN - Get from HuggingFace"
        echo ""
        echo "Then run this script again."
        exit 1
    else
        print_error ".env.example not found!"
        exit 1
    fi
fi

# Check if API tokens are set
source .env 2>/dev/null || true

if [ "$TELEGRAM_TOKEN" = "your_telegram_bot_token_here" ] || [ -z "$TELEGRAM_TOKEN" ]; then
    print_error "TELEGRAM_TOKEN not set in .env file"
    echo "Please get a token from @BotFather and add it to .env"
    exit 1
fi

if [ "$HUGGINGFACEHUB_API_TOKEN" = "your_huggingface_api_token_here" ] || [ -z "$HUGGINGFACEHUB_API_TOKEN" ]; then
    print_error "HUGGINGFACEHUB_API_TOKEN not set in .env file"
    echo "Please get a token from HuggingFace and add it to .env"
    exit 1
fi

print_status "API tokens are configured"

# Check Python version
PYTHON_VERSION=$(python3 --version 2>&1 | cut -d' ' -f2)
print_status "Python version: $PYTHON_VERSION"

# Check if virtual environment exists
if [ ! -d "venv" ]; then
    print_warning "Virtual environment not found. Creating..."
    
    # Check if python3-venv is available
    if ! python3 -c "import venv" 2>/dev/null; then
        print_error "python3-venv not available. Please install it:"
        echo "  sudo apt install python3-venv"
        exit 1
    fi
    
    python3 -m venv venv
    print_status "Virtual environment created"
fi

# Activate virtual environment
print_status "Activating virtual environment..."
source venv/bin/activate

# Upgrade pip
print_status "Upgrading pip..."
pip install --upgrade pip

# Install requirements
print_status "Installing requirements..."
if [ -f "requirements.txt" ]; then
    pip install -r requirements.txt
    print_status "Requirements installed"
else
    print_error "requirements.txt not found!"
    exit 1
fi

# Run basic tests
print_status "Running basic tests..."
if python3 simple_test.py; then
    print_status "Basic tests passed"
else
    print_warning "Some tests failed, but continuing..."
fi

# Check if bot can be imported
print_status "Testing bot imports..."
if python3 -c "import bot; print('Bot module imported successfully')" 2>/dev/null; then
    print_status "Bot module can be imported"
else
    print_error "Failed to import bot module"
    exit 1
fi

echo ""
echo "🎉 Setup completed successfully!"
echo ""
echo "To run the bot:"
echo "  1. Activate virtual environment: source venv/bin/activate"
echo "  2. Run the bot: python3 bot.py"
echo ""
echo "To run in background:"
echo "  nohup python3 bot.py > bot.log 2>&1 &"
echo ""
echo "To check logs:"
echo "  tail -f bot.log"
echo ""
echo "To stop the bot:"
echo "  pkill -f 'python3 bot.py'"
echo ""

# Ask if user wants to run the bot now
read -p "Do you want to run the bot now? (y/n): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    print_status "Starting bot..."
    python3 bot.py
else
    print_status "Setup complete. Run 'python3 bot.py' when ready."
fi