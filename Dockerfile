# Use a slim Python base image for a smaller footprint
FROM --platform=$TARGETPLATFORM python:3.10-slim AS main

# Set working directory
WORKDIR /app

# Install only necessary system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    pandoc \
    netcat-openbsd \
    libgl1-mesa-glx \
    libglib2.0-0 \
    && rm -rf /var/lib/apt/lists/*

# Set environment variables for optimized performance
ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    PIP_NO_CACHE_DIR=1 \
    PIP_DISABLE_PIP_VERSION_CHECK=1 \
    SCARF_NO_ANALYTICS=true

# Copy dependencies first to leverage Docker cache
COPY requirements.txt .

# Install Python dependencies efficiently
RUN pip install --no-cache-dir --prefer-binary -r requirements.txt

# Download required NLTK data
RUN python -m nltk.downloader -d /app/nltk_data punkt averaged_perceptron_tagger
ENV NLTK_DATA=/app/nltk_data

# Copy the rest of the application
COPY . .

# Define default command
CMD ["python", "main.py"]