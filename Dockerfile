FROM python:3.11-slim
WORKDIR /usr/src/app
COPY requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt
COPY . .
ENV PYTHONUNBUFFERED=1
CMD ["sh", "-c", "python manage.py migrate && python manage.py runserver 0.0.0.0:8000"]