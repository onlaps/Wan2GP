#!/usr/bin/env bash
set -euo pipefail

echo "🚀 Starting Wan2GP bootstrap (PyTorch + Sage v2)..."

# 0) Initialize conda for non-interactive shells
source "$(conda info --base)/etc/profile.d/conda.sh"

# 1) Create env
echo "📦 Creating conda env 'wan2gp' (Python 3.10.9)..."
conda create -y -n wan2gp python=3.10.9

# 2) Activate env
echo "🔑 Activating conda env..."
conda activate wan2gp
python --version

# 3) PyTorch first (CUDA 12.8 test channel as per your guide)
echo "🧠 Installing PyTorch 2.7.0 (cu124)..."
pip install -q --prefer-binary torch==2.7.0 torchvision torchaudio \
  --index-url https://download.pytorch.org/whl/test/cu124

# 4) Project requirements
echo "📚 Installing project requirements..."
pip install -q --prefer-binary -r requirements.txt

# 5) Sage v2 (preferred attention backend)
echo "⚡ Installing SageAttention v2..."

# Detect Windows vs Linux
IS_WINDOWS="0"
if [[ "${OS:-}" == "Windows_NT" ]] || uname -s | grep -qi "mingw\|msys\|cygwin"; then
  IS_WINDOWS="1"
fi

if [[ "$IS_WINDOWS" == "1" ]]; then
  echo "🪟 Windows detected: installing triton-windows first..."
  pip install -q --prefer-binary triton-windows || true
fi

# Try prebuilt wheel first (fast path)
if pip install -q --prefer-binary "sageattention==2.*"; then
  echo "✅ Sage v2 wheel installed."
else
  echo "🛠️  No Sage v2 wheel found for this Python/Torch/CUDA combo."

  if [[ "$IS_WINDOWS" == "1" ]]; then
    echo "❌ Building Sage v2 from source on Windows is not recommended here."
    echo "👉 Continue with SDPA or try a different Torch/CUDA combo that has a Sage v2 wheel."
  else
    echo "🐧 Linux detected: attempting source build for Sage v2..."
    python -m pip install -q "setuptools<=75.8.2" --force-reinstall
    # Clone in parent/home (location doesn't matter; editable install links it)
    SA_DIR="${HOME}/SageAttention"
    if [[ -d "$SA_DIR" ]]; then
      echo "📁 Reusing existing $SA_DIR"
    else
      git clone --depth 1 https://github.com/thu-ml/SageAttention "$SA_DIR"
    fi
    pushd "$SA_DIR" >/dev/null
    # Editable install
    pip install -q -e .
    popd >/dev/null
    echo "✅ Sage v2 built and installed from source."
  fi
fi

# 6) Sanity checks
python - <<'PY'
import torch, importlib
print("CUDA available:", torch.cuda.is_available(), "| Torch:", torch.__version__, "| CUDA rt:", torch.version.cuda)
try:
    importlib.import_module("sageattention")
    print("SageAttention import: OK ✅")
except Exception as e:
    print("SageAttention import failed:", e)
PY

echo "✅ Bootstrap complete!"
echo "👉 To activate later: conda activate wan2gp"
echo "👉 To run with Sage v2 (if installed):  python wgp.py --attention sage2"
echo "👉 If Sage v2 is not available, use SDPA: python wgp.py --attention sdpa"