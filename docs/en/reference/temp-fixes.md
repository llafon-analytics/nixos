# Temporary fixes

A **temporary fix** is a workaround we hope to remove some day: a package pinned or taken from
unstable because stable is broken, a corrective overlay, an option forced against a module, a patch,
a compatibility flag… They are recorded in **`temp-fixes.toml`** at the repository root and
marked in the code with a `TEMP-FIX(<id>)` comment.

## Consult

The `temp-fixes` command is installed for both users (otherwise `nix run .#temp-fixes --`). It finds
the registry from the current directory or, failing that, in `~/Documents/nix-configuration`.

```sh
temp-fixes list                     # active fixes ("!" = review overdue)
temp-fixes list --status all --host desktop
temp-fixes show solaar-unstable
temp-fixes due                      # fixes whose review date has passed
temp-fixes check --all              # run the automatic removal tests
temp-fixes lint                     # registry <-> marker consistency (also in CI)
```

`check` prints ✅ when the removal test passes (the fix can probably be removed), ⏳ otherwise.

## Entry format

```toml
[[fix]]
id = "solaar-unstable"
title = "Solaar taken from nixpkgs-unstable"
status = "active"                   # active | resolved
hosts = ["desktop", "laptop"]
files = ["modules/nixos/hardware/logitech.nix"]   # files carrying the marker
reason = "The solaar 1.1.19 test suite fails in the sandbox."
removal_condition = "The stable solaar builds."
removal_test = "nix build --no-link --inputs-from . nixpkgs#solaar"   # optional
upstream = "https://…"              # optional
added = 2026-10-17
review_after = 2026-11-28
last_challenged = 2026-10-17        # optional
resolved = 2026-12-01               # when status = "resolved"
history = ["2026-10-17 : entry created during the audit."]
```

The registry text itself is written in French. `removal_test` runs from the repository root and
must **succeed once the fix is no longer needed**. `--inputs-from .` makes `nixpkgs#…` resolve to
the flake's locked input.

## Being challenged regularly

| When | What |
|---|---|
| Claude Code session start | the `SessionStart` hook hands the overdue fixes to the agent; it challenges you on at most two of them and records your decision |
| Editing a marked file | the agent rereads the entry and says whether the fix is still justified |
| Weekly lock PR | comment with the result of `temp-fixes check --all` |
| Every Monday | GitHub issue "Revue des fix temporaires" updated (comment when the list changes) |

## Deciding

- **Keep**: update `last_challenged`, `review_after` and add a line to `history`.
- **Remove**: delete the workaround and its marker, set the entry to `resolved` with the date and a
  history line. The entry stays as a record.

An agent can make these updates (`temp-fixes` skill).
