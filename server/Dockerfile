# Dockerfile

# Pull base image
FROM python:3.9

# Set environment variables
ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1

# Set work directory
RUN mkdir /web/
WORKDIR /web/

# Copy requirements.txt to container
ADD requirements.txt /web/

# Install dependencies
RUN pip install -r /web/requirements.txt

# Copy project to container
ADD . /web/
