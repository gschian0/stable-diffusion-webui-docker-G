# Use a newer base image with Ubuntu 24.04 and CUDA toolkit support
FROM nvidia/cuda:12.6.0-devel-ubuntu24.04

# Prevent interactive prompts AND allow pip to install globally (PEP 668 override)
ENV DEBIAN_FRONTEND=noninteractive \
    PIP_PREFER_BINARY=1 \
    PIP_BREAK_SYSTEM_PACKAGES=1 \
    ROOT=/stable-diffusion-webui

# Install Python 3.12, Git, and generic tools
RUN apt-get update && apt-get install -y \
    fonts-dejavu-core rsync git jq moreutils aria2 \
    ffmpeg libglfw3-dev libgles2-mesa-dev pkg-config libcairo2 libcairo2-dev build-essential \
    python3 python3-pip python3-venv \
    libgl1 libglx-mesa0 \
    libgoogle-perftools-dev \
    libjpeg-dev zlib1g-dev rustc cargo \
    ca-certificates \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# --- RTX 5090 / Blackwell ---
# Install PyTorch Nightly with CUDA 12.8 support.
# --timeout 600 prevents ReadTimeoutError on the large (~830 MB) torch wheel.
# Install torchvision separately with --no-deps to avoid nightly date skew breaks.
RUN --mount=type=cache,target=/root/.cache/pip \
  pip3 install --no-cache-dir --pre torch --timeout 600 --index-url https://download.pytorch.org/whl/nightly/cu128
RUN --mount=type=cache,target=/root/.cache/pip \
  pip3 install --no-cache-dir --pre torchvision --no-deps --timeout 600 --index-url https://download.pytorch.org/whl/nightly/cu128

WORKDIR /

# Clone and install AUTOMATIC1111
RUN --mount=type=cache,target=/root/.cache/pip \
  git clone https://github.com/AUTOMATIC1111/stable-diffusion-webui.git && \
  cd stable-diffusion-webui && \
  git checkout v1.10.1 && \
  # Strategy: Pre-install binary wheels to skip compilation.
  pip3 install --no-cache-dir "transformers>=4.38.0" "tokenizers>=0.19.1" && \
  # Fix: Remove version pins that conflict with Python 3.12
  sed -i '/transformers/d' requirements_versions.txt && \
  sed -i '/tokenizers/d' requirements_versions.txt && \
  sed -i 's/scikit-image==0.21.0/scikit-image>=0.22.0/g' requirements_versions.txt && \
  sed -i 's/Pillow==9.5.0/Pillow>=9.5.0/g' requirements_versions.txt && \
  sed -i 's/inflection==0.5.1/inflection>=0.5.1/g' requirements_versions.txt && \
  # Fix: Prevent driver downgrade
  sed -i '/torch/d' requirements_versions.txt && \
  sed -i '/torchvision/d' requirements_versions.txt && \
  sed -i '/xformers/d' requirements_versions.txt && \
  pip3 install --no-cache-dir -r requirements_versions.txt --extra-index-url https://download.pytorch.org/whl/nightly/cu128

# 4. COPY REPOS (The Network Fix)
# Instead of "RUN git clone", we simply COPY the folder you just downloaded.
COPY repositories/ ${ROOT}/repositories/

# 5. Final Setup
WORKDIR ${ROOT}
RUN mkdir ${ROOT}/interrogate && cp ${ROOT}/repositories/clip-interrogator/clip_interrogator/data/* ${ROOT}/interrogate

RUN --mount=type=cache,target=/root/.cache/pip \
  pip3 install --no-cache-dir pyngrok \
  pytorch-lightning \
  git+https://github.com/TencentARC/GFPGAN.git@master \
  git+https://github.com/openai/CLIP.git@main \
  git+https://github.com/mlfoundations/open_clip.git@v2.20.0

ENV LD_PRELOAD=libtcmalloc.so
COPY . /docker
RUN chmod u+x /docker/entrypoint.sh

RUN sed -i 's/in_app_dir = .*/in_app_dir = True/g' /usr/local/lib/python3.12/dist-packages/gradio/routes.py || true && \
    git config --global --add safe.directory '*'

ENV NVIDIA_VISIBLE_DEVICES=all
ENV CLI_ARGS=""
EXPOSE 7860
ENTRYPOINT ["/docker/entrypoint.sh"]

CMD python3 -u webui.py --listen --port 7860 --opt-sdp-attention --skip-python-version-check --skip-torch-cuda-test ${CLI_ARGS}