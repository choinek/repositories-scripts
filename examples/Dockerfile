FROM python:3.9-slim

RUN apt-get update && apt-get install -y \
    build-essential \
    wget \
    pngquant \
    webp \
    gifsicle \
    libjpeg-turbo-progs \
    && apt-get clean

RUN pip install --no-cache-dir pillow

WORKDIR /app

COPY optimize_images.py /app/optimize_images.py

CMD ["python", "/app/optimize_images.py"]
