FROM python:3.12-slim

WORKDIR /app

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

COPY web/requirements.txt ./requirements.txt
RUN pip install --no-cache-dir -r requirements.txt

COPY web/ .

ENV APP_NAME="Photo Gallery API (Stateless)" \
    APP_VERSION="v1"

EXPOSE 8080

CMD ["python", "app.py"]