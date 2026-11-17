# syntax=docker/dockerfile:1.12@sha256:93bfd3b68c109427185cd78b4779fc82b484b0b7618e36d0f104d4d801e66d25

FROM python:3.12-slim-bookworm@sha256:e697c81897302a4c4333bade000d98038fbb21eb064f8ee1fd42d02ebcd9d337 AS deps
SHELL ["/bin/bash", "-o", "pipefail", "-c"]
COPY requirements.txt /tmp/requirements.txt
RUN python -m venv --without-pip /opt/venv \
    && python -m pip --python /opt/venv/bin/python install --no-cache-dir --no-compile --no-deps \
        --require-hashes -r /tmp/requirements.txt

# Claude Code 2.1.312 and Codex 0.165.0, the official native builds on the npm registry, pre-baked because the agent
# network is closed: each tarball is checked against a pinned sha256 before extraction, and
# Codex keeps its package layout because its binary finds the bundled rg and bwrap beside it.
FROM --platform=$BUILDPLATFORM python:3.12-slim-bookworm@sha256:e697c81897302a4c4333bade000d98038fbb21eb064f8ee1fd42d02ebcd9d337 AS agents
ARG TARGETARCH
SHELL ["/bin/bash", "-o", "pipefail", "-c"]
# The script runs inline, one quoted line per argument, not as a heredoc: Kaniko drops heredoc bodies.
RUN printf '%s\n' \
    'import hashlib' \
    'import os' \
    'import tarfile' \
    'import tempfile' \
    'import urllib.request' \
    'from pathlib import Path' \
    '' \
    'NPM = "https://registry.npmjs.org"' \
    'PINS = {' \
    '    "amd64": {' \
    '        "claude": (f"{NPM}/@anthropic-ai/claude-code-linux-x64/-/claude-code-linux-x64-2.1.312.tgz",' \
    '                   "f1c3d923ff3ac7e7080b8b9c638833dde72feab15e46940a65a0122d728c6bfd"),' \
    '        "codex": (f"{NPM}/@openai/codex/-/codex-0.165.0-linux-x64.tgz",' \
    '                  "f997cd6ef5987126e19cd3c82e847a4a6461270f32f97340c5e99a65fb6f9b8a"),' \
    '        "triple": "x86_64-unknown-linux-musl",' \
    '    },' \
    '    "arm64": {' \
    '        "claude": (f"{NPM}/@anthropic-ai/claude-code-linux-arm64/-/claude-code-linux-arm64-2.1.312.tgz",' \
    '                   "3aa8e624d35e8a77a851e7009b83ae95d3168f24f1afdb0a1ed580a2313d9e5c"),' \
    '        "codex": (f"{NPM}/@openai/codex/-/codex-0.165.0-linux-arm64.tgz",' \
    '                  "c9955808e3598198afe1b8525b5864c0e3f2477339d26e91924e95ed45473baf"),' \
    '        "triple": "aarch64-unknown-linux-musl",' \
    '    },' \
    '}[os.environ["TARGETARCH"]]' \
    'OUT = Path("/out")' \
    '' \
    '' \
    'def fetch(url, sha256):' \
    '    digest = hashlib.sha256()' \
    '    with urllib.request.urlopen(url, timeout=600) as response, tempfile.NamedTemporaryFile(delete=False) as tmp:' \
    '        for chunk in iter(lambda: response.read(1 << 20), b""):' \
    '            digest.update(chunk)' \
    '            tmp.write(chunk)' \
    '    if digest.hexdigest() != sha256:' \
    '        raise SystemExit(f"sha256 mismatch for {url}: got {digest.hexdigest()}, pinned {sha256}")' \
    '    return tmp.name' \
    '' \
    '' \
    'with tarfile.open(fetch(*PINS["claude"])) as tf:' \
    '    member = tf.getmember("package/claude")' \
    '    member.name = "usr/local/bin/claude"' \
    '    tf.extract(member, OUT, filter="data")' \
    '' \
    'prefix = f"package/vendor/{PINS['\''triple'\'']}/"' \
    'with tarfile.open(fetch(*PINS["codex"])) as tf:' \
    '    members = [m for m in tf.getmembers() if m.name.startswith(prefix) and m.name != prefix.rstrip("/")]' \
    '    for m in members:' \
    '        m.name = "opt/codex/" + m.name[len(prefix):]' \
    '    tf.extractall(OUT, members=members, filter="data")' \
    '(OUT / "usr/local/bin/codex").symlink_to("/opt/codex/bin/codex")' \
  | TARGETARCH="${TARGETARCH:-$(dpkg --print-architecture)}" python3 -

FROM python:3.12-slim-bookworm@sha256:e697c81897302a4c4333bade000d98038fbb21eb064f8ee1fd42d02ebcd9d337 AS runtime
LABEL org.opencontainers.image.title="ethara/42f44b68-8927-4f99-af0b-8c795988488b environment" \
      org.opencontainers.image.licenses="MIT" \
      org.opencontainers.image.base.name="docker.io/library/python:3.12-slim-bookworm" \
      org.opencontainers.image.base.digest="sha256:e697c81897302a4c4333bade000d98038fbb21eb064f8ee1fd42d02ebcd9d337"
SHELL ["/bin/bash", "-o", "pipefail", "-c"]
ENV PATH=/opt/venv/bin:$PATH \
    PYTHONDONTWRITEBYTECODE=1
COPY --from=deps /opt/venv /opt/venv
# curl, procps and ripgrep come from a dated Debian snapshot at exact versions, the ones bookworm main carries there
# for amd64 and arm64, so the image is reproducible; procps and ripgrep are the system packages Harbor's own
# installers add for these two agents.
RUN printf 'Types: deb\nURIs: http://snapshot.debian.org/archive/debian/20261020T000000Z\nSuites: bookworm bookworm-updates\nComponents: main\nSigned-By: /usr/share/keyrings/debian-archive-keyring.gpg\n\nTypes: deb\nURIs: http://snapshot.debian.org/archive/debian-security/20261020T000000Z\nSuites: bookworm-security\nComponents: main\nSigned-By: /usr/share/keyrings/debian-archive-keyring.gpg\n' > /etc/apt/sources.list.d/debian.sources \
    && apt-get -o Acquire::Check-Valid-Until=false update \
    && apt-get install -y --no-install-recommends curl=7.88.1-10+deb12u15 procps=2:4.0.2-3 ripgrep=13.0.0-4+b2 \
    && rm -rf /var/lib/apt/lists/*
COPY --from=agents /out/ /
# Both agents and ripgrep must start from the image itself: a broken or truncated download fails the build here.
RUN HOME=/tmp/cli-check CODEX_HOME=/tmp/cli-check sh -c 'claude --version && codex --version && rg --version' \
    && rm -rf /tmp/cli-check
# Agent web tools off. Under a plain `harbor run`, Codex offers a web tool that searches through
# api.openai.com/v1/alpha/search and Claude Code offers WebSearch (run by Anthropic's servers) and WebFetch;
# both hosts are on the agent allowlist, so either agent could read the open web despite the no-network
# environment. The system-level (managed) configs below remove the tools and override user config and flags.
RUN mkdir -p /etc/codex /etc/claude-code \
    && chmod 0755 /etc/codex /etc/claude-code \
    && touch /etc/codex/managed_config.toml \
    && chmod 0644 /etc/codex/managed_config.toml \
    && printf 'web_search = "disabled"\n' >> /etc/codex/managed_config.toml \
    && printf '{"permissions": {"deny": ["WebSearch", "WebFetch"]}}\n' > /etc/claude-code/managed-settings.json \
    && chmod 0444 /etc/codex/managed_config.toml /etc/claude-code/managed-settings.json \
    && grep -qx 'web_search = "disabled"' /etc/codex/managed_config.toml \
    && python3 -c "import json; d=set(json.load(open('/etc/claude-code/managed-settings.json'))['permissions']['deny']); raise SystemExit(0 if {'WebSearch','WebFetch'} <= d else 1)"
# useradd stamps /etc/shadow with the build day and chage keeps that line in /etc/shadow-;
# pin both to day 20754 (2026-10-28, the SOURCE_DATE_EPOCH day) so the layer does not
# depend on when it is built. Login shells (bash -lc) take PATH from /etc/profile, which drops
# the ENV PATH above, so /etc/profile.d puts the venv back in front.
RUN mkdir -p /app/output \
    && groupadd --gid 1000 analyst \
    && useradd --uid 1000 --gid 1000 --create-home --shell /bin/bash analyst \
    && chage --lastday 20754 analyst \
    && cp -p /etc/shadow /etc/shadow- \
    && chown 1000:1000 /app/output \
    && printf '%s\n' "export PATH=/opt/venv/bin:\$PATH" > /etc/profile.d/venv.sh
COPY --chown=0:0 --chmod=0644 docs /app/docs
COPY --chown=0:0 --chmod=0644 data /app/data
COPY --chown=0:0 --chmod=0644 tools /app/tools
RUN find /app/docs /app/data /app/tools -type d -exec chmod 0755 {} +
WORKDIR /app
# The image stays root so the harness can set up the container; task.toml [agent] user = "1000:1000" runs the agent.
# hadolint ignore=DL3002
USER 0
CMD ["/bin/bash"]
