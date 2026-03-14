# Daily Cumulative Member Tally (2026)

## 1) Cumulative (Full Scale)

```mermaid
xychart-beta
    title "Daily Cumulative Member Tally (2026) - Full Scale"
  x-axis ["2.25", "26", "27", "28", "3.1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12", "13"]
  y-axis "Members" 0 --> 240
  bar [167, 170, 173, 175, 181, 183, 183, 186, 187, 190, 196, 203, 211, 214, 217, 217, 220]
```

## 2) Cumulative (Zoomed)

```mermaid
xychart-beta
    title "Daily Cumulative Member Tally (2026) - Zoomed"
    x-axis ["2.25", "26", "27", "28", "3.1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12", "13"]
    y-axis "Members" 150 --> 240
    bar [167, 170, 173, 175, 181, 183, 183, 186, 187, 190, 196, 203, 211, 214, 217, 217, 220]
```

## 3) Daily Net Change

```mermaid
xychart-beta
    title "Daily Net Member Change (2026)"
    x-axis ["2.25", "26", "27", "28", "3.1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12", "13"]
    y-axis "New Members" 0 --> 10
    bar [0, 3, 3, 2, 6, 2, 0, 3, 1, 3, 6, 7, 8, 3, 3, 0, 3]
```

Data approach:
- One end-of-day cumulative value per date.
- Missing calendar dates are carry-forward values from the previous day.
- Label format uses numeric month.day when the month changes, otherwise day only.
- Daily net change is the day-over-day difference from the cumulative series.
