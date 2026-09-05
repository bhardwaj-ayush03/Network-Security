FROM python:3.14-slim-bookworm

WORKDIR /app

COPY . /app

RUN apt-get update && apt-get install -y awscli && rm -rf /var/lib/apt/lists/*

RUN pip install --upgrade pip
RUN pip install -r requirements.txt

CMD ["python", "app.py"]