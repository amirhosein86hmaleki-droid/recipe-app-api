# syntax=docker/dockerfile:1
FROM python:3.12-slim
LABEL maintainer="londonappdeveloper.ir"

ENV PYTHONUNBUFFERED=1
ENV PATH="/py/bin:$PATH"

WORKDIR /app

# فقط فایل‌های requirements را قبل از COPY کل پروژه کپی کنید
COPY ./requirements.txt /tmp/requirements.txt
COPY ./requirements.dev.txt /tmp/requirements.dev.txt

ARG DEV=false

# نصب gcc، libpq-dev و بسته‌های Python با timeout بیشتر و mirror سریع
RUN python -m venv /py && \
    /py/bin/pip install --upgrade pip && \
    apt-get update && apt-get install -y \
        gcc \
        libpq-dev \
        curl \
    && rm -rf /var/lib/apt/lists/* && \
    /py/bin/pip install --default-timeout=100 -r /tmp/requirements.txt -i https://pypi.tuna.tsinghua.edu.cn/simple && \
    if [ "$DEV" = "true" ]; then \
        /py/bin/pip install --default-timeout=100 -r /tmp/requirements.dev.txt -i https://pypi.tuna.tsinghua.edu.cn/simple ; \
    fi && \
    rm -rf /tmp && \
    adduser --disabled-password --no-create-home django-user

# حالا پروژه را کپی کنید
COPY ./app /app

USER django-user
EXPOSE 8000
