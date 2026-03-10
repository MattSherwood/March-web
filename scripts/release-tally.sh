#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$repo_root"

if [[ $# -lt 1 || $# -gt 2 ]]; then
  echo "Usage: scripts/release-tally.sh <member_count> [last_updated]"
  echo "Example: scripts/release-tally.sh 215 'Mar 10 2026'"
  echo "If last_updated is omitted, today's date is used in 'Mon D YYYY' format."
  exit 1
fi

new_count="$1"
if ! [[ "$new_count" =~ ^[0-9]+$ ]]; then
  echo "Error: member_count must be numeric."
  exit 1
fi

if [[ $# -eq 2 ]]; then
  new_date="$2"
else
  new_date="$(date '+%b %-d %Y')"
fi

python3 - <<'PY' "$new_count" "$new_date"
import json
import sys

new_count = int(sys.argv[1])
new_date = sys.argv[2]

with open('data.json', 'r', encoding='utf-8') as f:
    data = json.load(f)

data['current'] = new_count
data['lastUpdated'] = new_date

with open('data.json', 'w', encoding='utf-8') as f:
    json.dump(data, f, indent=2)
    f.write('\n')
PY

scripts/update-tally-chart.sh

git add data.json docs/daily-cumulative-member-tally-2026.md

git commit -m "Update members count to ${new_count} for ${new_date}"
git push

echo "Release complete: members=${new_count}, lastUpdated='${new_date}'"