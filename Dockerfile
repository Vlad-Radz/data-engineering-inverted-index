# Reference: https://github.com/ykursadkaya/pyspark-Docker
# Adjusted for my needs

ARG IMAGE_VARIANT=slim-buster
ARG OPENJDK_VERSION=8
ARG PYTHON_VERSION=3.8

FROM python:${PYTHON_VERSION}-${IMAGE_VARIANT} AS py3
FROM openjdk:${OPENJDK_VERSION}-${IMAGE_VARIANT}

COPY --from=py3 / /

# There should be a command for copying the whole directory
COPY ./data words_index
COPY ./app/app.py app/app.py
COPY ./app/storage.py app/storage.py
COPY ./app/strategies.py app/strategies.py
COPY ./app/utils.py app/utils.py
COPY ./app/__init__.py app/__init__.py

ARG PYSPARK_VERSION=3.1.2
RUN pip --no-cache-dir install pyspark==${PYSPARK_VERSION}  # run pip in a virtual environment

WORKDIR "/app/"
CMD [ "python", "app.py" ]