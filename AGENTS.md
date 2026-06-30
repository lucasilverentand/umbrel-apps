# Umbrel App Store Maintenance Guide

This repository is a custom Umbrel app store. umbrelOS treats each non-hidden top-level directory as an installable app package. Hidden directories such as `.tools/`, `.templates/`, and `.github/` are repository support files and must not be treated as apps.

Keep work scoped to the requested app or store-maintenance task. If you find useful follow-up work outside the current objective, file it separately instead of expanding the current change.

## Repository Rules

- Always sign commits.
- Do not use `codex/*` or `claude/*` branch names. Use meaningful names such as `feat/add-example-app`, `fix/hello-world-proxy`, or `chore/update-validation`.
- Keep `main` publishable. A commit on `main` should either be a valid store scaffold or contain only app packages that pass validation.
- Preserve unrelated local changes. Do not reset, clean, or rewrite work you did not create unless explicitly asked.
- Prefer small, focused commits: one app update, one validation improvement, or one documentation change.

## App Package Layout

Each app package lives in a top-level directory named exactly like the app id:

```text
app-id/
  umbrel-app.yml
  docker-compose.yml
  data/
```

Required files:

- `umbrel-app.yml`: Umbrel metadata. `id` must match the directory name.
- `docker-compose.yml`: Runtime services for umbrelOS.

Optional files:

- `data/`: screenshots, config templates, seed files, or placeholder `.gitkeep` files.
- `exports.sh`: only when the app needs to expose values to dependent apps.

Use `.templates/example-app/` when creating a new package, then replace every placeholder before committing.

## Metadata Standards

Keep `umbrel-app.yml` complete and user-facing:

- `manifestVersion` should be `1`.
- `id` should be lowercase kebab-case and match the directory name.
- `category` should use a category already used by Umbrel when possible.
- `name`, `tagline`, and `description` should explain what the user gets after install.
- `version` should match the packaged upstream app version when packaging real software.
- `releaseNotes` should describe the package update or upstream release in practical terms.
- `developer`, `website`, `repo`, and `support` should point to the real upstream project for packaged third-party apps.
- `port` must match the app service port exposed through `app_proxy`.
- `gallery` entries must exist under the app package, usually in `data/`, if screenshots are listed.

Do not add marketing copy that hides setup requirements. If an app needs credentials, first-run configuration, external devices, or a manual setup step, make that clear in the description or release notes.

## Compose Standards

Umbrel packages normally include an `app_proxy` service stub and one or more real services:

```yaml
services:
  app_proxy:
    environment:
      APP_HOST: app-id_server_1
      APP_PORT: 8080
```

Guidelines:

- Route the browser UI through `app_proxy`.
- Persist user data under `${APP_DATA_DIR}`.
- Use `${UMBREL_ROOT}` only when the app intentionally needs shared Umbrel storage.
- Prefer pinned image tags and image digests for real app packages.
- Do not expose host ports unless the app genuinely needs direct LAN access outside the Umbrel proxy.
- Keep default credentials out of committed files. Use Umbrel-supported password fields or generated secrets where possible.
- Avoid privileged containers, host networking, broad host mounts, and Docker socket access unless the app cannot work without them. Document the reason when they are required.

Plain `docker compose config` may reject Umbrel's `app_proxy` stub because it has no image outside umbrelOS. Use it only for additional syntax checks when helpful; the store validator is the required local check.

## Validation

Run this before committing or publishing:

```sh
.tools/validate-store.sh
```

The validator checks that non-hidden top-level app directories include the required files, that metadata ids match directory names, and that proxy wiring is present.

For app changes, also inspect the package manually:

- Confirm `umbrel-app.yml` has no placeholders.
- Confirm every gallery asset exists.
- Confirm `APP_HOST` matches the Compose service name in Umbrel's generated container naming style.
- Confirm `APP_PORT` matches the internal service port.
- Confirm persistent paths use `${APP_DATA_DIR}`.

When possible, install the app on umbrelOS and verify that it opens to a useful browser page, setup flow, login page, or status page without requiring SSH or log scraping.

## Adding A New App

1. Copy `.templates/example-app/` to a new top-level directory.
2. Rename the directory to the final app id.
3. Update `umbrel-app.yml` completely.
4. Update `docker-compose.yml` with the real image, service name, proxy host, proxy port, volumes, and environment.
5. Add screenshots or assets under `data/` if used.
6. Run `.tools/validate-store.sh`.
7. Commit the package with a signed commit.

Do not leave template placeholder values in published packages.

## Updating An App

When updating a packaged app:

- Check the upstream release notes and image tags.
- Update image tags and digests together when digests are used.
- Update `version` and `releaseNotes`.
- Preserve existing user data paths unless a migration is intentional and documented.
- Avoid renaming services, volumes, app ids, or paths unless necessary. Those changes can break installed users.
- Run validation after the update.

If an upstream update includes a security fix, mention that plainly in `releaseNotes`.

## Publishing

The remote for this store should be:

```text
https://github.com/lucasilverentand/umbrel-apps.git
```

Before pushing:

1. Confirm the working tree is clean except intended changes.
2. Run `.tools/validate-store.sh`.
3. Confirm commits are signed with `git log --show-signature`.
4. Push the intended branch.

If GitHub authentication fails, stop and report the exact auth failure. Do not work around it by creating a different repository, using another account, or changing the remote owner.

## Security And Privacy

- Do not commit secrets, tokens, private hostnames, internal URLs, or machine-specific paths.
- Do not include private company or personal operational details in public GitHub issues or package metadata.
- Treat `umbrel-app.yml` and screenshots as public-facing content.
- If a package requires sensitive configuration, document the user-facing setup path instead of committing sample secrets.

## Follow-Up Work

If this repository is published on GitHub and you find useful follow-up work outside the current objective, create a GitHub issue for it. State that Codex created the issue and explain why it was filed. Do not include private or sensitive details unless explicitly approved.

