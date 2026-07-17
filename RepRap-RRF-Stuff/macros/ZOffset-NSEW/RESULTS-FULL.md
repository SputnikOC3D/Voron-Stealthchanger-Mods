# Calibration Results — Full Data

Every value logged during each calibration run, reconstructed from [`zoff_nsew_log.csv`](zoff_nsew_log.csv) into readable tables: the raw N/S/E/W and center touches (one row per physical probe contact), the per-side averages, and the final computed Z result/offset. For the condensed just-the-headline-numbers version, see [RESULTS.md](RESULTS.md).

CSV column reference: `timestamp,tool,phase,x_minus,x_plus,y_minus,y_plus,center_x,center_y,z_result,z_offset,nsew_x_depth,nsew_y_depth`. Raw-tap rows (`TX-`/`TX+`/`TY-`/`TY+`) repurpose the `x_minus` column for the single reading, `y_minus` as the sample number (1-5), `y_plus` as the depth tried that attempt. `x_plus` holds the ladder attempt number for X-/Y- (the discovery side, always run fresh: 1, 2, 3...) or literal `0` for X+/Y+ when that touch succeeded at the depth already discovered by its X-/Y- counterpart (macro tries the reused depth first, only falls back to its own fresh ladder on a miss). `TC` (center) rows repurpose `x_minus` for the reading and `y_minus` for sample number. `S` rows are the per-side averages; `C`/`CENTER` rows are the final result.

## Run: 2026-07-15T13:41:23

### T0

**Side averages**

| X− | X+ | Y− | Y+ | Center X | Center Y | X depth (mm) | Y depth (mm) |
|---|---|---|---|---|---|---|---|
| 249.2475 | 251.9850 | 0.4025009 | 3.780002 | 250.6162 | 2.091251 | 0.25 | 0.25 |

**Final result**

| Center X | Center Y | Z result (mm) | Z offset (mm) |
|---|---|---|---|
| 250.6162 | 2.091251 | 5.420000 |  |

### T1

**Side averages**

| X− | X+ | Y− | Y+ | Center X | Center Y | X depth (mm) | Y depth (mm) |
|---|---|---|---|---|---|---|---|
| 249.4130 | 251.8405 | 1.062497 | 2.804999 | 250.6268 | 1.933748 | 0.50 | 0.25 |

**Final result**

| Center X | Center Y | Z result (mm) | Z offset (mm) |
|---|---|---|---|
| 250.6268 | 1.933748 | 5.871500 | 0.4514999 |

### T2

**Side averages**

| X− | X+ | Y− | Y+ | Center X | Center Y | X depth (mm) | Y depth (mm) |
|---|---|---|---|---|---|---|---|
| 248.7500 | 250.5150 | 0.6624985 | 2.840001 | 249.6325 | 1.751250 | 0.50 | 0.50 |

**Final result**

| Center X | Center Y | Z result (mm) | Z offset (mm) |
|---|---|---|---|
| 249.6325 | 1.751250 | 6.194000 | 0.7740002 |

## Run: 2026-07-16T22:42:01

### T0

**X− raw taps**

| Sample | Reading | Depth tried (mm) | Ladder attempt / reused |
|---|---|---|---|
| 1 | 249.137 | 0.25 | attempt 1 (fresh ladder) |
| 2 | 249.150 | 0.25 | attempt 1 (fresh ladder) |
| 3 | 249.150 | 0.25 | attempt 1 (fresh ladder) |
| 4 | 249.150 | 0.25 | attempt 1 (fresh ladder) |
| 5 | 249.150 | 0.25 | attempt 1 (fresh ladder) |

**X+ raw taps**

| Sample | Reading | Depth tried (mm) | Ladder attempt / reused |
|---|---|---|---|
| 1 | 251.900 | 0.25 | reused depth from X− |
| 2 | 251.913 | 0.25 | reused depth from X− |
| 3 | 251.913 | 0.25 | reused depth from X− |
| 4 | 251.913 | 0.25 | reused depth from X− |
| 5 | 251.900 | 0.25 | reused depth from X− |

**Y− raw taps**

| Sample | Reading | Depth tried (mm) | Ladder attempt / reused |
|---|---|---|---|
| 1 | 0.362 | 0.25 | attempt 1 (fresh ladder) |
| 2 | 0.350 | 0.25 | attempt 1 (fresh ladder) |
| 3 | 0.362 | 0.25 | attempt 1 (fresh ladder) |
| 4 | 0.362 | 0.25 | attempt 1 (fresh ladder) |
| 5 | 0.362 | 0.25 | attempt 1 (fresh ladder) |

**Y+ raw taps**

| Sample | Reading | Depth tried (mm) | Ladder attempt / reused |
|---|---|---|---|
| 1 | 3.575 | 0.25 | reused depth from Y− |
| 2 | 3.562 | 0.25 | reused depth from Y− |
| 3 | 3.562 | 0.25 | reused depth from Y− |
| 4 | 3.562 | 0.25 | reused depth from Y− |
| 5 | 3.562 | 0.25 | reused depth from Y− |

**Center Z raw taps**

| Sample | Reading |
|---|---|
| 1 | 5.445 |
| 2 | 5.430 |
| 3 | 5.427 |
| 4 | 5.430 |
| 5 | 5.430 |

**Side averages**

| X− | X+ | Y− | Y+ | Center X | Center Y | X depth (mm) | Y depth (mm) |
|---|---|---|---|---|---|---|---|
| 249.1475 | 251.9075 | 0.3599960 | 3.565001 | 250.5275 | 1.962499 | 0.25 | 0.25 |

**Final result**

| Center X | Center Y | Z result (mm) | Z offset (mm) |
|---|---|---|---|
| 250.5275 | 1.962499 | 5.432500 |  |

### T1

**X− raw taps**

| Sample | Reading | Depth tried (mm) | Ladder attempt / reused |
|---|---|---|---|
| 1 | 249.151 | 0.25 | attempt 1 (fresh ladder) |
| 2 | 249.151 | 0.25 | attempt 1 (fresh ladder) |
| 3 | 249.151 | 0.25 | attempt 1 (fresh ladder) |
| 4 | 249.138 | 0.25 | attempt 1 (fresh ladder) |
| 5 | 249.138 | 0.25 | attempt 1 (fresh ladder) |

**X+ raw taps**

| Sample | Reading | Depth tried (mm) | Ladder attempt / reused |
|---|---|---|---|
| 1 | 251.926 | 0.25 | reused depth from X− |
| 2 | 251.926 | 0.25 | reused depth from X− |
| 3 | 251.913 | 0.25 | reused depth from X− |
| 4 | 251.901 | 0.25 | reused depth from X− |
| 5 | 251.888 | 0.25 | reused depth from X− |

**Y− raw taps**

| Sample | Reading | Depth tried (mm) | Ladder attempt / reused |
|---|---|---|---|
| 1 | 0.187 | 0.25 | attempt 1 (fresh ladder) |
| 2 | 0.188 | 0.25 | attempt 1 (fresh ladder) |
| 3 | 0.175 | 0.25 | attempt 1 (fresh ladder) |
| 4 | 0.175 | 0.25 | attempt 1 (fresh ladder) |
| 5 | 0.175 | 0.25 | attempt 1 (fresh ladder) |

**Y+ raw taps**

| Sample | Reading | Depth tried (mm) | Ladder attempt / reused |
|---|---|---|---|
| 1 | 3.525 | 0.25 | reused depth from Y− |
| 2 | 3.513 | 0.25 | reused depth from Y− |
| 3 | 3.513 | 0.25 | reused depth from Y− |
| 4 | 3.513 | 0.25 | reused depth from Y− |
| 5 | 3.513 | 0.25 | reused depth from Y− |

**Center Z raw taps**

| Sample | Reading |
|---|---|
| 1 | 5.540 |
| 2 | 5.537 |
| 3 | 5.540 |
| 4 | 5.537 |
| 5 | 5.540 |

**Side averages**

| X− | X+ | Y− | Y+ | Center X | Center Y | X depth (mm) | Y depth (mm) |
|---|---|---|---|---|---|---|---|
| 249.1455 | 251.9105 | 0.1800003 | 3.515001 | 250.5280 | 1.847501 | 0.25 | 0.25 |

**Final result**

| Center X | Center Y | Z result (mm) | Z offset (mm) |
|---|---|---|---|
| 250.5280 | 1.847501 | 5.539000 | 0.1065001 |

### T2

**X− raw taps**

| Sample | Reading | Depth tried (mm) | Ladder attempt / reused |
|---|---|---|---|
| 1 | 248.262 | 0.25 | attempt 1 (fresh ladder) |
| 2 | 248.275 | 0.25 | attempt 1 (fresh ladder) |
| 3 | 248.300 | 0.25 | attempt 1 (fresh ladder) |
| 4 | 248.300 | 0.25 | attempt 1 (fresh ladder) |
| 5 | 248.325 | 0.25 | attempt 1 (fresh ladder) |

**X+ raw taps**

| Sample | Reading | Depth tried (mm) | Ladder attempt / reused |
|---|---|---|---|
| 1 | 250.825 | 0.25 | reused depth from X− |
| 2 | 250.812 | 0.25 | reused depth from X− |
| 3 | 250.837 | 0.25 | reused depth from X− |
| 4 | 250.837 | 0.25 | reused depth from X− |
| 5 | 250.825 | 0.25 | reused depth from X− |

**Y− raw taps**

| Sample | Reading | Depth tried (mm) | Ladder attempt / reused |
|---|---|---|---|
| 1 | 0.262 | 0.25 | attempt 1 (fresh ladder) |

*No final result recorded for this tool this run — run was aborted before completion (see readme changelog for the corresponding date).*

## Run: 2026-07-17T07:44:55

### T0

**X− raw taps**

| Sample | Reading | Depth tried (mm) | Ladder attempt / reused |
|---|---|---|---|
| 1 | 249.150 | 0.25 | attempt 1 (fresh ladder) |
| 2 | 249.163 | 0.25 | attempt 1 (fresh ladder) |
| 3 | 249.163 | 0.25 | attempt 1 (fresh ladder) |
| 4 | 249.163 | 0.25 | attempt 1 (fresh ladder) |
| 5 | 249.163 | 0.25 | attempt 1 (fresh ladder) |

**X+ raw taps**

| Sample | Reading | Depth tried (mm) | Ladder attempt / reused |
|---|---|---|---|
| 1 | 251.887 | 0.25 | reused depth from X− |
| 2 | 251.863 | 0.25 | reused depth from X− |
| 3 | 251.863 | 0.25 | reused depth from X− |
| 4 | 251.863 | 0.25 | reused depth from X− |
| 5 | 251.863 | 0.25 | reused depth from X− |

**Y− raw taps**

| Sample | Reading | Depth tried (mm) | Ladder attempt / reused |
|---|---|---|---|
| 1 | 0.400 | 0.25 | attempt 1 (fresh ladder) |
| 2 | 0.400 | 0.25 | attempt 1 (fresh ladder) |
| 3 | 0.400 | 0.25 | attempt 1 (fresh ladder) |
| 4 | 0.412 | 0.25 | attempt 1 (fresh ladder) |
| 5 | 0.400 | 0.25 | attempt 1 (fresh ladder) |

**Y+ raw taps**

| Sample | Reading | Depth tried (mm) | Ladder attempt / reused |
|---|---|---|---|
| 1 | 3.650 | 0.25 | reused depth from Y− |
| 2 | 3.613 | 0.25 | reused depth from Y− |
| 3 | 3.613 | 0.25 | reused depth from Y− |
| 4 | 3.600 | 0.25 | reused depth from Y− |
| 5 | 3.600 | 0.25 | reused depth from Y− |

**Center Z raw taps**

| Sample | Reading |
|---|---|
| 1 | 5.438 |
| 2 | 5.438 |
| 3 | 5.438 |
| 4 | 5.435 |
| 5 | 5.438 |

**Side averages**

| X− | X+ | Y− | Y+ | Center X | Center Y | X depth (mm) | Y depth (mm) |
|---|---|---|---|---|---|---|---|
| 249.1600 | 251.8675 | 0.4025009 | 3.615001 | 250.5137 | 2.008751 | 0.25 | 0.25 |

**Final result**

| Center X | Center Y | Z result (mm) | Z offset (mm) |
|---|---|---|---|
| 250.5137 | 2.008751 | 5.437000 |  |

### T1

**X− raw taps**

| Sample | Reading | Depth tried (mm) | Ladder attempt / reused |
|---|---|---|---|
| 1 | 249.138 | 0.25 | attempt 1 (fresh ladder) |
| 2 | 249.138 | 0.25 | attempt 1 (fresh ladder) |
| 3 | 249.138 | 0.25 | attempt 1 (fresh ladder) |
| 4 | 249.138 | 0.25 | attempt 1 (fresh ladder) |
| 5 | 249.138 | 0.25 | attempt 1 (fresh ladder) |

**X+ raw taps**

| Sample | Reading | Depth tried (mm) | Ladder attempt / reused |
|---|---|---|---|
| 1 | 251.901 | 0.25 | reused depth from X− |
| 2 | 251.888 | 0.25 | reused depth from X− |
| 3 | 251.888 | 0.25 | reused depth from X− |
| 4 | 251.876 | 0.25 | reused depth from X− |
| 5 | 251.888 | 0.25 | reused depth from X− |

**Y− raw taps**

| Sample | Reading | Depth tried (mm) | Ladder attempt / reused |
|---|---|---|---|
| 1 | 0.200 | 0.25 | attempt 1 (fresh ladder) |
| 2 | 0.187 | 0.25 | attempt 1 (fresh ladder) |
| 3 | 0.200 | 0.25 | attempt 1 (fresh ladder) |
| 4 | 0.187 | 0.25 | attempt 1 (fresh ladder) |
| 5 | 0.187 | 0.25 | attempt 1 (fresh ladder) |

**Y+ raw taps**

| Sample | Reading | Depth tried (mm) | Ladder attempt / reused |
|---|---|---|---|
| 1 | 3.538 | 0.25 | reused depth from Y− |
| 2 | 3.525 | 0.25 | reused depth from Y− |
| 3 | 3.513 | 0.25 | reused depth from Y− |
| 4 | 3.513 | 0.25 | reused depth from Y− |
| 5 | 3.513 | 0.25 | reused depth from Y− |

**Center Z raw taps**

| Sample | Reading |
|---|---|
| 1 | 5.557 |
| 2 | 5.560 |
| 3 | 5.560 |
| 4 | 5.560 |
| 5 | 5.562 |

**Side averages**

| X− | X+ | Y− | Y+ | Center X | Center Y | X depth (mm) | Y depth (mm) |
|---|---|---|---|---|---|---|---|
| 249.1380 | 251.8880 | 0.1924973 | 3.520001 | 250.5130 | 1.856249 | 0.25 | 0.25 |

**Final result**

| Center X | Center Y | Z result (mm) | Z offset (mm) |
|---|---|---|---|
| 250.5130 | 1.856249 | 5.560000 | 0.1230001 |

### T2

**X− raw taps**

| Sample | Reading | Depth tried (mm) | Ladder attempt / reused |
|---|---|---|---|
| 1 | 248.300 | 0.25 | attempt 1 (fresh ladder) |
| 2 | 248.275 | 0.25 | attempt 1 (fresh ladder) |
| 3 | 248.275 | 0.25 | attempt 1 (fresh ladder) |
| 4 | 248.300 | 0.25 | attempt 1 (fresh ladder) |
| 5 | 248.288 | 0.25 | attempt 1 (fresh ladder) |

**X+ raw taps**

| Sample | Reading | Depth tried (mm) | Ladder attempt / reused |
|---|---|---|---|
| 1 | 250.812 | 0.25 | reused depth from X− |
| 2 | 250.825 | 0.25 | reused depth from X− |
| 3 | 250.812 | 0.25 | reused depth from X− |
| 4 | 250.812 | 0.25 | reused depth from X− |
| 5 | 250.812 | 0.25 | reused depth from X− |

**Y− raw taps**

| Sample | Reading | Depth tried (mm) | Ladder attempt / reused |
|---|---|---|---|
| 1 | 0.287 | 0.25 | attempt 1 (fresh ladder) |
| 2 | 0.300 | 0.25 | attempt 1 (fresh ladder) |
| 3 | 0.300 | 0.25 | attempt 1 (fresh ladder) |
| 4 | 0.275 | 0.25 | attempt 1 (fresh ladder) |
| 5 | 0.300 | 0.25 | attempt 1 (fresh ladder) |

**Y+ raw taps**

| Sample | Reading | Depth tried (mm) | Ladder attempt / reused |
|---|---|---|---|
| 1 | 3.088 | 0.25 | reused depth from Y− |
| 2 | 3.069 | 0.25 | reused depth from Y− |
| 3 | 3.062 | 0.25 | reused depth from Y− |
| 4 | 3.062 | 0.25 | reused depth from Y− |
| 5 | 3.062 | 0.25 | reused depth from Y− |

**Center Z raw taps**

| Sample | Reading |
|---|---|
| 1 | 5.800 |
| 2 | 5.805 |
| 3 | 5.805 |
| 4 | 5.800 |
| 5 | 5.805 |

**Side averages**

| X− | X+ | Y− | Y+ | Center X | Center Y | X depth (mm) | Y depth (mm) |
|---|---|---|---|---|---|---|---|
| 248.2875 | 250.8150 | 0.2925018 | 3.068750 | 249.5512 | 1.680626 | 0.25 | 0.25 |

**Final result**

| Center X | Center Y | Z result (mm) | Z offset (mm) |
|---|---|---|---|
| 249.5512 | 1.680626 | 5.803000 | 0.3660002 |

## Run: 2026-07-17T10:11:24

### T0

**X− raw taps**

| Sample | Reading | Depth tried (mm) | Ladder attempt / reused |
|---|---|---|---|
| 1 | 249.125 | 0.25 | attempt 1 (fresh ladder) |
| 2 | 249.113 | 0.25 | attempt 1 (fresh ladder) |
| 3 | 249.137 | 0.25 | attempt 1 (fresh ladder) |
| 4 | 249.137 | 0.25 | attempt 1 (fresh ladder) |
| 5 | 249.137 | 0.25 | attempt 1 (fresh ladder) |

**X+ raw taps**

| Sample | Reading | Depth tried (mm) | Ladder attempt / reused |
|---|---|---|---|
| 1 | 251.913 | 0.25 | reused depth from X− |
| 2 | 251.900 | 0.25 | reused depth from X− |
| 3 | 251.887 | 0.25 | reused depth from X− |
| 4 | 251.887 | 0.25 | reused depth from X− |
| 5 | 251.900 | 0.25 | reused depth from X− |

**Y− raw taps**

| Sample | Reading | Depth tried (mm) | Ladder attempt / reused |
|---|---|---|---|
| 1 | 0.400 | 0.25 | attempt 1 (fresh ladder) |
| 2 | 0.375 | 0.25 | attempt 1 (fresh ladder) |
| 3 | 0.375 | 0.25 | attempt 1 (fresh ladder) |
| 4 | 0.375 | 0.25 | attempt 1 (fresh ladder) |
| 5 | 0.375 | 0.25 | attempt 1 (fresh ladder) |

**Y+ raw taps**

| Sample | Reading | Depth tried (mm) | Ladder attempt / reused |
|---|---|---|---|
| 1 | 3.625 | 0.25 | reused depth from Y− |
| 2 | 3.625 | 0.25 | reused depth from Y− |
| 3 | 3.613 | 0.25 | reused depth from Y− |
| 4 | 3.600 | 0.25 | reused depth from Y− |
| 5 | 3.600 | 0.25 | reused depth from Y− |

**Center Z raw taps**

| Sample | Reading |
|---|---|
| 1 | 5.430 |
| 2 | 5.430 |
| 3 | 5.432 |
| 4 | 5.430 |
| 5 | 5.435 |

**Side averages**

| X− | X+ | Y− | Y+ | Center X | Center Y | X depth (mm) | Y depth (mm) |
|---|---|---|---|---|---|---|---|
| 249.1300 | 251.8975 | 0.3800003 | 3.612500 | 250.5138 | 1.996250 | 0.25 | 0.25 |

**Final result**

| Center X | Center Y | Z result (mm) | Z offset (mm) |
|---|---|---|---|
| 250.5138 | 1.996250 | 5.431500 |  |

### T1

**X− raw taps**

| Sample | Reading | Depth tried (mm) | Ladder attempt / reused |
|---|---|---|---|
| 1 | 249.138 | 0.25 | attempt 1 (fresh ladder) |
| 2 | 249.126 | 0.25 | attempt 1 (fresh ladder) |
| 3 | 249.138 | 0.25 | attempt 1 (fresh ladder) |
| 4 | 249.126 | 0.25 | attempt 1 (fresh ladder) |
| 5 | 249.126 | 0.25 | attempt 1 (fresh ladder) |

**X+ raw taps**

| Sample | Reading | Depth tried (mm) | Ladder attempt / reused |
|---|---|---|---|
| 1 | 251.901 | 0.25 | reused depth from X− |
| 2 | 251.888 | 0.25 | reused depth from X− |
| 3 | 251.888 | 0.25 | reused depth from X− |
| 4 | 251.888 | 0.25 | reused depth from X− |
| 5 | 251.888 | 0.25 | reused depth from X− |

**Y− raw taps**

| Sample | Reading | Depth tried (mm) | Ladder attempt / reused |
|---|---|---|---|
| 1 | 0.200 | 0.25 | attempt 1 (fresh ladder) |
| 2 | 0.187 | 0.25 | attempt 1 (fresh ladder) |
| 3 | 0.200 | 0.25 | attempt 1 (fresh ladder) |
| 4 | 0.200 | 0.25 | attempt 1 (fresh ladder) |
| 5 | 0.187 | 0.25 | attempt 1 (fresh ladder) |

**Y+ raw taps**

| Sample | Reading | Depth tried (mm) | Ladder attempt / reused |
|---|---|---|---|
| 1 | 3.513 | 0.25 | reused depth from Y− |
| 2 | 3.513 | 0.25 | reused depth from Y− |
| 3 | 3.500 | 0.25 | reused depth from Y− |
| 4 | 3.500 | 0.25 | reused depth from Y− |
| 5 | 3.500 | 0.25 | reused depth from Y− |

**Center Z raw taps**

| Sample | Reading |
|---|---|
| 1 | 5.548 |
| 2 | 5.548 |
| 3 | 5.548 |
| 4 | 5.565 |
| 5 | 5.548 |

**Side averages**

| X− | X+ | Y− | Y+ | Center X | Center Y | X depth (mm) | Y depth (mm) |
|---|---|---|---|---|---|---|---|
| 249.1305 | 251.8905 | 0.1949982 | 3.504999 | 250.5105 | 1.849998 | 0.25 | 0.25 |

**Final result**

| Center X | Center Y | Z result (mm) | Z offset (mm) |
|---|---|---|---|
| 250.5105 | 1.849998 | 5.551000 | 0.1195002 |

### T2

**X− raw taps**

| Sample | Reading | Depth tried (mm) | Ladder attempt / reused |
|---|---|---|---|
| 1 | 248.275 | 0.25 | attempt 1 (fresh ladder) |
| 2 | 248.288 | 0.25 | attempt 1 (fresh ladder) |
| 3 | 248.238 | 0.25 | attempt 1 (fresh ladder) |
| 4 | 248.300 | 0.25 | attempt 1 (fresh ladder) |
| 5 | 248.300 | 0.25 | attempt 1 (fresh ladder) |

**X+ raw taps**

| Sample | Reading | Depth tried (mm) | Ladder attempt / reused |
|---|---|---|---|
| 1 | 250.825 | 0.25 | reused depth from X− |
| 2 | 250.812 | 0.25 | reused depth from X− |
| 3 | 250.812 | 0.25 | reused depth from X− |
| 4 | 250.837 | 0.25 | reused depth from X− |
| 5 | 250.812 | 0.25 | reused depth from X− |

**Y− raw taps**

| Sample | Reading | Depth tried (mm) | Ladder attempt / reused |
|---|---|---|---|
| 1 | 0.225 | 0.25 | attempt 1 (fresh ladder) |
| 2 | 0.250 | 0.25 | attempt 1 (fresh ladder) |
| 3 | 0.262 | 0.25 | attempt 1 (fresh ladder) |
| 4 | 0.250 | 0.25 | attempt 1 (fresh ladder) |
| 5 | 0.275 | 0.25 | attempt 1 (fresh ladder) |

**Y+ raw taps**

| Sample | Reading | Depth tried (mm) | Ladder attempt / reused |
|---|---|---|---|
| 1 | 3.050 | 0.25 | reused depth from Y− |
| 2 | 3.037 | 0.25 | reused depth from Y− |
| 3 | 3.062 | 0.25 | reused depth from Y− |
| 4 | 3.012 | 0.25 | reused depth from Y− |
| 5 | 3.012 | 0.25 | reused depth from Y− |

**Center Z raw taps**

| Sample | Reading |
|---|---|
| 1 | 5.782 |
| 2 | 5.782 |
| 3 | 5.798 |
| 4 | 5.785 |
| 5 | 5.785 |

**Side averages**

| X− | X+ | Y− | Y+ | Center X | Center Y | X depth (mm) | Y depth (mm) |
|---|---|---|---|---|---|---|---|
| 248.2800 | 250.8200 | 0.2524994 | 3.034999 | 249.5500 | 1.643749 | 0.25 | 0.25 |

**Final result**

| Center X | Center Y | Z result (mm) | Z offset (mm) |
|---|---|---|---|
| 249.5500 | 1.643749 | 5.786500 | 0.3550000 |
