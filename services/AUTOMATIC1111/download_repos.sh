#!/bin/bash
# Create the target directory
mkdir -p repositories
cd repositories

# Define the repositories to clone
# We clone them exactly as A1111 expects them
echo "Cloning Assets..."
git clone --depth 1 https://github.com/AUTOMATIC1111/stable-diffusion-webui-assets.git stable-diffusion-webui-assets
rm -rf stable-diffusion-webui-assets/.git

echo "Cloning Stability AI Backend..."
git clone --depth 1 https://github.com/Stability-AI/stablediffusion.git stable-diffusion-stability-ai
rm -rf stable-diffusion-stability-ai/assets stable-diffusion-stability-ai/data stable-diffusion-stability-ai/.git

echo "Cloning BLIP..."
git clone --depth 1 https://github.com/salesforce/BLIP.git BLIP
rm -rf BLIP/.git

echo "Cloning K-Diffusion..."
git clone --depth 1 https://github.com/crowsonkb/k-diffusion.git k-diffusion
rm -rf k-diffusion/.git

echo "Cloning Clip Interrogator..."
git clone --depth 1 https://github.com/pharmapsychotic/clip-interrogator clip-interrogator
rm -rf clip-interrogator/.git

echo "Cloning Generative Models..."
git clone --depth 1 https://github.com/Stability-AI/generative-models generative-models
rm -rf generative-models/.git

echo "Done! Repositories are ready for Docker."