FROM python:alpine

WORKDIR /app

ENV FLASK_APP app.py

COPY requirements.txt .
RUN apk add --no-cache --virtual .build-deps gcc musl-dev && \
    pip install --no-cache-dir --upgrade pip setuptools && \
    pip install --no-cache-dir --upgrade -r requirements.txt && \
    apk del .build-deps gcc musl-dev

COPY tox.ini .
COPY runserver.sh .
COPY app.py .

EXPOSE 8000

CMD ["ash", "runserver.sh"]
