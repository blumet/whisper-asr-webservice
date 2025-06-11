FROM onerahmet/ffmpeg:n7.1 AS ffmpeg

FROM swaggerapi/swagger-ui:v5.9.1 AS swagger-ui

FROM python:3.10-bookworm

ENV POETRY_VENV=/app/.venv

RUN python3 -m venv $POETRY_VENV \
    && $POETRY_VENV/bin/pip install -U pip setuptools \
    && $POETRY_VENV/bin/pip install poetry==2.1.1

ENV PATH="${PATH}:${POETRY_VENV}/bin"

WORKDIR /app

COPY . /app
COPY --from=ffmpeg /usr/local/bin/ffmpeg /usr/local/bin/ffmpeg
COPY --from=swagger-ui /usr/share/nginx/html/swagger-ui.css swagger-ui-assets/swagger-ui.css
COPY --from=swagger-ui /usr/share/nginx/html/swagger-ui-bundle.js swagger-ui-assets/swagger-ui-bundle.js

RUN poetry config virtualenvs.in-project true
RUN poetry install

EXPOSE 10000

CMD ["poetry", "run", "whisper-asr-webservice", "--host", "0.0.0.0", "--port", "10000"]
