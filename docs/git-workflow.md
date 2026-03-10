# Git Workflow

## Approved Release Path

The tally release flow is automated and must be run via:

```bash
scripts/release-tally.sh <member_count> [last_updated]
```

Examples:

```bash
scripts/release-tally.sh 215
scripts/release-tally.sh 215 "Mar 10 2026"
```

This is the only approved way to revise the tally, regenerate documentation, commit, and push.

## What the Release Script Does

`scripts/release-tally.sh` performs all required release steps:

1. Updates `data.json` (`current`, `lastUpdated`)
2. Regenerates `exports/charts/daily-cumulative-member-tally-2026.md`
3. Exports reporting artifacts to `exports/charts` (SVG + PNG)
4. Stages updated source + chart + SVG exports
5. Creates a commit with a standard message
6. Pushes to `origin/main`

Export artifact policy:

- `exports/charts/*.svg` is version controlled.
- `exports/charts/*.png` is generated for external reporting and ignored by git.

## Export Rendered PDF

To export a PDF that contains rendered Mermaid charts (not raw markdown blocks), run:

```bash
scripts/export-tally-pdf.sh
```

Optional custom output path:

```bash
scripts/export-tally-pdf.sh exports/reports/tally-report.pdf
```

This script:

1. Regenerates `exports/charts/*.png` from Mermaid blocks
2. Builds `exports/charts/daily-cumulative-member-tally-2026-rendered.md` by replacing Mermaid blocks with the rendered PNG charts
3. Uses pandoc to generate a PDF with preserved section headings and notes

## Commit Prerequisite Enforcement

A pre-commit hook auto-refreshes and stages the tally chart before every commit.

- Hook file: `.githooks/pre-commit`
- Generator: `scripts/update-tally-chart.sh`
- Exporter: `scripts/export-tally-charts.sh` (invoked by tally release script)

Enable hooks once per clone:

```bash
git config core.hooksPath .githooks
chmod +x scripts/update-tally-chart.sh scripts/release-tally.sh .githooks/pre-commit
```

After this setup, every commit automatically includes a refreshed chart.

## Chart Labeling Note

Mermaid `xychart-beta` does not reliably support multiline axis labels in this environment.
The chart therefore uses compact labels:

- Day numbers for each tick
- Full month name only when the month changes

This preserves readability while keeping the chart renderer-compatible.
