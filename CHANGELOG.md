# Changelog

All notable user-visible changes to the IT-Tools TOS application package.

## 2024.10.22-3 — 2026-11-12

### Changed
- Icon: replaced the letter monogram with a functional vector mark that describes what the app does (the upstream project does not publish a compliant SVG).

## 2024.10.22-2 — 2026-11-12

### Changed
- Icon: replaced the letter monogram with a functional vector mark that describes what the app does (the upstream project does not publish a compliant SVG).

## 2024.10.22-1 — 2026-11-09

### Added
- First release. IT-Tools (`corentinth/it-tools:2024.10.22-7ca5933`, Docker Hub official image, unmodified)
  packaged as a TOS 7 Docker application, published on port 8027 and running
  as a non-root user (1000:1000).
- Persistent data is kept under `/Volume1/DockerAppData/ittoolsdocker/`.
