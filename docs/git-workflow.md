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
2. Regenerates `docs/daily-cumulative-member-tally-2026.md`
3. Stages both files
4. Creates a commit with a standard message
5. Pushes to `origin/main`

## Commit Prerequisite Enforcement

A pre-commit hook auto-refreshes and stages the tally chart before every commit.

- Hook file: `.githooks/pre-commit`
- Generator: `scripts/update-tally-chart.sh`

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
