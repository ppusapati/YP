FROM python:3.12-slim

WORKDIR /app

RUN apt-get update && apt-get install -y --no-install-recommends \
    libgl1-mesa-glx libglib2.0-0 && \
    rm -rf /var/lib/apt/lists/*

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY configs/ configs/
COPY scripts/ scripts/

WORKDIR /app/scripts

ENTRYPOINT ["python", "run_pipeline.py"]
CMD ["--tasks", "all", "--config", "../configs/training_config.yaml"]
