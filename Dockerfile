FROM python:alpine

WORKDIR /app

COPY tox.ini .
COPY app.py .
