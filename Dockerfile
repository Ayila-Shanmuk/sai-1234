# ==========================================
# Run Backend
# ==========================================
FROM python:3.11-slim
WORKDIR /app

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

# Install curl for health check
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Install Python dependencies
COPY requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt

# Copy application files
COPY app.py auth.py train_models.py ./

# data/, models/, templates/, static/ and frontend/ are not in the repo; create
# the runtime dirs and train the models at build time so the API starts.
RUN mkdir -p data models templates static && python train_models.py

# Expose port (Railway injects $PORT at runtime)
EXPOSE 8080

# Run with Gunicorn on the port dynamically assigned by Railway
CMD exec gunicorn app:app --bind 0.0.0.0:${PORT:-8080} --workers 2 --threads 4 --timeout 120
