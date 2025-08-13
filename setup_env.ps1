# Setup script for LFP-TGbot-LLM-RAG project
# 1. Removes old environment if exists
# 2. Creates new conda environment with Python 3.11.13
# 3. Installs all required dependencies

# Configuration
$envName = "lfp_bot_py311"
$pythonVersion = "3.11.13"

# Remove existing environment if exists
Write-Host "Removing existing environment if exists..." -ForegroundColor Yellow
conda env remove -n $envName -y

# Create new environment
Write-Host "Creating new environment '$envName' with Python $pythonVersion..." -ForegroundColor Cyan
conda create -n $envName python=$pythonVersion -y

# Activate and install requirements
Write-Host "Installing requirements..." -ForegroundColor Cyan
conda run -n $envName pip install -r requirements.txt

# Установка Intel XPU зависимостей
Write-Host "Installing Intel XPU dependencies..." -ForegroundColor Cyan
conda run -n $envName pip install --pre torch==2.7.1+xpu torchvision==0.22.1+xpu torchaudio==2.7.1+xpu --index-url https://download.pytorch.org/whl/nightly/xpu
conda run -n $envName pip install --pre --upgrade ipex-llm[xpu] --extra-index-url https://pytorch-extension.intel.com/release-whl/stable/xpu/us/
conda run -n $envName pip install transformers==4.42.0 accelerate==0.29.3 bitsandbytes==0.43.0 sentence-transformers==2.2.2 chromadb==0.3.23

conda run -n $envName pip install python-dotenv python-telegram-bot[ext]

# Create .env file if not exists
$envFile = ".\.env"
if (-not (Test-Path $envFile)) {
    @"
# Telegram Bot
TELEGRAM_TOKEN=your_telegram_token

# Hugging Face
HUGGINGFACEHUB_API_TOKEN=your_hf_token
MODEL_NAME=Qwen/Qwen2-1.5B-Instruct
EMBEDDING_MODEL=sentence-transformers/all-mpnet-base-v2

# Device (cpu, cuda, xpu, mps)
DEVICE=cpu

# Database
CHROMA_DB_PATH=./chroma_db
"@ | Out-File -FilePath $envFile -Encoding utf8
    Write-Host "Created .env file. Please update it with your tokens." -ForegroundColor Yellow
}

Write-Host "`nSetup complete! To activate the environment, run:" -ForegroundColor Green
Write-Host "conda activate $envName" -ForegroundColor Cyan
