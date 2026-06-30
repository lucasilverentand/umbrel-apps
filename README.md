# Umbrel App Store

This repository is a custom Umbrel app store. umbrelOS consumes app packages from non-hidden top-level directories in the repository.

## Add An App

1. Copy `.templates/example-app/` to a new top-level directory named with the app id, for example `my-app/`.
2. Update `my-app/umbrel-app.yml`.
3. Update `my-app/docker-compose.yml`.
4. Put screenshots or app assets under `my-app/data/` if the metadata references them.
5. Run `.tools/validate-store.sh`.

The package id in `umbrel-app.yml` should match the directory name.

## Install In umbrelOS

Publish this repository to GitHub or another Git host, then add the repository URL as a community/custom app store in umbrelOS.

Use a stable branch, usually `main`, so umbrelOS can pull updates predictably.

## Package Standard

Apps should open to a browser-based UI, setup flow, login page, or status page that gives users a clear next step without SSH, CLI access, log scraping, or manual file edits.

Use pinned image tags and image digests where practical, persist user data under `${APP_DATA_DIR}`, and route the main web UI through the `app_proxy` service.

