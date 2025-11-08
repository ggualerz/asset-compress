FROM registry.suse.com/bci/bci-base:16.0-10.3 AS builder

RUN zypper --non-interactive ref && \
    zypper --non-interactive install --no-recommends \
      bash \
      coreutils \
      findutils \
      brotli \
      gzip \
      pigz \
      gawk && \
    zypper clean -a

ENV INSTALL_PREFIX=/opt/tools
RUN mkdir -p "${INSTALL_PREFIX}/bin"

RUN install -Dm755 /usr/bin/brotli "${INSTALL_PREFIX}/bin/brotli" && \
    install -Dm755 /usr/bin/gzip "${INSTALL_PREFIX}/bin/gzip" && \
    install -Dm755 /usr/bin/pigz "${INSTALL_PREFIX}/bin/pigz" && \
    install -Dm755 /usr/bin/find "${INSTALL_PREFIX}/bin/find" && \
    install -Dm755 /usr/bin/gawk "${INSTALL_PREFIX}/bin/gawk"

FROM registry.suse.com/bci/bci-base:16.0-10.3

ENV BROTLI_QUALITY=11 \
    GZIP_LEVEL=9 \
    PIGZ_PROCESSES=0

RUN zypper --non-interactive ref && \
    zypper --non-interactive install --no-recommends \
      bash \
      coreutils \
      findutils \
      gawk \
      brotli && \
    zypper clean -a

COPY --from=builder /opt/tools /opt/tools

RUN set -euo pipefail && \
    mkdir -p /usr/local/bin && \
    for bin in /opt/tools/bin/*; do \
      ln -sf "$bin" /usr/local/bin/"$(basename "$bin")"; \
    done && \
    if ! getent group 65532 >/dev/null; then groupadd --gid 65532 nonroot; fi && \
    if ! id -u 65532 >/dev/null 2>&1; then useradd --uid 65532 --gid 65532 --home-dir /work --shell /bin/bash nonroot; fi

COPY precompress-static-assets /usr/local/bin/precompress-static-assets
RUN chmod +x /usr/local/bin/precompress-static-assets

WORKDIR /work

USER 65532:65532

ENTRYPOINT ["precompress-static-assets"]
