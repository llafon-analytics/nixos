# CI

GitHub Actions workflows in `.github/workflows/`:

| Workflow | Trigger | Role |
|---|---|---|
| `ci.yml` | push to `main`, PRs | **lint** job (`treefmt`, `temp-fixes-lint`, `hyprland-lua` checks) and **eval** job (`nix flake check --no-build`, evaluates both hosts) |
| `docs.yml` | changes to `docs/` or `mkdocs.yml` | `mkdocs build --strict`; GitHub Pages deployment from `main` |
| `update-flake-lock.yml` | Mondays 04:00 UTC, manual | lock update PR + comment (version diff, temporary-fix removal tests) |
| `temp-fixes-review.yml` | Mondays 07:00 UTC, manual | single "Revue des fix temporaires" issue listing overdue fixes |
| `build-laptop.yml` | PRs touching `flake.lock`, manual | full laptop build (non-blocking) |

## Limits

- The **desktop is not built** in CI: global CUDA, DaVinci Resolve and kernel modules are too much
  for a hosted runner. It is evaluated on every push.
- A PR opened with the default `GITHUB_TOKEN` does not trigger `ci.yml`. To get checks on the lock
  PRs, add a `FLAKE_UPDATE_TOKEN` secret (fine-grained PAT: *contents* and *pull requests* write).
  The evaluation runs in `update-flake-lock.yml` either way.
- Deploying the docs requires *Settings → Pages → Source: GitHub Actions*.

## To configure on GitHub

- Protect `main`: require the `Lint (format, temp-fixes, Lua)` and `Evaluate both hosts` checks.
