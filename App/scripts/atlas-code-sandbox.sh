#!/usr/bin/env bash
set -euo pipefail

# E3 sandbox: every branch and commit lives below TMPDIR. This script never
# registers, edits, or deletes a branch in an Atlas workspace.
action="${1:-create}"
root="${2:-${TMPDIR:-/tmp}/atlas-code-sandbox}"

case "$action" in
  create)
    if [[ -e "$root" ]]; then
      printf 'sandbox_exists=%s\n' "$root" >&2
      exit 2
    fi
    mkdir -p "$root"
    git -C "$root" init -q -b main
    git -C "$root" config user.name "Atlas Sandbox"
    git -C "$root" config user.email "atlas-sandbox@example.test"
    printf 'sandbox\n' > "$root/README.md"
    git -C "$root" add README.md
    git -C "$root" commit -q -m "sandbox: baseline"
    git -C "$root" switch -q -c atlas-code-cobaia
    printf 'branch-cobaia\n' > "$root/cobaia.txt"
    git -C "$root" add cobaia.txt
    git -C "$root" commit -q -m "sandbox: branch cobaia"
    printf 'repo_path=%s\nbranch=atlas-code-cobaia\nresolve=%s resolve\n' "$root" "$0"
    ;;
  resolve)
    git -C "$root" switch -q main
    git -C "$root" branch -D -q atlas-code-cobaia
    printf 'repo_path=%s\nbranch=main\nbranch_cobaia=absent\n' "$root"
    ;;
  *)
    printf 'usage: %s create [tmp-path] | %s resolve <tmp-path>\n' "$0" "$0" >&2
    exit 64
    ;;
esac
