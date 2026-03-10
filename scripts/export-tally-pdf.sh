#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$repo_root"

source_md="exports/charts/daily-cumulative-member-tally-2026.md"
rendered_md="exports/charts/daily-cumulative-member-tally-2026-rendered.md"
output_pdf="${1:-exports/charts/daily-cumulative-member-tally-2026.pdf}"
output_dir="$(dirname "$output_pdf")"
image_width="${TALLY_PDF_IMAGE_WIDTH:-97%}"

if ! command -v pandoc >/dev/null 2>&1; then
  echo "Error: pandoc not found. Install pandoc first."
  exit 1
fi

scripts/export-tally-charts.sh

shopt -s nullglob
png_files=(exports/charts/*.png)
shopt -u nullglob

if [[ ${#png_files[@]} -eq 0 ]]; then
  echo "Error: no PNG charts found in exports/charts."
  exit 1
fi

mkdir -p "$output_dir"

python3 - <<'PY' "$source_md" "$rendered_md" "$image_width" "${png_files[@]}"
import re
import sys
from pathlib import Path

source_md = Path(sys.argv[1])
rendered_md = Path(sys.argv[2])
image_width = sys.argv[3]
image_paths = [path.replace('\\', '/') for path in sys.argv[4:]]
text = source_md.read_text(encoding='utf-8')

titles = re.findall(r'^##\s+(.+)$', text, flags=re.MULTILINE)
blocks = list(re.finditer(r'```mermaid\n.*?```', text, flags=re.DOTALL))
if len(blocks) != len(image_paths):
  raise SystemExit(f'Expected {len(blocks)} PNG charts, found {len(image_paths)}')

parts = []
last = 0
section_index = 0
for block, image_name in zip(blocks, image_paths):
    before = text[last:block.start()]
    if section_index > 0 and before.lstrip().startswith('## '):
        before = '\\newpage\n\n' + before

    title = titles[section_index] if section_index < len(titles) else f'Chart {section_index + 1}'
    image_markdown = f'![{title}]({image_name}){{ width={image_width} }}\n'
    parts.append(before)
    parts.append(image_markdown)
    last = block.end()
    section_index += 1

tail = text[last:]
if 'Data approach:' in tail:
    tail = tail.replace('Data approach:', '\\vfill\n\nData approach:', 1)

parts.append(tail)
rendered_md.write_text(''.join(parts), encoding='utf-8')
PY

pandoc "$rendered_md" -o "$output_pdf"

echo "Rendered PDF written to: $output_pdf"