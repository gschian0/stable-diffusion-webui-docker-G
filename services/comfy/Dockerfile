# Use a newer base image with Ubuntu 24.04 and CUDA toolkit support
FROM nvidia/cuda:12.6.0-devel-ubuntu24.04

# Prevent interactive prompts AND allow pip to install globally (PEP 668 override)
ENV DEBIAN_FRONTEND=noninteractive \
    PIP_PREFER_BINARY=1 \
    PIP_BREAK_SYSTEM_PACKAGES=1 \
    ROOT=/stable-diffusion

# Install Python 3.12, Git, and generic tools
# (Includes the libgl fix for Ubuntu 24.04)
RUN apt-get update && apt-get install -y \
    python3 \
    python3-pip \
    python3-venv \
    git \
    libgl1 \
    libglx-mesa0 \
    libglib2.0-0 \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Clone ComfyUI (Using the cache mount to speed up rebuilds)
RUN --mount=type=cache,target=/root/.cache/pip \
    git clone https://github.com/comfyanonymous/ComfyUI.git ${ROOT} && \
    cd ${ROOT} && \
    git checkout master

# --- THE FIX FOR RTX 5090 ---
# Force install PyTorch Nightly with CUDA 12.8 support
# (Required for sm_120 / Blackwell architecture)
RUN pip3 install --no-cache-dir --pre torch torchvision torchaudio --index-url https://download.pytorch.org/whl/nightly/cu128

# Install the rest of ComfyUI requirements
# We use --ignore-installed to stop it from downgrading our nightly PyTorch
WORKDIR ${ROOT}
RUN pip3 install --no-cache-dir -r requirements.txt --extra-index-url https://download.pytorch.org/whl/nightly/cu128

# Copy the entrypoint script from the local folder into the image
COPY . /docker/
RUN chmod u+x /docker/entrypoint.sh && cp /docker/extra_model_paths.yaml ${ROOT}

ENV NVIDIA_VISIBLE_DEVICES=all \
    PYTHONPATH="${PYTHONPATH}:${PWD}" \
    CLI_ARGS=""

EXPOSE 7860
ENTRYPOINT ["/docker/entrypoint.sh"]
CMD ["python3", "-u", "main.py", "--listen", "--port", "7860"]


# FROM pytorch/pytorch:2.3.0-cuda12.1-cudnn8-runtime

# ENV DEBIAN_FRONTEND=noninteractive PIP_PREFER_BINARY=1

# RUN apt-get update && apt-get install -y git && apt-get clean

# ENV ROOT=/stable-diffusion
# RUN --mount=type=cache,target=/root/.cache/pip \
#   git clone https://github.com/comfyanonymous/ComfyUI.git ${ROOT} && \
#   cd ${ROOT} && \
#   git checkout master && \
#   git reset --hard 276f8fce9f5a80b500947fb5745a4dde9e84622d && \
#   pip install -r requirements.txt

# WORKDIR ${ROOT}
# COPY . /docker/
# RUN chmod u+x /docker/entrypoint.sh && cp /docker/extra_model_paths.yaml ${ROOT}

# ENV NVIDIA_VISIBLE_DEVICES=all PYTHONPATH="${PYTHONPATH}:${PWD}" CLI_ARGS=""
# EXPOSE 7860
# ENTRYPOINT ["/docker/entrypoint.sh"]
# CMD python -u main.py --listen --port 7860 ${CLI_ARGS}
