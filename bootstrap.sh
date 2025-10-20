#!/bin/bash

# Wan2GP Bootstrap Script
# This script clones the repository and sets up the conda environment

set -e  # Exit on any error

echo "Starting Wan2GP bootstrap process..."

# Clone the repository
echo "Cloning Wan2GP repository..."
git clone https://github.com/onlaps/Wan2GP
cd Wan2GP

# Create conda environment
echo "Creating conda environment 'wan2gp' with Python 3.10.9..."
conda create -n wan2gp python=3.10.9

# Activate conda environment
echo "Activating conda environment..."
conda activate wan2gp

# Install PyTorch with CUDA support
echo "Installing PyTorch with CUDA 12.8 support..."
pip install torch==2.7.0 torchvision torchaudio --index-url https://download.pytorch.org/whl/test/cu128

# Install project requirements
echo "Installing project requirements..."
pip install -r requirements.txt

echo "Bootstrap process completed successfully!"
echo "To activate the environment in the future, run: conda activate wan2gp"