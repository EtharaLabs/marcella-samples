# syntax=docker/dockerfile:1.12@sha256:93bfd3b68c109427185cd78b4779fc82b484b0b7618e36d0f104d4d801e66d25

FROM python:3.12-slim-bookworm@sha256:e697c81897302a4c4333bade000d98038fbb21eb064f8ee1fd42d02ebcd9d337 AS deps
SHELL ["/bin/bash", "-o", "pipefail", "-c"]
COPY requirements.txt /tmp/requirements.txt
RUN python -m venv --without-pip /opt/venv \
    && python -m pip --python /opt/venv/bin/python install --no-cache-dir --no-compile --no-deps \
        --require-hashes -r /tmp/requirements.txt

FROM python:3.12-slim-bookworm@sha256:e697c81897302a4c4333bade000d98038fbb21eb064f8ee1fd42d02ebcd9d337 AS verifier
LABEL org.opencontainers.image.title="ethara/42f44b68-8927-4f99-af0b-8c795988488b verifier" \
      org.opencontainers.image.licenses="MIT" \
      org.opencontainers.image.base.name="docker.io/library/python:3.12-slim-bookworm" \
      org.opencontainers.image.base.digest="sha256:e697c81897302a4c4333bade000d98038fbb21eb064f8ee1fd42d02ebcd9d337"
SHELL ["/bin/bash", "-o", "pipefail", "-c"]
ENV PATH=/opt/venv/bin:$PATH \
    PYTHONDONTWRITEBYTECODE=1 \
    LITELLM_LOCAL_MODEL_COST_MAP=True
COPY --from=deps /opt/venv /opt/venv
# useradd stamps /etc/shadow with the build day and chage keeps that line in /etc/shadow-;
# pin both to day 20754 (2026-10-28, the SOURCE_DATE_EPOCH day) so the layer does not
# depend on when it is built.
RUN mkdir -p /tests /app/output /logs/verifier /var/lib/hpr-integrity \
    && groupadd --gid 1000 verifier \
    && useradd --uid 1000 --gid 1000 --create-home --shell /bin/bash verifier \
    && chage --lastday 20754 verifier \
    && cp -p /etc/shadow /etc/shadow- \
    && chown 1000:1000 /app/output /logs/verifier
# The whole tests/ tree, as the harness tasks ship it, so a grader wrapper placed beside
# test.sh reaches the image; modes are fixed here, not taken from the build host.
COPY --chown=0:0 --chmod=0755 . /tests/
WORKDIR /tests
# The image stays root so the harness can set up the container; task.toml [verifier] user = "1000:1000" runs the verifier.
# hadolint ignore=DL3002
USER 0
CMD ["/bin/bash"]
