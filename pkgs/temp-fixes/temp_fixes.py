"""Consult and lint the temporary-fix registry (temp-fixes.toml).

Every workaround in the configuration (pinned package, overlay, forced
option, patch...) has an entry in temp-fixes.toml and a
`TEMP-FIX(<id>)` marker comment next to the code. This tool lists the
entries, reports the ones whose review date has passed, runs their removal
tests and checks that registry and markers agree.
"""

import argparse
import datetime as dt
import os
import re
import subprocess
import sys
import tomllib
from pathlib import Path

REGISTRY_NAME = "temp-fixes.toml"
FALLBACK_ROOT = Path.home() / "Documents" / "nix-configuration"
MARKER_RE = re.compile(r"TEMP-FIX\(([a-z0-9-]+)\)")
ID_RE = re.compile(r"^[a-z0-9][a-z0-9-]*$")
STATUSES = ("active", "resolved")
REQUIRED = (
    "id",
    "title",
    "status",
    "files",
    "reason",
    "removal_condition",
    "added",
    "review_after",
)
# Only code files can carry markers; Markdown (docs, AGENTS.md) is free to
# quote the marker syntax.
MARKER_SUFFIXES = {".nix", ".sh", ".lua", ".py", ".conf", ".el"}
SKIP_DIRS = {".git", ".direnv", "result", "node_modules", ".worktrees"}


def find_registry(explicit):
    if explicit:
        return Path(explicit).resolve()
    env = os.environ.get("TEMP_FIXES_REGISTRY")
    if env:
        return Path(env).resolve()
    here = Path.cwd().resolve()
    for directory in (here, *here.parents):
        candidate = directory / REGISTRY_NAME
        if candidate.is_file():
            return candidate
    return FALLBACK_ROOT / REGISTRY_NAME


def load(registry):
    if not registry.is_file():
        sys.exit(f"temp-fixes: registre introuvable : {registry}")
    with registry.open("rb") as handle:
        data = tomllib.load(handle)
    return data.get("fix", [])


def as_date(value):
    if isinstance(value, dt.date):
        return value
    return dt.date.fromisoformat(str(value))


def is_due(fix, today):
    return fix.get("status") == "active" and as_date(fix["review_after"]) <= today


def filtered(fixes, status, host):
    for fix in fixes:
        if status != "all" and fix.get("status") != status:
            continue
        if host and host not in fix.get("hosts", [host]):
            continue
        yield fix


def cmd_list(fixes, args):
    rows = list(filtered(fixes, args.status, args.host))
    if args.format == "markdown":
        print("| id | titre | hôtes | revue | statut |")
        print("|----|-------|-------|-------|--------|")
        for fix in rows:
            hosts = ", ".join(fix.get("hosts", ["tous"]))
            print(
                f"| `{fix['id']}` | {fix['title']} | {hosts} "
                f"| {fix['review_after']} | {fix['status']} |"
            )
        return 0
    if not rows:
        print("Aucun fix temporaire.")
        return 0
    width = max(len(fix["id"]) for fix in rows)
    for fix in rows:
        flag = "!" if is_due(fix, args.today) else " "
        print(
            f"{flag} {fix['id']:<{width}}  {fix['review_after']}  "
            f"{fix['status']:<8}  {fix['title']}"
        )
    return 0


def cmd_show(fixes, args):
    for fix in fixes:
        if fix.get("id") == args.id:
            for key, value in fix.items():
                if isinstance(value, list):
                    print(f"{key}:")
                    for item in value:
                        print(f"  - {item}")
                else:
                    print(f"{key}: {value}")
            return 0
    print(f"temp-fixes: aucun fix « {args.id} »", file=sys.stderr)
    return 1


def cmd_due(fixes, args):
    due = sorted(
        (fix for fix in fixes if is_due(fix, args.today)),
        key=lambda fix: as_date(fix["review_after"]),
    )
    if args.format == "markdown":
        if not due:
            print("Aucun fix temporaire à revoir. 🎉")
        for fix in due:
            print(f"- [ ] **`{fix['id']}`** — {fix['title']}")
            print(f"  - Revue prévue le {fix['review_after']}")
            print(f"  - Raison : {fix['reason']}")
            print(f"  - Retrait si : {fix['removal_condition']}")
            if fix.get("upstream"):
                print(f"  - Upstream : {fix['upstream']}")
        return 0
    if args.format == "brief":
        for fix in due:
            print(
                f"- {fix['id']} : {fix['title']} (revue due le "
                f"{fix['review_after']} ; retrait si : {fix['removal_condition']})"
            )
        return 0
    if not due:
        print("Aucun fix temporaire à revoir.")
        return 0
    for fix in due:
        print(f"{fix['id']} — {fix['title']}")
        print(f"  revue prévue le : {fix['review_after']}")
        print(f"  retrait si      : {fix['removal_condition']}")
        if fix.get("removal_test"):
            print(f"  test            : {fix['removal_test']}")
    return 0


def scan_markers(root, registry):
    markers = {}
    for path in root.rglob("*"):
        if any(part in SKIP_DIRS for part in path.relative_to(root).parts):
            continue
        if path.suffix not in MARKER_SUFFIXES or not path.is_file():
            continue
        if path == registry:
            continue
        try:
            text = path.read_text(encoding="utf-8")
        except UnicodeDecodeError:
            continue
        for match in MARKER_RE.finditer(text):
            rel = path.relative_to(root).as_posix()
            markers.setdefault(match.group(1), set()).add(rel)
    return markers


def cmd_lint(fixes, args):
    errors = []
    root = args.registry.parent
    seen = set()
    for index, fix in enumerate(fixes):
        label = fix.get("id", f"#{index + 1}")
        missing = [key for key in REQUIRED if key not in fix]
        if missing:
            errors.append(f"{label} : champs manquants : {', '.join(missing)}")
            continue
        if not ID_RE.match(fix["id"]):
            errors.append(f"{label} : id invalide (minuscules, chiffres, tirets)")
        if fix["id"] in seen:
            errors.append(f"{label} : id en double")
        seen.add(fix["id"])
        if fix["status"] not in STATUSES:
            errors.append(f"{label} : statut inconnu « {fix['status']} »")
        for key in ("added", "review_after", "last_challenged", "resolved"):
            if key in fix:
                try:
                    as_date(fix[key])
                except ValueError:
                    errors.append(f"{label} : date invalide pour {key}")
        if fix["status"] == "active":
            for rel in fix["files"]:
                if not (root / rel).is_file():
                    errors.append(f"{label} : fichier introuvable : {rel}")

    by_id = {fix.get("id"): fix for fix in fixes}
    markers = scan_markers(root, args.registry)
    for marker_id, files in sorted(markers.items()):
        fix = by_id.get(marker_id)
        where = ", ".join(sorted(files))
        if fix is None:
            errors.append(f"marqueur TEMP-FIX({marker_id}) sans entrée au registre ({where})")
        elif fix.get("status") != "active":
            errors.append(
                f"marqueur TEMP-FIX({marker_id}) d'un fix résolu, code à retirer ({where})"
            )
        else:
            unlisted = files - set(fix["files"])
            if unlisted:
                errors.append(
                    f"{marker_id} : marqueur dans des fichiers absents de `files` : "
                    f"{', '.join(sorted(unlisted))}"
                )
    for fix in fixes:
        if fix.get("status") != "active" or "files" not in fix:
            continue
        marked = markers.get(fix["id"], set())
        for rel in fix["files"]:
            if rel not in marked and (root / rel).is_file():
                errors.append(f"{fix['id']} : pas de marqueur TEMP-FIX({fix['id']}) dans {rel}")

    for error in errors:
        print(f"erreur : {error}", file=sys.stderr)
    if errors:
        return 1
    active = sum(1 for fix in fixes if fix.get("status") == "active")
    print(f"temp-fixes : registre cohérent ({active} fix actifs, {len(fixes)} au total).")
    return 0


def cmd_check(fixes, args):
    root = args.registry.parent
    wanted = [fix for fix in fixes if fix.get("status") == "active"]
    if not args.all:
        if not args.ids:
            print("temp-fixes check : donner des ids ou --all", file=sys.stderr)
            return 2
        wanted = [fix for fix in wanted if fix["id"] in args.ids]
    status = 0
    for fix in wanted:
        test = fix.get("removal_test")
        if not test:
            print(f"–  {fix['id']} : pas de test automatique ; vérifier : {fix['removal_condition']}")
            continue
        print(f"…  {fix['id']} : {test}", flush=True)
        result = subprocess.run(test, shell=True, cwd=root, capture_output=True, text=True)
        if result.returncode == 0:
            print(f"✅ {fix['id']} : le test passe, le contournement peut sans doute être retiré")
            status = 3
        else:
            print(f"⏳ {fix['id']} : toujours nécessaire (code {result.returncode})")
    return status


def main():
    parser = argparse.ArgumentParser(prog="temp-fixes", description=__doc__.splitlines()[0])
    parser.add_argument("--registry", help=f"chemin du {REGISTRY_NAME}")
    parser.add_argument("--today", type=dt.date.fromisoformat, default=dt.date.today(), help=argparse.SUPPRESS)
    sub = parser.add_subparsers(dest="command", required=True)

    p_list = sub.add_parser("list", help="lister les fix")
    p_list.add_argument("--status", choices=(*STATUSES, "all"), default="active")
    p_list.add_argument("--host")
    p_list.add_argument("--format", choices=("text", "markdown"), default="text")
    p_list.set_defaults(func=cmd_list)

    p_show = sub.add_parser("show", help="afficher un fix")
    p_show.add_argument("id")
    p_show.set_defaults(func=cmd_show)

    p_due = sub.add_parser("due", help="fix dont la date de revue est passée")
    p_due.add_argument("--format", choices=("text", "markdown", "brief"), default="text")
    p_due.set_defaults(func=cmd_due)

    p_lint = sub.add_parser("lint", help="vérifier le registre et les marqueurs")
    p_lint.set_defaults(func=cmd_lint)

    p_check = sub.add_parser("check", help="lancer les tests de retrait")
    p_check.add_argument("ids", nargs="*")
    p_check.add_argument("--all", action="store_true")
    p_check.set_defaults(func=cmd_check)

    args = parser.parse_args()
    args.registry = find_registry(args.registry)
    return args.func(load(args.registry), args)


if __name__ == "__main__":
    sys.exit(main())
