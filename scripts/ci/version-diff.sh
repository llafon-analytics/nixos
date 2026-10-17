#!/usr/bin/env bash
# Markdown summary of package version changes between two outputs of
# scripts/ci/package-versions.nix.
#   version-diff.sh before.json after.json
set -euo pipefail

before=$1
after=$2

jq -r --slurpfile old "$before" --slurpfile new "$after" -n '
  ($old[0] | keys) + ($new[0] | keys) | unique | .[] as $host
  | ($old[0][$host] // {}) as $o
  | ($new[0][$host] // {}) as $n
  | [ (($o | keys) + ($n | keys) | unique | .[])
      | select($o[.] != $n[.])
      | "| `\(.)` | \($o[.] // "—") | \($n[.] // "—") |" ] as $rows
  | "### \($host)\n",
    (if ($rows | length) == 0 then "Aucun changement de version.\n"
     else "| paquet | avant | après |\n|---|---|---|\n" + ($rows | join("\n")) + "\n" end)
'
