#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$repo_root"

output_file="docs/daily-cumulative-member-tally-2026.md"

tmp_history="$(mktemp)"
trap 'rm -f "$tmp_history"' EXIT

# Build one tally per commit date from data.json history.
while IFS='|' read -r commit_date commit_hash; do
  current_val="$(git show "${commit_hash}:data.json" 2>/dev/null | grep '"current"' | sed -E 's/[^0-9]*([0-9]+).*/\1/' | head -n1 || true)"
  if [[ -n "${current_val}" ]]; then
    echo "${commit_date}|${current_val}" >> "$tmp_history"
  fi
done < <(git log --follow --reverse --format='%ad|%H' --date=short -- data.json)

# Keep only the latest tally for each date, then include current working tree value.
consolidated="$(awk -F'|' '{daily[$1]=$2} END {for (d in daily) print d"|"daily[d]}' "$tmp_history" | sort)"

today_iso="$(python3 - <<'PY'
import json
from datetime import datetime

with open('data.json', 'r', encoding='utf-8') as f:
    data = json.load(f)

raw = str(data.get('lastUpdated', '')).strip()
for fmt in ('%b %d, %Y', '%b %d %Y'):
    try:
        dt = datetime.strptime(raw, fmt)
        print(dt.strftime('%Y-%m-%d'))
        break
    except ValueError:
        continue
else:
    raise SystemExit(f'Could not parse lastUpdated date: {raw}')
PY
)"

today_count="$(python3 - <<'PY'
import json
with open('data.json', 'r', encoding='utf-8') as f:
    data = json.load(f)
print(int(data['current']))
PY
)"

# Python handles date expansion and markdown generation for portability.
python3 - <<'PY' "$output_file" "$consolidated" "$today_iso" "$today_count"
import sys
from datetime import date, timedelta, datetime

output_file, consolidated_blob, today_iso, today_count = sys.argv[1], sys.argv[2], sys.argv[3], int(sys.argv[4])

daily = {}
for line in consolidated_blob.splitlines():
    line = line.strip()
    if not line:
        continue
    d, v = line.split('|', 1)
    daily[d] = int(v)

# Ensure working tree value is reflected pre-commit.
daily[today_iso] = today_count

dates = sorted(daily.keys())
if not dates:
    raise SystemExit('No data points found for chart generation')

start = datetime.strptime(dates[0], '%Y-%m-%d').date()
end = datetime.strptime(dates[-1], '%Y-%m-%d').date()

expanded_dates = []
expanded_values = []
cur = start
last_val = None
while cur <= end:
    key = cur.strftime('%Y-%m-%d')
    if key in daily:
        last_val = daily[key]
    if last_val is None:
        cur += timedelta(days=1)
        continue
    expanded_dates.append(cur)
    expanded_values.append(last_val)
    cur += timedelta(days=1)

# xychart-beta does not support multiline tick labels reliably, so keep compact labels.
# Format: month-change ticks use M.D (for example 2.25, 3.1); other ticks use D only.
labels = []
prev_month = None
for d in expanded_dates:
    day = str(d.day)
    if prev_month != d.month:
        labels.append(f'{d.month}.{day}')
    else:
        labels.append(day)
    prev_month = d.month

max_val = max(expanded_values)
y_max = ((max_val // 10) + 2) * 10
zoom_min = 150

daily_changes = [0]
for i in range(1, len(expanded_values)):
    daily_changes.append(expanded_values[i] - expanded_values[i - 1])

change_max = max(daily_changes) if daily_changes else 0
change_y_max = max(5, ((change_max + 4) // 5) * 5)

year_label = expanded_dates[0].year if expanded_dates[0].year == expanded_dates[-1].year else f'{expanded_dates[0].year}-{expanded_dates[-1].year}'

x_axis = ', '.join(f'"{l}"' for l in labels)
bars = ', '.join(str(v) for v in expanded_values)
changes = ', '.join(str(v) for v in daily_changes)

content = f'''# Daily Cumulative Member Tally ({year_label})

## 1) Cumulative (Full Scale)

```mermaid
xychart-beta
    title "Daily Cumulative Member Tally ({year_label}) - Full Scale"
  x-axis [{x_axis}]
  y-axis "Members" 0 --> {y_max}
  bar [{bars}]
```

## 2) Cumulative (Zoomed)

```mermaid
xychart-beta
    title "Daily Cumulative Member Tally ({year_label}) - Zoomed"
    x-axis [{x_axis}]
    y-axis "Members" {zoom_min} --> {y_max}
    bar [{bars}]
```

## 3) Daily Net Change

```mermaid
xychart-beta
    title "Daily Net Member Change ({year_label})"
    x-axis [{x_axis}]
    y-axis "New Members" 0 --> {change_y_max}
    bar [{changes}]
```

Data approach:
- One end-of-day cumulative value per date.
- Missing calendar dates are carry-forward values from the previous day.
- Label format uses numeric month.day when the month changes, otherwise day only.
- Daily net change is the day-over-day difference from the cumulative series.
'''

with open(output_file, 'w', encoding='utf-8') as f:
    f.write(content)
PY

echo "Updated ${output_file}"