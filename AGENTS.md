# Umbrel App Store Agent Guide

This repository is an Umbrel app store. Each non-hidden top-level directory is an app package consumed by umbrelOS.

Keep changes scoped to the requested app unless the task explicitly requires shared store changes.

## Package Layout

Each app package should include:

- `umbrel-app.yml` for app metadata.
- `docker-compose.yml` for the runtime services.
- `data/` for screenshots, config templates, or other package assets when needed.
- `exports.sh` only when the app needs to expose values to other apps.

Use `.templates/example-app/` as the starting point for a new package, then rename every placeholder before publishing.

## Validation

Run `.tools/validate-store.sh` before publishing changes. It checks the root layout and the required package files without installing dependencies.

