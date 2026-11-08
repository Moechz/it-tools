# it-tools-for-tos

> TerraMaster TOS 7 App Center — **Docker application** package for
> [IT-Tools](https://github.com/CorentinTh/it-tools).

## What this is

A four-file TOS Docker application archive (`ittoolsdocker.tar.gz`) that installs
IT-Tools on TOS 7 through the App Center:

- `config.ini` — TOS application metadata (`application_type: docker`, id `ittoolsdocker`)
- `ittoolsdocker.lang` — 23-language superset (TOS requires 14)
- `ittoolsdocker.svg` — application icon (326 bytes, 2 SVG elements)
- `docker-compose.yml` — one service, image `corentinth/it-tools:2024.10.22-7ca5933`

## How it works

| | |
|---|---|
| Container image | `corentinth/it-tools:2024.10.22-7ca5933` (Docker Hub, used unmodified) |
| Open | `http://<NAS-IP>:8027/` (container port 8080) |
| Runs as | non-root, `user: "1000:1000"` |
| Persistent data | `/data` → `/Volume1/DockerAppData/ittoolsdocker/data` |
| Logs | `docker logs ittoolsdocker` (stdout/stderr) |

IT-Tools is a static single-page application. It has no database, no uploads and no server-side state; the optional `/data` mount is unused and can be ignored.

## Design highlights

- **Non-root.** `user: "1000:1000"`; verified on real hardware (the container reports uid 1000).
- **Rootless nginx wrapper.** The image starts nginx as root on port 80; `src/entrypoint.sh` starts it as uid 1000 on port 8080 with `/tmp` pid/temp/log paths. The application files are unmodified.
- **Fixed image tag, never `:latest`**, Docker Hub only, no `privileged`, no `network_mode: host`, and no Docker socket, no `cap_add`.
- **Health check** probing the service on container port 8080.
- **Deterministic build**: GNU tar with uid/gid 0 and zeroed timestamps, gzip without a timestamp, plus the review-standards self-check above.
- **Rootless nginx.** The upstream nginx runs as root on port 80; `src/entrypoint.sh` runs it as uid 1000 on 8080 with pid/temp/log paths under `/tmp`; the static files are unmodified.
- **No persistence.** The app is a static SPA; there is nothing to back up.
- **One port.** Only 8080 is published; no privileged mode, no host network, no Docker socket.
- **Health check** probes `/` on 8080.

## Runtime file manifest

Everything the application writes on the NAS lives inside its own data
directory; the container-internal `/tmp` is discarded with the container. The
table lists what is created and how it behaves. Nothing else is written.

| Path | Purpose | Created when | Growth bound | Lifecycle |
|---|---|---|---|---|
| `/Volume1/DockerAppData/ittoolsdocker/data` | IT-Tools application data (everything the container writes outside /tmp) | on first start / on demand | bounded by your own data | persistent; kept on uninstall unless you ask to delete it |

## Build

```bash
scripts/build.sh                  # -> out/ittoolsdocker.tar.gz + .sha256
scripts/build.sh 2024.10.22-2   # packaging iteration bump
scripts/build.sh 2024.10.22-1 aarch64
```

The build stages the four files, substitutes the version/platform placeholders,
embeds `src/entrypoint.sh` into the compose file (escaping every `$` as `$$`), removes CRLF/BOM/AppleDouble, then runs
`tools/verify.py`, a review-standards self-check (archive layout, JSON validity,
required fields, 14+ language coverage, version consistency, Docker-Hub-only
images, fixed tag, reserved/recommended host ports, non-root user, per-service
healthcheck/TZ/restart, data path below the application data root, never the
`/Volume*` wildcard, comment-free sequence blocks, `x-app-meta` position, no
literal secrets and the SVG size/element limits).

## Local verification

```bash
./TOSAppSelfTestingTool -c out/ittoolsdocker.tar.gz   # official spec check
bash test/install-and-verify.sh                  # on-device E2E (needs root)
```

> Docker applications cannot be side-loaded through the App Center's manual
> install page (it accepts `.deb` only); the official self-testing tool's `-i`
> mode or `docker compose` are the only ways to install one for testing.

## Store submission checklist

1. Public GitHub repo (code + README only).
2. Release **tag `v2024.10.22-1`**, assets `ittoolsdocker.tar.gz` +
   `ittoolsdocker.tar.gz.sha256` (Docker asset naming: `<app_id>.tar.gz`, **no
   platform suffix**).
3. Developer platform → Add Application: ID `ittoolsdocker`, package type Docker,
   repository URL, architecture `x86_64`.
4. Version Management → Add Version `2024.10.22-1` → automated validation → review.

## License / branding

IT-Tools is distributed by its upstream authors under **GPL-3.0**. The container image is the official image from Docker Hub (`corentinth/it-tools:2024.10.22-7ca5933`) and is used unmodified; no upstream source code is redistributed here. This packaging is an independent community submission by Moechz and is not affiliated with the upstream project or TerraMaster.

## Limitations

No login and no server-side storage: do not use it for secrets that must be kept on the NAS.
Some browser features (clipboard, file APIs) depend on the browser and on HTTPS; over plain HTTP on the LAN some tools may be limited.
Plain HTTP on the LAN; do not expose the published port to the internet without a TLS reverse proxy.

---

Packaged for TOS 7 by Moechz. Upstream image used unmodified from Docker Hub.
