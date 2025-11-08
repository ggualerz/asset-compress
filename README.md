# README — asset-compress

Pre-compress static assets to Brotli (`.br`) and Gzip (`.gz`) variants. Minimal, non-root, CI-friendly.
Base image: **SUSE BCI Base**

## What it does

- Recursively scans your working directory (or supplied paths) for common static asset extensions.
- Emits sibling `.br` and `.gz` files beside each source when the source is newer than existing precompressed outputs.
- Operates safely in read-only-friendly environments by writing through temporary files before atomic renames.
- Ships with Brotli, gzip, and pigz CLIs so you can choose between single-threaded or multi-core gzip compression.
- Runs as a non-root user by default (UID/GID `65532:65532`).

## Requirements

- Docker (or a compatible container runtime).
- A directory containing assets to compress, mounted at `/work`.

## CLI behavior

- **Default command:** `precompress-static-assets`.
- **No args:** scans `/work` recursively.
- **With args:** limits work to the provided files or directories (relative to `/work`).
- Automatically skips files whose extension is outside the configured allowlist and ignores existing `.gz` / `.br` artifacts.
- Timestamp-aware: only regenerates compressed outputs when the source file is newer or the outputs are missing.

## Tuning (environment variables)

- `BROTLI_QUALITY` (default: `11`) — Brotli compression level (0–11).
- `GZIP_LEVEL` (default: `9`) — gzip/pigz compression level (1–9).
- `PREFER_PIGZ` (default: unset) — set to `1` to prefer `pigz` (parallel gzip). Otherwise the script uses the stock `gzip` binary.
- `PIGZ_PROCESSES` (default: `0`) — when `PREFER_PIGZ=1`, controls the number of worker processes (`0` = auto).
- `ASSET_EXTENSIONS` — comma-separated list of extensions to compress (overrides defaults).
- `ADDITIONAL_EXTENSIONS` — comma-separated list appended to the defaults or `ASSET_EXTENSIONS` list.

## Pairing with a webserver

Run this container during build or deploy to pre-generate Brotli/Gzip artifacts that can be served directly by your webserver or CDN (e.g., via `try_files` rules that prefer `.br` and `.gz` when present).

## Built-in helpers

The container bundles a minimal toolkit to support asset workflows:

- **brotli** — reference Brotli encoder.
- **gzip** — GNU gzip CLI.
- **pigz** — parallel gzip encoder for multi-core environments.
- **find** / **gawk** — used internally to discover assets and handle timestamp comparisons.

## Publishing to Docker registries

Use `publish-asset-compress.sh` to build and push versioned tags that follow the `x.y.z-bci-base-16.0-10.3` pattern. Populate `release.env` with your registry credentials and tagging preferences before running the script.

## Versioning note

When publishing releases, tag images with `MAJOR.MINOR.PATCH-bci-base-16.0-10.3` to communicate both the project version and SUSE base image revision.
