# Reference: https://github.com/ykursadkaya/pyspark-Docker
# Adjusted for my needs

ARG IMAGE_VARIANT=slim-buster
ARG OPENJDK_VERSION=8
ARG PYTHON_VERSION=3.8

FROM python:${PYTHON_VERSION}-${IMAGE_VARIANT} AS py3
FROM openjdk:${OPENJDK_VERSION}-${IMAGE_VARIANT}

COPY --from=py3 / /
COPY ./data words_index
COPY ./app/app.py app_inverted_index/app.py

ARG PYSPARK_VERSION=3.1.2
RUN pip --no-cache-dir install pyspark==${PYSPARK_VERSION}

CMD [ "python", "./app_inverted_index/app.py" ]