#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$repo_root"

source_md="docs/daily-cumulative-member-tally-2026.md"
output_dir="exports/charts"
tmp_dir="$(mktemp -d)"
trap 'rm -rf "$tmp_dir"' EXIT

if ! command -v npx >/dev/null 2>&1; then
  echo "Error: npx not found. Install Node.js/npm first."
  exit 1
fi

if [[ ! -f "$source_md" ]]; then
  echo "Error: source file not found: $source_md"
  exit 1
fi

mkdir -p "$output_dir"

python3 - <<'PY' "$source_md" "$tmp_dir"
import re
import sys
from pathlib import Path

source_md = Path(sys.argv[1])
tmp_dir = Path(sys.argv[2])
text = source_md.read_text(encoding='utf-8')

blocks = re.findall(r"```mermaid\n(.*?)```", text, flags=re.DOTALL)
if not blocks:
    raise SystemExit("No mermaid blocks found")

def slugify(value: str) -> str:
    value = value.strip().lower()
    value = re.sub(r"[^a-z0-9]+", "-", value)
    value = re.sub(r"-+", "-", value).strip("-")
    return value or "chart"

used = set()
for idx, block in enumerate(blocks, start=1):
    title_match = re.search(r'^\s*title\s+"([^"]+)"', block, flags=re.MULTILINE)
    title = title_match.group(1) if title_match else f"chart-{idx}"
    base = f"{idx:02d}-{slugify(title)}"
    name = base
    suffix = 2
    while name in used:
        name = f"{base}-{suffix}"
        suffix += 1
    used.add(name)
    (tmp_dir / f"{name}.mmd").write_text(block.strip() + "\n", encoding='utf-8')
PY

count=0
for mmd_file in "$tmp_dir"/*.mmd; do
  base_name="$(basename "$mmd_file" .mmd)"
  svg_out="$output_dir/$base_name.svg"
  png_out="$output_dir/$base_name.png"

  npx -y @mermaid-js/mermaid-cli -i "$mmd_file" -o "$svg_out"
  npx -y @mermaid-js/mermaid-cli -i "$mmd_file" -o "$png_out" -w 2400 -H 1400 -s 2

  count=$((count + 1))
done

echo "Exported $count chart(s) to $output_dir"
ls -1 "$output_dir"
