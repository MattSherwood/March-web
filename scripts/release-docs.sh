#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$repo_root"

if [[ $# -lt 1 ]]; then
  echo "Usage: scripts/release-docs.sh \"<commit message>\" [file ...]"
  echo "Example: scripts/release-docs.sh \"Add full, zoomed, and daily-change tally charts\""
  exit 1
fi

commit_message="$1"
shift || true

scripts/update-tally-chart.sh

if [[ $# -gt 0 ]]; then
  git add "$@"
else
  git add exports/charts/daily-cumulative-member-tally-2026.md scripts/update-tally-chart.sh
fi

git commit -m "$commit_message"
git push

echo "Docs release complete: ${commit_message}"
