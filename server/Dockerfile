# Dockerfile

# Pull base image
FROM python:3.9

# Set work directory
WORKDIR /web

# Install dependencies
RUN pip install pipenv
COPY Pipfile Pipfile.lock /web/
RUN pipenv install --system

# Copy project
COPY . /web/