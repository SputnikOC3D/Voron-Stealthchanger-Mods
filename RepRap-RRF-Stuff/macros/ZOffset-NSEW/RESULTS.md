# Calibration Results

Summary of final results from each calibration run in
[`zoff_nsew_log.csv`](zoff_nsew_log.csv) — one row per tool per run, pulled
from that file's `C`/`CENTER` (final result) rows. T0 is the reference
tool (`Z offset` is always blank for T0 since every other tool's offset is
computed relative to it). This table is just the headline numbers — for
every individual N/S/E/W touch and the per-side averages behind each of
these results, see [RESULTS-FULL.md](RESULTS-FULL.md).

| Timestamp | Tool | Center X | Center Y | Z result (mm) | Z offset (mm) |
|---|---|---|---|---|---|
| 2026-07-15T13:41:23 | T0 | 250.6162 | 2.091251 | 5.420000 | — (reference) |
| 2026-07-15T13:41:23 | T1 | 250.6268 | 1.933748 | 5.871500 | 0.4514999 |
| 2026-07-15T13:41:23 | T2 | 249.6325 | 1.751250 | 6.194000 | 0.7740002 |
| 2026-07-16T22:42:01 | T0 | 250.5275 | 1.962499 | 5.432500 | — (reference) |
| 2026-07-16T22:42:01 | T1 | 250.5280 | 1.847501 | 5.539000 | 0.1065001 |
| 2026-07-16T22:42:01 | T2 | — | — | — | *run aborted (Y- pre-trigger failure — see readme changelog)* |
| 2026-07-17T07:44:55 | T0 | 250.5137 | 2.008751 | 5.437000 | — (reference) |
| 2026-07-17T07:44:55 | T1 | 250.5130 | 1.856249 | 5.560000 | 0.1230001 |
| 2026-07-17T07:44:55 | T2 | 249.5512 | 1.680626 | 5.803000 | 0.3660002 |
| 2026-07-17T10:11:24 | T0 | 250.5138 | 1.996250 | 5.431500 | — (reference) |
| 2026-07-17T10:11:24 | T1 | 250.5105 | 1.849998 | 5.551000 | 0.1195002 |
| 2026-07-17T10:11:24 | T2 | 249.5500 | 1.643749 | 5.786500 | 0.3550000 |

**Trend:** T1 and T2's offsets tightened significantly after the stale
tool-offset contamination fix (2026-07-16, see readme) — T1 dropped from
0.451mm (contaminated, 07-15) to a stable 0.107–0.123mm range across the
three clean runs; T2's first clean measurement (07-17) landed at
0.355–0.366mm, consistent across both same-day runs.
