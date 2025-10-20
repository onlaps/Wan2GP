#!/usr/bin/env bash
set -euo pipefail

echo "🚀 Starting Wan2GP bootstrap process..."

# 0️⃣ Initialize conda in this script session
source "$(conda info --base)/etc/profile.d/conda.sh"

# 1️⃣ Create environment (auto-confirm)
echo "📦 Creating conda environment 'wan2gp' with Python 3.10.9..."
conda create -y -n wan2gp python=3.10.9

# 2️⃣ Activate it properly
echo "🔑 Activating conda environment..."
conda activate wan2gp
python --version  # sanity check: should print 3.10.9 from wan2gp

# 3️⃣ Install PyTorch (auto-confirm)
echo "🧠 Installing PyTorch with CUDA 12.8 support..."
pip install -q --prefer-binary torch==2.7.0 torchvision torchaudio \
  --index-url https://download.pytorch.org/whl/test/cu128

# 4️⃣ Install requirements
echo "📚 Installing project requirements..."
pip install -q --prefer-binary -r requirements.txt

# 5️⃣ Install FlashAttention (optional)
echo "⚡ Installing FlashAttention..."
pip install -q --prefer-binary flash-attn==2.7.2.post1

echo "✅ Bootstrap process completed successfully!"
echo "👉 To activate later: conda activate wan2gp"