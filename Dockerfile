FROM python:3.8-slim

WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y \
    gcc \
    g++ \
    build-essential \
    pkg-config \
    libhdf5-dev \
    libssl-dev \
    git \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

COPY . /app/

# Install Python packages
RUN pip install --no-cache-dir --upgrade pip
RUN pip install --no-cache-dir wheel setuptools
RUN pip install --no-cache-dir rasa tensorflow

CMD ["bash"] 