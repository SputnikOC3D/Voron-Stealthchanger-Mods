; Per-tool Z-offset calibration via N/S/E/W probing against the SEX-Z-Nipple
; pin. See sex-z-nipple.readme.md in this folder for design rationale, tuning-constant
; provenance, and dated bug/fix history - this file intentionally carries
; only short in-place comments, not the full paper trail.

if !move.axes[0].homed || !move.axes[1].homed || !move.axes[2].homed
    abort "Axes not homed. Calibration aborted."

; --- Startup: discover current tool, get T0 on the shuttle ---
M98 P"0:/macros/05_discover_tool.g"

if state.currentTool != -1 && state.currentTool != 0
    M291 P{"Current tool is T" ^ state.currentTool ^ ". This probing sequence needs to start with T0 - approve dropping T" ^ state.currentTool ^ " and picking up T0?"} R"Calibrate_ZOff_Tool_NSEW - initial tool change" S3

if move.axes[2].userPosition < 15
    G53 G1 Z15 F2400
if state.currentTool == -1
    G53 G1 Y{global.dock_safe_y_empty} F{global.speed_xy_fast}
else
    G53 G1 Y{global.dock_safe_y_loaded} F{global.speed_xy_fast}

T0
G4 P1000
if state.currentTool == -1
    abort "Calibration aborted: could not get T0 onto the shuttle (pickup failed or no tool available)."

; --- Tuning constants (see sex-z-nipple.readme.md, section: Tuning constants, for provenance of each) ---
; -------------------------
var safe_z 			= 15		; safe Z post tool change traverse height
var approach_z 		= 10		; drops z down to here to touch probe in vert Z
var probe_x 		= 250		; Sex-Z-Nipples X axis coordinate
var probe_y 		= 1			; Sex-Z-Nipples Y axis coordinate
var spread 			= 4			; mm outward from pin before probing back inward (N/S/E/W approach distance)
var nsew_drop_z 	= 0.25		; mm below pin's measured top for the first N/S/E/W touch attempt
var lift_z 			= 4.0		; Z clearance when traversing between N/S/E/W touches
var final_lift_z 	= 4.0		; park height above final measured Z once a tool's routine is done
var traverse_speed 	= 1200		; mm/min for non-probing X/Y moves (=20mm/s)
var probe_samples 	= 5			; touches taken and averaged per side/center, always in full
var probe_retract 	= 2			; mm retract for vertical G30 center-touch retries only
var nsew_retract 	= 4			; mm retract for horizontal G38.2 touch retries only
; ------------------------

if !fileexists("0:/sys/zoff_nsew_log.csv")
    echo >>"0:/sys/zoff_nsew_log.csv" "timestamp,tool,phase,x_minus,x_plus,y_minus,y_plus,center_x,center_y,z_result,z_offset,nsew_x_depth,nsew_y_depth"

; --- STEP 0 (disabled) - one-time Z reference check, re-enable if the build
; plate changes (protrusion height varies 2-3mm by plate). See sex-z-nipple.readme.md. ---
; T0
; G4 P1000
; if state.currentTool == -1
;     abort "Calibration aborted: no tool attached after T0 - cannot probe the pin with nothing on the shuttle."
; G53 G1 Z{var.safe_z} F6000
; G53 G1 X{var.probe_x} Y10 F15000
; G53 G1 Y{var.probe_y} F2000
; G53 G1 Z{var.approach_z} F2000
;
; G30 K1 S-1
; var z_reference = move.axes[2].userPosition
; M118 P0 S{"Pin Z ref = " ^ var.z_reference ^ " (expect positive, near pin height)"}
; M118 P0 S"VERIFY above before continuing; comment out Step 0 once trusted"
; G53 G1 Z{var.z_reference + var.lift_z} F2000

; --- Shared working variables (declared once, reset via 'set' per tool/touch) ---
; -------------------------
var rough_z 			= 0			; each tool's freshly-measured rough Z, before NSEW starts
var x_minus 		= 0			; X- side's averaged touch result
var x_plus 			= 0			; X+ side's averaged touch result
var center_x 		= 0			; true center X, averaged from x_minus/x_plus
var y_minus 		= 0			; Y- side's averaged touch result
var y_plus 			= 0			; Y+ side's averaged touch result
var center_y 		= 0			; true center Y, averaged from y_minus/y_plus
var sample_sum 		= 0			; scratch accumulator for the current multi-sample loop
var sample_count 	= 0			; scratch counter for the current multi-sample loop
var sample_reading 	= 0			; the current single tap's reading
var nsew_max_attempts 	= 3			; max depth-discovery ladder rungs before hard abort (fixed, not tunable)
var nsew_attempt 	= 1			; current ladder attempt number (1-based)
var nsew_depth 		= 0			; depth below rough_z currently being tried
var nsew_miss 		= true		; true = current touch swept full distance without triggering (genuine miss)
var x_depth 		= 0			; depth X- actually succeeded at, reused as X+'s first attempt
var y_depth 		= 0			; depth Y- actually succeeded at, reused as Y+'s first attempt
var run_time 		= state.time	; shared timestamp for this run, captured once, used on every CSV row
; ------------------------

; ===== T0 MASTER (reference measurement) - see sex-z-nipple.readme.md sections
; "The algorithm" and "Key design decisions" for why this block is shaped
; the way it is (per-axis depth discovery, multi-sampling, stale-offset
; clear). T1/T2 below repeat this exact pattern. =====
T0
G4 P1000
if state.currentTool == -1
    abort "Calibration aborted: T0 pickup failed, nothing on the shuttle."
G10 P0 Z0
M118 P0 S"Locating SEX-Z-Nipple center for T0 (master)..."
G53 G1 Z{var.safe_z} F6000
G53 G1 X{var.probe_x} Y10 F15000
G53 G1 Y{var.probe_y} F2000
G53 G1 Z{var.approach_z} F2000
G30 K1 S-1
set var.rough_z = move.axes[2].userPosition


; ===== X- : depth-discovery ladder for the X axis =====
set var.nsew_attempt = 1
set var.nsew_miss = true
while var.nsew_miss && var.nsew_attempt <= var.nsew_max_attempts
    set var.nsew_miss = false
    set var.nsew_depth = var.nsew_drop_z * var.nsew_attempt
    M118 P0 S{"T0 X- discovery attempt " ^ var.nsew_attempt ^ "/" ^ var.nsew_max_attempts ^ ", depth=" ^ var.nsew_depth ^ "mm"}
    G53 G1 Z{var.rough_z + var.lift_z} F2000
    G53 G1 X{var.probe_x - var.spread} Y{var.probe_y} F{var.traverse_speed}
    G53 G1 Z{var.rough_z - var.nsew_depth} F600
    set var.sample_sum = 0
    set var.sample_count = 0
    while var.sample_count < var.probe_samples
        G38.2 K1 X{var.probe_x + var.spread} F240
        if result >= 2
            ; position tells apart the two failure modes: closer to this
            ; touch's START coord = already triggered before moving (hard
            ; abort, retrying deeper would be backwards); closer to TARGET =
            ; swept the full distance without contact (a genuine miss, retry
            ; deeper below). Same check repeats unmarked at every other
            ; X-/X+/Y-/Y+ touch in this file - see sex-z-nipple.readme.md "Key design
            ; decisions" for the full derivation.
            if abs(move.axes[0].userPosition - (var.probe_x - var.spread)) < abs(move.axes[0].userPosition - (var.probe_x + var.spread))
                G53 G1 Z{var.safe_z} F6000
                abort "Calibration aborted: T0 X- touch failed (probe already triggered at start) - see console."
            M118 P0 S{"T0 X- MISS attempt " ^ var.nsew_attempt ^ " depth " ^ var.nsew_depth ^ "mm"}
            set var.nsew_miss = true
            break
        set var.sample_reading = move.axes[0].userPosition
        echo >>"0:/sys/zoff_nsew_log.csv" var.run_time ^ "," ^ "T0" ^ "," ^ "TX-" ^ "," ^ var.sample_reading ^ "," ^ var.nsew_attempt ^ "," ^ (var.sample_count + 1) ^ "," ^ var.nsew_depth ^ ",,,,,,"
        set var.sample_sum = var.sample_sum + var.sample_reading
        set var.sample_count = var.sample_count + 1
        if var.sample_count < var.probe_samples
            ; retract clear of the switch, then return to this touch's start
            ; (unmarked repeat elsewhere in this file - same pattern every time)
            G53 G1 X{move.axes[0].userPosition - var.nsew_retract} F{var.traverse_speed}
            G53 G1 X{var.probe_x - var.spread} Y{var.probe_y} F{var.traverse_speed}
    if !var.nsew_miss
        set var.x_minus = var.sample_sum / var.sample_count
        M118 P0 S{"T0 X- done: " ^ var.x_minus ^ " (" ^ var.sample_count ^ "x, depth " ^ var.nsew_depth ^ "mm)"}
    set var.nsew_attempt = var.nsew_attempt + 1
if var.nsew_miss
    G53 G1 Z{var.safe_z} F6000
    abort "Calibration aborted: T0 X- never made contact after " ^ var.nsew_max_attempts ^ " attempts (deepest tried " ^ (var.nsew_drop_z * var.nsew_max_attempts) ^ "mm) - see console."
set var.x_depth = var.nsew_depth

; ===== X+ : try discovered X depth first, fall back to its own ladder only if that misses =====
set var.nsew_depth = var.x_depth
set var.nsew_miss = false
M118 P0 S{"T0 X+ trying X depth " ^ var.nsew_depth ^ "mm (reused from X-)"}
G53 G1 Z{var.rough_z + var.lift_z} F2000
G53 G1 X{var.probe_x + var.spread} Y{var.probe_y} F{var.traverse_speed}
G53 G1 Z{var.rough_z - var.nsew_depth} F600
set var.sample_sum = 0
set var.sample_count = 0
while var.sample_count < var.probe_samples
    G38.2 K1 X{var.probe_x - var.spread} F240
    if result >= 2
        if abs(move.axes[0].userPosition - (var.probe_x + var.spread)) < abs(move.axes[0].userPosition - (var.probe_x - var.spread))
            G53 G1 Z{var.safe_z} F6000
            abort "Calibration aborted: T0 X+ touch failed (probe already triggered at start) - see console."
        M118 P0 S{"T0 X+ MISS at reused X depth " ^ var.nsew_depth ^ "mm - falling back to own ladder"}
        set var.nsew_miss = true
        break
    set var.sample_reading = move.axes[0].userPosition
    echo >>"0:/sys/zoff_nsew_log.csv" var.run_time ^ "," ^ "T0" ^ "," ^ "TX+" ^ "," ^ var.sample_reading ^ "," ^ 0 ^ "," ^ (var.sample_count + 1) ^ "," ^ var.nsew_depth ^ ",,,,,,"
    set var.sample_sum = var.sample_sum + var.sample_reading
    set var.sample_count = var.sample_count + 1
    if var.sample_count < var.probe_samples
        G53 G1 X{move.axes[0].userPosition + var.nsew_retract} F{var.traverse_speed}
        G53 G1 X{var.probe_x + var.spread} Y{var.probe_y} F{var.traverse_speed}
if !var.nsew_miss
    set var.x_plus = var.sample_sum / var.sample_count
    M118 P0 S{"T0 X+ done: " ^ var.x_plus ^ " (" ^ var.sample_count ^ "x, depth " ^ var.nsew_depth ^ "mm, reused)"}
if var.nsew_miss
    set var.nsew_attempt = 1
    set var.nsew_miss = true
    while var.nsew_miss && var.nsew_attempt <= var.nsew_max_attempts
        set var.nsew_miss = false
        set var.nsew_depth = var.nsew_drop_z * var.nsew_attempt
        M118 P0 S{"T0 X+ own-ladder attempt " ^ var.nsew_attempt ^ "/" ^ var.nsew_max_attempts ^ ", depth=" ^ var.nsew_depth ^ "mm"}
        G53 G1 Z{var.rough_z + var.lift_z} F2000
        G53 G1 X{var.probe_x + var.spread} Y{var.probe_y} F{var.traverse_speed}
        G53 G1 Z{var.rough_z - var.nsew_depth} F600
        set var.sample_sum = 0
        set var.sample_count = 0
        while var.sample_count < var.probe_samples
            G38.2 K1 X{var.probe_x - var.spread} F240
            if result >= 2
                if abs(move.axes[0].userPosition - (var.probe_x + var.spread)) < abs(move.axes[0].userPosition - (var.probe_x - var.spread))
                    G53 G1 Z{var.safe_z} F6000
                    abort "Calibration aborted: T0 X+ touch failed (probe already triggered at start) - see console."
                M118 P0 S{"T0 X+ MISS attempt " ^ var.nsew_attempt ^ " depth " ^ var.nsew_depth ^ "mm"}
                set var.nsew_miss = true
                break
            set var.sample_reading = move.axes[0].userPosition
            echo >>"0:/sys/zoff_nsew_log.csv" var.run_time ^ "," ^ "T0" ^ "," ^ "TX+" ^ "," ^ var.sample_reading ^ "," ^ var.nsew_attempt ^ "," ^ (var.sample_count + 1) ^ "," ^ var.nsew_depth ^ ",,,,,,"
            set var.sample_sum = var.sample_sum + var.sample_reading
            set var.sample_count = var.sample_count + 1
            if var.sample_count < var.probe_samples
                G53 G1 X{move.axes[0].userPosition + var.nsew_retract} F{var.traverse_speed}
                G53 G1 X{var.probe_x + var.spread} Y{var.probe_y} F{var.traverse_speed}
        if !var.nsew_miss
            set var.x_plus = var.sample_sum / var.sample_count
            M118 P0 S{"T0 X+ done: " ^ var.x_plus ^ " (" ^ var.sample_count ^ "x, depth " ^ var.nsew_depth ^ "mm, own ladder)"}
        set var.nsew_attempt = var.nsew_attempt + 1
    if var.nsew_miss
        G53 G1 Z{var.safe_z} F6000
        abort "Calibration aborted: T0 X+ never made contact after own ladder of " ^ var.nsew_max_attempts ^ " attempts (deepest tried " ^ (var.nsew_drop_z * var.nsew_max_attempts) ^ "mm) - see console."

set var.center_x = (var.x_minus + var.x_plus) / 2

; ===== Y- : depth-discovery ladder for the Y axis =====
set var.nsew_attempt = 1
set var.nsew_miss = true
while var.nsew_miss && var.nsew_attempt <= var.nsew_max_attempts
    set var.nsew_miss = false
    set var.nsew_depth = var.nsew_drop_z * var.nsew_attempt
    M118 P0 S{"T0 Y- discovery attempt " ^ var.nsew_attempt ^ "/" ^ var.nsew_max_attempts ^ ", depth=" ^ var.nsew_depth ^ "mm"}
    G53 G1 Z{var.rough_z + var.lift_z} F2000
    G53 G1 X{var.center_x} Y{var.probe_y - var.spread} F{var.traverse_speed}
    G53 G1 Z{var.rough_z - var.nsew_depth} F600
    set var.sample_sum = 0
    set var.sample_count = 0
    while var.sample_count < var.probe_samples
        G38.2 K1 Y{var.probe_y + var.spread} F240
        if result >= 2
            if abs(move.axes[1].userPosition - (var.probe_y - var.spread)) < abs(move.axes[1].userPosition - (var.probe_y + var.spread))
                G53 G1 Z{var.safe_z} F6000
                abort "Calibration aborted: T0 Y- touch failed (probe already triggered at start) - see console."
            M118 P0 S{"T0 Y- MISS attempt " ^ var.nsew_attempt ^ " depth " ^ var.nsew_depth ^ "mm"}
            set var.nsew_miss = true
            break
        set var.sample_reading = move.axes[1].userPosition
        echo >>"0:/sys/zoff_nsew_log.csv" var.run_time ^ "," ^ "T0" ^ "," ^ "TY-" ^ "," ^ var.sample_reading ^ "," ^ var.nsew_attempt ^ "," ^ (var.sample_count + 1) ^ "," ^ var.nsew_depth ^ ",,,,,,"
        set var.sample_sum = var.sample_sum + var.sample_reading
        set var.sample_count = var.sample_count + 1
        if var.sample_count < var.probe_samples
            G53 G1 Y{move.axes[1].userPosition - var.nsew_retract} F{var.traverse_speed}
            G53 G1 X{var.center_x} Y{var.probe_y - var.spread} F{var.traverse_speed}
    if !var.nsew_miss
        set var.y_minus = var.sample_sum / var.sample_count
        M118 P0 S{"T0 Y- done: " ^ var.y_minus ^ " (" ^ var.sample_count ^ "x, depth " ^ var.nsew_depth ^ "mm)"}
    set var.nsew_attempt = var.nsew_attempt + 1
if var.nsew_miss
    G53 G1 Z{var.safe_z} F6000
    abort "Calibration aborted: T0 Y- never made contact after " ^ var.nsew_max_attempts ^ " attempts (deepest tried " ^ (var.nsew_drop_z * var.nsew_max_attempts) ^ "mm) - see console."
set var.y_depth = var.nsew_depth

; ===== Y+ : try discovered Y depth first, fall back to its own ladder only if that misses =====
set var.nsew_depth = var.y_depth
set var.nsew_miss = false
M118 P0 S{"T0 Y+ trying Y depth " ^ var.nsew_depth ^ "mm (reused from Y-)"}
G53 G1 Z{var.rough_z + var.lift_z} F2000
G53 G1 X{var.center_x} Y{var.probe_y + var.spread} F{var.traverse_speed}
G53 G1 Z{var.rough_z - var.nsew_depth} F600
set var.sample_sum = 0
set var.sample_count = 0
while var.sample_count < var.probe_samples
    G38.2 K1 Y{var.probe_y - var.spread} F240
    if result >= 2
        if abs(move.axes[1].userPosition - (var.probe_y + var.spread)) < abs(move.axes[1].userPosition - (var.probe_y - var.spread))
            G53 G1 Z{var.safe_z} F6000
            abort "Calibration aborted: T0 Y+ touch failed (probe already triggered at start) - see console."
        M118 P0 S{"T0 Y+ MISS at reused Y depth " ^ var.nsew_depth ^ "mm - falling back to own ladder"}
        set var.nsew_miss = true
        break
    set var.sample_reading = move.axes[1].userPosition
    echo >>"0:/sys/zoff_nsew_log.csv" var.run_time ^ "," ^ "T0" ^ "," ^ "TY+" ^ "," ^ var.sample_reading ^ "," ^ 0 ^ "," ^ (var.sample_count + 1) ^ "," ^ var.nsew_depth ^ ",,,,,,"
    set var.sample_sum = var.sample_sum + var.sample_reading
    set var.sample_count = var.sample_count + 1
    if var.sample_count < var.probe_samples
        G53 G1 Y{move.axes[1].userPosition + var.nsew_retract} F{var.traverse_speed}
        G53 G1 X{var.center_x} Y{var.probe_y + var.spread} F{var.traverse_speed}
if !var.nsew_miss
    set var.y_plus = var.sample_sum / var.sample_count
    M118 P0 S{"T0 Y+ done: " ^ var.y_plus ^ " (" ^ var.sample_count ^ "x, depth " ^ var.nsew_depth ^ "mm, reused)"}
if var.nsew_miss
    set var.nsew_attempt = 1
    set var.nsew_miss = true
    while var.nsew_miss && var.nsew_attempt <= var.nsew_max_attempts
        set var.nsew_miss = false
        set var.nsew_depth = var.nsew_drop_z * var.nsew_attempt
        M118 P0 S{"T0 Y+ own-ladder attempt " ^ var.nsew_attempt ^ "/" ^ var.nsew_max_attempts ^ ", depth=" ^ var.nsew_depth ^ "mm"}
        G53 G1 Z{var.rough_z + var.lift_z} F2000
        G53 G1 X{var.center_x} Y{var.probe_y + var.spread} F{var.traverse_speed}
        G53 G1 Z{var.rough_z - var.nsew_depth} F600
        set var.sample_sum = 0
        set var.sample_count = 0
        while var.sample_count < var.probe_samples
            G38.2 K1 Y{var.probe_y - var.spread} F240
            if result >= 2
                if abs(move.axes[1].userPosition - (var.probe_y + var.spread)) < abs(move.axes[1].userPosition - (var.probe_y - var.spread))
                    G53 G1 Z{var.safe_z} F6000
                    abort "Calibration aborted: T0 Y+ touch failed (probe already triggered at start) - see console."
                M118 P0 S{"T0 Y+ MISS attempt " ^ var.nsew_attempt ^ " depth " ^ var.nsew_depth ^ "mm"}
                set var.nsew_miss = true
                break
            set var.sample_reading = move.axes[1].userPosition
            echo >>"0:/sys/zoff_nsew_log.csv" var.run_time ^ "," ^ "T0" ^ "," ^ "TY+" ^ "," ^ var.sample_reading ^ "," ^ var.nsew_attempt ^ "," ^ (var.sample_count + 1) ^ "," ^ var.nsew_depth ^ ",,,,,,"
            set var.sample_sum = var.sample_sum + var.sample_reading
            set var.sample_count = var.sample_count + 1
            if var.sample_count < var.probe_samples
                G53 G1 Y{move.axes[1].userPosition + var.nsew_retract} F{var.traverse_speed}
                G53 G1 X{var.center_x} Y{var.probe_y + var.spread} F{var.traverse_speed}
        if !var.nsew_miss
            set var.y_plus = var.sample_sum / var.sample_count
            M118 P0 S{"T0 Y+ done: " ^ var.y_plus ^ " (" ^ var.sample_count ^ "x, depth " ^ var.nsew_depth ^ "mm, own ladder)"}
        set var.nsew_attempt = var.nsew_attempt + 1
    if var.nsew_miss
        G53 G1 Z{var.safe_z} F6000
        abort "Calibration aborted: T0 Y+ never made contact after own ladder of " ^ var.nsew_max_attempts ^ " attempts (deepest tried " ^ (var.nsew_drop_z * var.nsew_max_attempts) ^ "mm) - see console."

set var.center_y = (var.y_minus + var.y_plus) / 2

G53 G1 Z{var.rough_z + var.lift_z} F2000

echo >>"0:/sys/zoff_nsew_log.csv" var.run_time ^ "," ^ "T0" ^ "," ^ "S" ^ "," ^ var.x_minus ^ "," ^ var.x_plus ^ "," ^ var.y_minus ^ "," ^ var.y_plus ^ "," ^ var.center_x ^ "," ^ var.center_y ^ ",," ^ var.x_depth ^ "," ^ var.y_depth

G53 G1 X{var.center_x} Y{var.center_y} F{var.traverse_speed}

set var.sample_sum = 0
set var.sample_count = 0
while var.sample_count < var.probe_samples
    G30 K1 S-1
    set var.sample_reading = move.axes[2].userPosition
    echo >>"0:/sys/zoff_nsew_log.csv" var.run_time ^ "," ^ "T0" ^ "," ^ "TC" ^ "," ^ var.sample_reading ^ ",," ^ (var.sample_count + 1) ^ ",,,,,,,"
    set var.sample_sum = var.sample_sum + var.sample_reading
    set var.sample_count = var.sample_count + 1
    if var.sample_count < var.probe_samples
        G53 G1 Z{move.axes[2].userPosition + var.probe_retract} F2000
var master_z = var.sample_sum / var.sample_count
M118 P0 S{"T0 CENTER done: " ^ var.master_z ^ " (" ^ var.sample_count ^ "x)"}
var master_x = var.center_x
var master_y = var.center_y

G53 G1 Z{var.final_lift_z + var.master_z} F2000

echo >>"0:/sys/zoff_nsew_log.csv" var.run_time ^ "," ^ "T0" ^ "," ^ "C,,,,," ^ var.center_x ^ "," ^ var.center_y ^ "," ^ var.master_z ^ ","

M118 P0 S{"T0 reference: X=" ^ var.master_x ^ " Y=" ^ var.master_y ^ " Z=" ^ var.master_z}

M291 P{"T0 reference established: Z=" ^ var.master_z ^ ". Review the result above, then click OK to continue to T1."} R"Calibrate_ZOff_Tool_NSEW - T0 done" S2

; ===== T1 CALIBRATION - identical pattern to T0's block above, tool label
; swapped. See sex-z-nipple.readme.md "The algorithm" / "Key design decisions". =====
G53 G1 Z{var.safe_z} F6000
T1
G4 P1000
if state.currentTool == -1
    abort "Calibration aborted: T1 pickup failed, nothing on the shuttle."
G10 P1 Z0
M118 P0 S"Locating SEX-Z-Nipple center for T1..."
G53 G1 X{var.probe_x} Y10 F15000
G53 G1 Y{var.probe_y} F2000
G53 G1 Z{var.approach_z} F2000
G30 K1 S-1
set var.rough_z = move.axes[2].userPosition


; ===== X- : depth-discovery ladder for the X axis =====
set var.nsew_attempt = 1
set var.nsew_miss = true
while var.nsew_miss && var.nsew_attempt <= var.nsew_max_attempts
    set var.nsew_miss = false
    set var.nsew_depth = var.nsew_drop_z * var.nsew_attempt
    M118 P0 S{"T1 X- discovery attempt " ^ var.nsew_attempt ^ "/" ^ var.nsew_max_attempts ^ ", depth=" ^ var.nsew_depth ^ "mm"}
    G53 G1 Z{var.rough_z + var.lift_z} F2000
    G53 G1 X{var.probe_x - var.spread} Y{var.probe_y} F{var.traverse_speed}
    G53 G1 Z{var.rough_z - var.nsew_depth} F600
    set var.sample_sum = 0
    set var.sample_count = 0
    while var.sample_count < var.probe_samples
        G38.2 K1 X{var.probe_x + var.spread} F240
        if result >= 2
            if abs(move.axes[0].userPosition - (var.probe_x - var.spread)) < abs(move.axes[0].userPosition - (var.probe_x + var.spread))
                G53 G1 Z{var.safe_z} F6000
                abort "Calibration aborted: T1 X- touch failed (probe already triggered at start) - see console."
            M118 P0 S{"T1 X- MISS attempt " ^ var.nsew_attempt ^ " depth " ^ var.nsew_depth ^ "mm"}
            set var.nsew_miss = true
            break
        set var.sample_reading = move.axes[0].userPosition
        echo >>"0:/sys/zoff_nsew_log.csv" var.run_time ^ "," ^ "T1" ^ "," ^ "TX-" ^ "," ^ var.sample_reading ^ "," ^ var.nsew_attempt ^ "," ^ (var.sample_count + 1) ^ "," ^ var.nsew_depth ^ ",,,,,,"
        set var.sample_sum = var.sample_sum + var.sample_reading
        set var.sample_count = var.sample_count + 1
        if var.sample_count < var.probe_samples
            G53 G1 X{move.axes[0].userPosition - var.nsew_retract} F{var.traverse_speed}
            G53 G1 X{var.probe_x - var.spread} Y{var.probe_y} F{var.traverse_speed}
    if !var.nsew_miss
        set var.x_minus = var.sample_sum / var.sample_count
        M118 P0 S{"T1 X- done: " ^ var.x_minus ^ " (" ^ var.sample_count ^ "x, depth " ^ var.nsew_depth ^ "mm)"}
    set var.nsew_attempt = var.nsew_attempt + 1
if var.nsew_miss
    G53 G1 Z{var.safe_z} F6000
    abort "Calibration aborted: T1 X- never made contact after " ^ var.nsew_max_attempts ^ " attempts (deepest tried " ^ (var.nsew_drop_z * var.nsew_max_attempts) ^ "mm) - see console."
set var.x_depth = var.nsew_depth

; ===== X+ : try discovered X depth first, fall back to its own ladder only if that misses =====
set var.nsew_depth = var.x_depth
set var.nsew_miss = false
M118 P0 S{"T1 X+ trying X depth " ^ var.nsew_depth ^ "mm (reused from X-)"}
G53 G1 Z{var.rough_z + var.lift_z} F2000
G53 G1 X{var.probe_x + var.spread} Y{var.probe_y} F{var.traverse_speed}
G53 G1 Z{var.rough_z - var.nsew_depth} F600
set var.sample_sum = 0
set var.sample_count = 0
while var.sample_count < var.probe_samples
    G38.2 K1 X{var.probe_x - var.spread} F240
    if result >= 2
        if abs(move.axes[0].userPosition - (var.probe_x + var.spread)) < abs(move.axes[0].userPosition - (var.probe_x - var.spread))
            G53 G1 Z{var.safe_z} F6000
            abort "Calibration aborted: T1 X+ touch failed (probe already triggered at start) - see console."
        M118 P0 S{"T1 X+ MISS at reused X depth " ^ var.nsew_depth ^ "mm - falling back to own ladder"}
        set var.nsew_miss = true
        break
    set var.sample_reading = move.axes[0].userPosition
    echo >>"0:/sys/zoff_nsew_log.csv" var.run_time ^ "," ^ "T1" ^ "," ^ "TX+" ^ "," ^ var.sample_reading ^ "," ^ 0 ^ "," ^ (var.sample_count + 1) ^ "," ^ var.nsew_depth ^ ",,,,,,"
    set var.sample_sum = var.sample_sum + var.sample_reading
    set var.sample_count = var.sample_count + 1
    if var.sample_count < var.probe_samples
        G53 G1 X{move.axes[0].userPosition + var.nsew_retract} F{var.traverse_speed}
        G53 G1 X{var.probe_x + var.spread} Y{var.probe_y} F{var.traverse_speed}
if !var.nsew_miss
    set var.x_plus = var.sample_sum / var.sample_count
    M118 P0 S{"T1 X+ done: " ^ var.x_plus ^ " (" ^ var.sample_count ^ "x, depth " ^ var.nsew_depth ^ "mm, reused)"}
if var.nsew_miss
    set var.nsew_attempt = 1
    set var.nsew_miss = true
    while var.nsew_miss && var.nsew_attempt <= var.nsew_max_attempts
        set var.nsew_miss = false
        set var.nsew_depth = var.nsew_drop_z * var.nsew_attempt
        M118 P0 S{"T1 X+ own-ladder attempt " ^ var.nsew_attempt ^ "/" ^ var.nsew_max_attempts ^ ", depth=" ^ var.nsew_depth ^ "mm"}
        G53 G1 Z{var.rough_z + var.lift_z} F2000
        G53 G1 X{var.probe_x + var.spread} Y{var.probe_y} F{var.traverse_speed}
        G53 G1 Z{var.rough_z - var.nsew_depth} F600
        set var.sample_sum = 0
        set var.sample_count = 0
        while var.sample_count < var.probe_samples
            G38.2 K1 X{var.probe_x - var.spread} F240
            if result >= 2
                if abs(move.axes[0].userPosition - (var.probe_x + var.spread)) < abs(move.axes[0].userPosition - (var.probe_x - var.spread))
                    G53 G1 Z{var.safe_z} F6000
                    abort "Calibration aborted: T1 X+ touch failed (probe already triggered at start) - see console."
                M118 P0 S{"T1 X+ MISS attempt " ^ var.nsew_attempt ^ " depth " ^ var.nsew_depth ^ "mm"}
                set var.nsew_miss = true
                break
            set var.sample_reading = move.axes[0].userPosition
            echo >>"0:/sys/zoff_nsew_log.csv" var.run_time ^ "," ^ "T1" ^ "," ^ "TX+" ^ "," ^ var.sample_reading ^ "," ^ var.nsew_attempt ^ "," ^ (var.sample_count + 1) ^ "," ^ var.nsew_depth ^ ",,,,,,"
            set var.sample_sum = var.sample_sum + var.sample_reading
            set var.sample_count = var.sample_count + 1
            if var.sample_count < var.probe_samples
                G53 G1 X{move.axes[0].userPosition + var.nsew_retract} F{var.traverse_speed}
                G53 G1 X{var.probe_x + var.spread} Y{var.probe_y} F{var.traverse_speed}
        if !var.nsew_miss
            set var.x_plus = var.sample_sum / var.sample_count
            M118 P0 S{"T1 X+ done: " ^ var.x_plus ^ " (" ^ var.sample_count ^ "x, depth " ^ var.nsew_depth ^ "mm, own ladder)"}
        set var.nsew_attempt = var.nsew_attempt + 1
    if var.nsew_miss
        G53 G1 Z{var.safe_z} F6000
        abort "Calibration aborted: T1 X+ never made contact after own ladder of " ^ var.nsew_max_attempts ^ " attempts (deepest tried " ^ (var.nsew_drop_z * var.nsew_max_attempts) ^ "mm) - see console."

set var.center_x = (var.x_minus + var.x_plus) / 2

; ===== Y- : depth-discovery ladder for the Y axis =====
set var.nsew_attempt = 1
set var.nsew_miss = true
while var.nsew_miss && var.nsew_attempt <= var.nsew_max_attempts
    set var.nsew_miss = false
    set var.nsew_depth = var.nsew_drop_z * var.nsew_attempt
    M118 P0 S{"T1 Y- discovery attempt " ^ var.nsew_attempt ^ "/" ^ var.nsew_max_attempts ^ ", depth=" ^ var.nsew_depth ^ "mm"}
    G53 G1 Z{var.rough_z + var.lift_z} F2000
    G53 G1 X{var.center_x} Y{var.probe_y - var.spread} F{var.traverse_speed}
    G53 G1 Z{var.rough_z - var.nsew_depth} F600
    set var.sample_sum = 0
    set var.sample_count = 0
    while var.sample_count < var.probe_samples
        G38.2 K1 Y{var.probe_y + var.spread} F240
        if result >= 2
            if abs(move.axes[1].userPosition - (var.probe_y - var.spread)) < abs(move.axes[1].userPosition - (var.probe_y + var.spread))
                G53 G1 Z{var.safe_z} F6000
                abort "Calibration aborted: T1 Y- touch failed (probe already triggered at start) - see console."
            M118 P0 S{"T1 Y- MISS attempt " ^ var.nsew_attempt ^ " depth " ^ var.nsew_depth ^ "mm"}
            set var.nsew_miss = true
            break
        set var.sample_reading = move.axes[1].userPosition
        echo >>"0:/sys/zoff_nsew_log.csv" var.run_time ^ "," ^ "T1" ^ "," ^ "TY-" ^ "," ^ var.sample_reading ^ "," ^ var.nsew_attempt ^ "," ^ (var.sample_count + 1) ^ "," ^ var.nsew_depth ^ ",,,,,,"
        set var.sample_sum = var.sample_sum + var.sample_reading
        set var.sample_count = var.sample_count + 1
        if var.sample_count < var.probe_samples
            G53 G1 Y{move.axes[1].userPosition - var.nsew_retract} F{var.traverse_speed}
            G53 G1 X{var.center_x} Y{var.probe_y - var.spread} F{var.traverse_speed}
    if !var.nsew_miss
        set var.y_minus = var.sample_sum / var.sample_count
        M118 P0 S{"T1 Y- done: " ^ var.y_minus ^ " (" ^ var.sample_count ^ "x, depth " ^ var.nsew_depth ^ "mm)"}
    set var.nsew_attempt = var.nsew_attempt + 1
if var.nsew_miss
    G53 G1 Z{var.safe_z} F6000
    abort "Calibration aborted: T1 Y- never made contact after " ^ var.nsew_max_attempts ^ " attempts (deepest tried " ^ (var.nsew_drop_z * var.nsew_max_attempts) ^ "mm) - see console."
set var.y_depth = var.nsew_depth

; ===== Y+ : try discovered Y depth first, fall back to its own ladder only if that misses =====
set var.nsew_depth = var.y_depth
set var.nsew_miss = false
M118 P0 S{"T1 Y+ trying Y depth " ^ var.nsew_depth ^ "mm (reused from Y-)"}
G53 G1 Z{var.rough_z + var.lift_z} F2000
G53 G1 X{var.center_x} Y{var.probe_y + var.spread} F{var.traverse_speed}
G53 G1 Z{var.rough_z - var.nsew_depth} F600
set var.sample_sum = 0
set var.sample_count = 0
while var.sample_count < var.probe_samples
    G38.2 K1 Y{var.probe_y - var.spread} F240
    if result >= 2
        if abs(move.axes[1].userPosition - (var.probe_y + var.spread)) < abs(move.axes[1].userPosition - (var.probe_y - var.spread))
            G53 G1 Z{var.safe_z} F6000
            abort "Calibration aborted: T1 Y+ touch failed (probe already triggered at start) - see console."
        M118 P0 S{"T1 Y+ MISS at reused Y depth " ^ var.nsew_depth ^ "mm - falling back to own ladder"}
        set var.nsew_miss = true
        break
    set var.sample_reading = move.axes[1].userPosition
    echo >>"0:/sys/zoff_nsew_log.csv" var.run_time ^ "," ^ "T1" ^ "," ^ "TY+" ^ "," ^ var.sample_reading ^ "," ^ 0 ^ "," ^ (var.sample_count + 1) ^ "," ^ var.nsew_depth ^ ",,,,,,"
    set var.sample_sum = var.sample_sum + var.sample_reading
    set var.sample_count = var.sample_count + 1
    if var.sample_count < var.probe_samples
        G53 G1 Y{move.axes[1].userPosition + var.nsew_retract} F{var.traverse_speed}
        G53 G1 X{var.center_x} Y{var.probe_y + var.spread} F{var.traverse_speed}
if !var.nsew_miss
    set var.y_plus = var.sample_sum / var.sample_count
    M118 P0 S{"T1 Y+ done: " ^ var.y_plus ^ " (" ^ var.sample_count ^ "x, depth " ^ var.nsew_depth ^ "mm, reused)"}
if var.nsew_miss
    set var.nsew_attempt = 1
    set var.nsew_miss = true
    while var.nsew_miss && var.nsew_attempt <= var.nsew_max_attempts
        set var.nsew_miss = false
        set var.nsew_depth = var.nsew_drop_z * var.nsew_attempt
        M118 P0 S{"T1 Y+ own-ladder attempt " ^ var.nsew_attempt ^ "/" ^ var.nsew_max_attempts ^ ", depth=" ^ var.nsew_depth ^ "mm"}
        G53 G1 Z{var.rough_z + var.lift_z} F2000
        G53 G1 X{var.center_x} Y{var.probe_y + var.spread} F{var.traverse_speed}
        G53 G1 Z{var.rough_z - var.nsew_depth} F600
        set var.sample_sum = 0
        set var.sample_count = 0
        while var.sample_count < var.probe_samples
            G38.2 K1 Y{var.probe_y - var.spread} F240
            if result >= 2
                if abs(move.axes[1].userPosition - (var.probe_y + var.spread)) < abs(move.axes[1].userPosition - (var.probe_y - var.spread))
                    G53 G1 Z{var.safe_z} F6000
                    abort "Calibration aborted: T1 Y+ touch failed (probe already triggered at start) - see console."
                M118 P0 S{"T1 Y+ MISS attempt " ^ var.nsew_attempt ^ " depth " ^ var.nsew_depth ^ "mm"}
                set var.nsew_miss = true
                break
            set var.sample_reading = move.axes[1].userPosition
            echo >>"0:/sys/zoff_nsew_log.csv" var.run_time ^ "," ^ "T1" ^ "," ^ "TY+" ^ "," ^ var.sample_reading ^ "," ^ var.nsew_attempt ^ "," ^ (var.sample_count + 1) ^ "," ^ var.nsew_depth ^ ",,,,,,"
            set var.sample_sum = var.sample_sum + var.sample_reading
            set var.sample_count = var.sample_count + 1
            if var.sample_count < var.probe_samples
                G53 G1 Y{move.axes[1].userPosition + var.nsew_retract} F{var.traverse_speed}
                G53 G1 X{var.center_x} Y{var.probe_y + var.spread} F{var.traverse_speed}
        if !var.nsew_miss
            set var.y_plus = var.sample_sum / var.sample_count
            M118 P0 S{"T1 Y+ done: " ^ var.y_plus ^ " (" ^ var.sample_count ^ "x, depth " ^ var.nsew_depth ^ "mm, own ladder)"}
        set var.nsew_attempt = var.nsew_attempt + 1
    if var.nsew_miss
        G53 G1 Z{var.safe_z} F6000
        abort "Calibration aborted: T1 Y+ never made contact after own ladder of " ^ var.nsew_max_attempts ^ " attempts (deepest tried " ^ (var.nsew_drop_z * var.nsew_max_attempts) ^ "mm) - see console."

set var.center_y = (var.y_minus + var.y_plus) / 2

G53 G1 Z{var.rough_z + var.lift_z} F2000

echo >>"0:/sys/zoff_nsew_log.csv" var.run_time ^ "," ^ "T1" ^ "," ^ "S" ^ "," ^ var.x_minus ^ "," ^ var.x_plus ^ "," ^ var.y_minus ^ "," ^ var.y_plus ^ "," ^ var.center_x ^ "," ^ var.center_y ^ ",," ^ var.x_depth ^ "," ^ var.y_depth

G53 G1 X{var.center_x} Y{var.center_y} F{var.traverse_speed}

set var.sample_sum = 0
set var.sample_count = 0
while var.sample_count < var.probe_samples
    G30 K1 S-1
    set var.sample_reading = move.axes[2].userPosition
    echo >>"0:/sys/zoff_nsew_log.csv" var.run_time ^ "," ^ "T1" ^ "," ^ "TC" ^ "," ^ var.sample_reading ^ ",," ^ (var.sample_count + 1) ^ ",,,,,,,"
    set var.sample_sum = var.sample_sum + var.sample_reading
    set var.sample_count = var.sample_count + 1
    if var.sample_count < var.probe_samples
        G53 G1 Z{move.axes[2].userPosition + var.probe_retract} F2000
var t1_z = var.sample_sum / var.sample_count
M118 P0 S{"T1 CENTER done: " ^ var.t1_z ^ " (" ^ var.sample_count ^ "x)"}

G53 G1 Z{var.final_lift_z + var.t1_z} F2000

echo >>"0:/sys/zoff_nsew_log.csv" var.run_time ^ "," ^ "T1" ^ "," ^ "C,,,,," ^ var.center_x ^ "," ^ var.center_y ^ "," ^ var.t1_z ^ "," ^ (var.t1_z - var.master_z)

G10 P1 Z{var.t1_z - var.master_z}
M118 P0 S{"T1 Z-offset applied: " ^ (var.t1_z - var.master_z)}
M118 P0 S{"Center X=" ^ var.center_x ^ " Y=" ^ var.center_y ^ " (ref only, X/Y=DuetToolAlign)"}

M291 P{"T1 Z-offset applied: " ^ (var.t1_z - var.master_z) ^ ". Review the result above, then click OK to continue to T2."} R"Calibrate_ZOff_Tool_NSEW - T1 done" S2

; ===== T2 CALIBRATION - identical pattern to T0's block above, tool label
; swapped. See sex-z-nipple.readme.md "The algorithm" / "Key design decisions". =====
G53 G1 Z{var.safe_z} F6000
T2
G4 P1000
if state.currentTool == -1
    abort "Calibration aborted: T2 pickup failed, nothing on the shuttle."
G10 P2 Z0
M118 P0 S"Locating SEX-Z-Nipple center for T2..."
G53 G1 X{var.probe_x} Y10 F15000
G53 G1 Y{var.probe_y} F2000
G53 G1 Z{var.approach_z} F2000
G30 K1 S-1
set var.rough_z = move.axes[2].userPosition


; ===== X- : depth-discovery ladder for the X axis =====
set var.nsew_attempt = 1
set var.nsew_miss = true
while var.nsew_miss && var.nsew_attempt <= var.nsew_max_attempts
    set var.nsew_miss = false
    set var.nsew_depth = var.nsew_drop_z * var.nsew_attempt
    M118 P0 S{"T2 X- discovery attempt " ^ var.nsew_attempt ^ "/" ^ var.nsew_max_attempts ^ ", depth=" ^ var.nsew_depth ^ "mm"}
    G53 G1 Z{var.rough_z + var.lift_z} F2000
    G53 G1 X{var.probe_x - var.spread} Y{var.probe_y} F{var.traverse_speed}
    G53 G1 Z{var.rough_z - var.nsew_depth} F600
    set var.sample_sum = 0
    set var.sample_count = 0
    while var.sample_count < var.probe_samples
        G38.2 K1 X{var.probe_x + var.spread} F240
        if result >= 2
            if abs(move.axes[0].userPosition - (var.probe_x - var.spread)) < abs(move.axes[0].userPosition - (var.probe_x + var.spread))
                G53 G1 Z{var.safe_z} F6000
                abort "Calibration aborted: T2 X- touch failed (probe already triggered at start) - see console."
            M118 P0 S{"T2 X- MISS attempt " ^ var.nsew_attempt ^ " depth " ^ var.nsew_depth ^ "mm"}
            set var.nsew_miss = true
            break
        set var.sample_reading = move.axes[0].userPosition
        echo >>"0:/sys/zoff_nsew_log.csv" var.run_time ^ "," ^ "T2" ^ "," ^ "TX-" ^ "," ^ var.sample_reading ^ "," ^ var.nsew_attempt ^ "," ^ (var.sample_count + 1) ^ "," ^ var.nsew_depth ^ ",,,,,,"
        set var.sample_sum = var.sample_sum + var.sample_reading
        set var.sample_count = var.sample_count + 1
        if var.sample_count < var.probe_samples
            G53 G1 X{move.axes[0].userPosition - var.nsew_retract} F{var.traverse_speed}
            G53 G1 X{var.probe_x - var.spread} Y{var.probe_y} F{var.traverse_speed}
    if !var.nsew_miss
        set var.x_minus = var.sample_sum / var.sample_count
        M118 P0 S{"T2 X- done: " ^ var.x_minus ^ " (" ^ var.sample_count ^ "x, depth " ^ var.nsew_depth ^ "mm)"}
    set var.nsew_attempt = var.nsew_attempt + 1
if var.nsew_miss
    G53 G1 Z{var.safe_z} F6000
    abort "Calibration aborted: T2 X- never made contact after " ^ var.nsew_max_attempts ^ " attempts (deepest tried " ^ (var.nsew_drop_z * var.nsew_max_attempts) ^ "mm) - see console."
set var.x_depth = var.nsew_depth

; ===== X+ : try discovered X depth first, fall back to its own ladder only if that misses =====
set var.nsew_depth = var.x_depth
set var.nsew_miss = false
M118 P0 S{"T2 X+ trying X depth " ^ var.nsew_depth ^ "mm (reused from X-)"}
G53 G1 Z{var.rough_z + var.lift_z} F2000
G53 G1 X{var.probe_x + var.spread} Y{var.probe_y} F{var.traverse_speed}
G53 G1 Z{var.rough_z - var.nsew_depth} F600
set var.sample_sum = 0
set var.sample_count = 0
while var.sample_count < var.probe_samples
    G38.2 K1 X{var.probe_x - var.spread} F240
    if result >= 2
        if abs(move.axes[0].userPosition - (var.probe_x + var.spread)) < abs(move.axes[0].userPosition - (var.probe_x - var.spread))
            G53 G1 Z{var.safe_z} F6000
            abort "Calibration aborted: T2 X+ touch failed (probe already triggered at start) - see console."
        M118 P0 S{"T2 X+ MISS at reused X depth " ^ var.nsew_depth ^ "mm - falling back to own ladder"}
        set var.nsew_miss = true
        break
    set var.sample_reading = move.axes[0].userPosition
    echo >>"0:/sys/zoff_nsew_log.csv" var.run_time ^ "," ^ "T2" ^ "," ^ "TX+" ^ "," ^ var.sample_reading ^ "," ^ 0 ^ "," ^ (var.sample_count + 1) ^ "," ^ var.nsew_depth ^ ",,,,,,"
    set var.sample_sum = var.sample_sum + var.sample_reading
    set var.sample_count = var.sample_count + 1
    if var.sample_count < var.probe_samples
        G53 G1 X{move.axes[0].userPosition + var.nsew_retract} F{var.traverse_speed}
        G53 G1 X{var.probe_x + var.spread} Y{var.probe_y} F{var.traverse_speed}
if !var.nsew_miss
    set var.x_plus = var.sample_sum / var.sample_count
    M118 P0 S{"T2 X+ done: " ^ var.x_plus ^ " (" ^ var.sample_count ^ "x, depth " ^ var.nsew_depth ^ "mm, reused)"}
if var.nsew_miss
    set var.nsew_attempt = 1
    set var.nsew_miss = true
    while var.nsew_miss && var.nsew_attempt <= var.nsew_max_attempts
        set var.nsew_miss = false
        set var.nsew_depth = var.nsew_drop_z * var.nsew_attempt
        M118 P0 S{"T2 X+ own-ladder attempt " ^ var.nsew_attempt ^ "/" ^ var.nsew_max_attempts ^ ", depth=" ^ var.nsew_depth ^ "mm"}
        G53 G1 Z{var.rough_z + var.lift_z} F2000
        G53 G1 X{var.probe_x + var.spread} Y{var.probe_y} F{var.traverse_speed}
        G53 G1 Z{var.rough_z - var.nsew_depth} F600
        set var.sample_sum = 0
        set var.sample_count = 0
        while var.sample_count < var.probe_samples
            G38.2 K1 X{var.probe_x - var.spread} F240
            if result >= 2
                if abs(move.axes[0].userPosition - (var.probe_x + var.spread)) < abs(move.axes[0].userPosition - (var.probe_x - var.spread))
                    G53 G1 Z{var.safe_z} F6000
                    abort "Calibration aborted: T2 X+ touch failed (probe already triggered at start) - see console."
                M118 P0 S{"T2 X+ MISS attempt " ^ var.nsew_attempt ^ " depth " ^ var.nsew_depth ^ "mm"}
                set var.nsew_miss = true
                break
            set var.sample_reading = move.axes[0].userPosition
            echo >>"0:/sys/zoff_nsew_log.csv" var.run_time ^ "," ^ "T2" ^ "," ^ "TX+" ^ "," ^ var.sample_reading ^ "," ^ var.nsew_attempt ^ "," ^ (var.sample_count + 1) ^ "," ^ var.nsew_depth ^ ",,,,,,"
            set var.sample_sum = var.sample_sum + var.sample_reading
            set var.sample_count = var.sample_count + 1
            if var.sample_count < var.probe_samples
                G53 G1 X{move.axes[0].userPosition + var.nsew_retract} F{var.traverse_speed}
                G53 G1 X{var.probe_x + var.spread} Y{var.probe_y} F{var.traverse_speed}
        if !var.nsew_miss
            set var.x_plus = var.sample_sum / var.sample_count
            M118 P0 S{"T2 X+ done: " ^ var.x_plus ^ " (" ^ var.sample_count ^ "x, depth " ^ var.nsew_depth ^ "mm, own ladder)"}
        set var.nsew_attempt = var.nsew_attempt + 1
    if var.nsew_miss
        G53 G1 Z{var.safe_z} F6000
        abort "Calibration aborted: T2 X+ never made contact after own ladder of " ^ var.nsew_max_attempts ^ " attempts (deepest tried " ^ (var.nsew_drop_z * var.nsew_max_attempts) ^ "mm) - see console."

set var.center_x = (var.x_minus + var.x_plus) / 2

; ===== Y- : depth-discovery ladder for the Y axis =====
set var.nsew_attempt = 1
set var.nsew_miss = true
while var.nsew_miss && var.nsew_attempt <= var.nsew_max_attempts
    set var.nsew_miss = false
    set var.nsew_depth = var.nsew_drop_z * var.nsew_attempt
    M118 P0 S{"T2 Y- discovery attempt " ^ var.nsew_attempt ^ "/" ^ var.nsew_max_attempts ^ ", depth=" ^ var.nsew_depth ^ "mm"}
    G53 G1 Z{var.rough_z + var.lift_z} F2000
    G53 G1 X{var.center_x} Y{var.probe_y - var.spread} F{var.traverse_speed}
    G53 G1 Z{var.rough_z - var.nsew_depth} F600
    set var.sample_sum = 0
    set var.sample_count = 0
    while var.sample_count < var.probe_samples
        G38.2 K1 Y{var.probe_y + var.spread} F240
        if result >= 2
            if abs(move.axes[1].userPosition - (var.probe_y - var.spread)) < abs(move.axes[1].userPosition - (var.probe_y + var.spread))
                G53 G1 Z{var.safe_z} F6000
                abort "Calibration aborted: T2 Y- touch failed (probe already triggered at start) - see console."
            M118 P0 S{"T2 Y- MISS attempt " ^ var.nsew_attempt ^ " depth " ^ var.nsew_depth ^ "mm"}
            set var.nsew_miss = true
            break
        set var.sample_reading = move.axes[1].userPosition
        echo >>"0:/sys/zoff_nsew_log.csv" var.run_time ^ "," ^ "T2" ^ "," ^ "TY-" ^ "," ^ var.sample_reading ^ "," ^ var.nsew_attempt ^ "," ^ (var.sample_count + 1) ^ "," ^ var.nsew_depth ^ ",,,,,,"
        set var.sample_sum = var.sample_sum + var.sample_reading
        set var.sample_count = var.sample_count + 1
        if var.sample_count < var.probe_samples
            G53 G1 Y{move.axes[1].userPosition - var.nsew_retract} F{var.traverse_speed}
            G53 G1 X{var.center_x} Y{var.probe_y - var.spread} F{var.traverse_speed}
    if !var.nsew_miss
        set var.y_minus = var.sample_sum / var.sample_count
        M118 P0 S{"T2 Y- done: " ^ var.y_minus ^ " (" ^ var.sample_count ^ "x, depth " ^ var.nsew_depth ^ "mm)"}
    set var.nsew_attempt = var.nsew_attempt + 1
if var.nsew_miss
    G53 G1 Z{var.safe_z} F6000
    abort "Calibration aborted: T2 Y- never made contact after " ^ var.nsew_max_attempts ^ " attempts (deepest tried " ^ (var.nsew_drop_z * var.nsew_max_attempts) ^ "mm) - see console."
set var.y_depth = var.nsew_depth

; ===== Y+ : try discovered Y depth first, fall back to its own ladder only if that misses =====
set var.nsew_depth = var.y_depth
set var.nsew_miss = false
M118 P0 S{"T2 Y+ trying Y depth " ^ var.nsew_depth ^ "mm (reused from Y-)"}
G53 G1 Z{var.rough_z + var.lift_z} F2000
G53 G1 X{var.center_x} Y{var.probe_y + var.spread} F{var.traverse_speed}
G53 G1 Z{var.rough_z - var.nsew_depth} F600
set var.sample_sum = 0
set var.sample_count = 0
while var.sample_count < var.probe_samples
    G38.2 K1 Y{var.probe_y - var.spread} F240
    if result >= 2
        if abs(move.axes[1].userPosition - (var.probe_y + var.spread)) < abs(move.axes[1].userPosition - (var.probe_y - var.spread))
            G53 G1 Z{var.safe_z} F6000
            abort "Calibration aborted: T2 Y+ touch failed (probe already triggered at start) - see console."
        M118 P0 S{"T2 Y+ MISS at reused Y depth " ^ var.nsew_depth ^ "mm - falling back to own ladder"}
        set var.nsew_miss = true
        break
    set var.sample_reading = move.axes[1].userPosition
    echo >>"0:/sys/zoff_nsew_log.csv" var.run_time ^ "," ^ "T2" ^ "," ^ "TY+" ^ "," ^ var.sample_reading ^ "," ^ 0 ^ "," ^ (var.sample_count + 1) ^ "," ^ var.nsew_depth ^ ",,,,,,"
    set var.sample_sum = var.sample_sum + var.sample_reading
    set var.sample_count = var.sample_count + 1
    if var.sample_count < var.probe_samples
        G53 G1 Y{move.axes[1].userPosition + var.nsew_retract} F{var.traverse_speed}
        G53 G1 X{var.center_x} Y{var.probe_y + var.spread} F{var.traverse_speed}
if !var.nsew_miss
    set var.y_plus = var.sample_sum / var.sample_count
    M118 P0 S{"T2 Y+ done: " ^ var.y_plus ^ " (" ^ var.sample_count ^ "x, depth " ^ var.nsew_depth ^ "mm, reused)"}
if var.nsew_miss
    set var.nsew_attempt = 1
    set var.nsew_miss = true
    while var.nsew_miss && var.nsew_attempt <= var.nsew_max_attempts
        set var.nsew_miss = false
        set var.nsew_depth = var.nsew_drop_z * var.nsew_attempt
        M118 P0 S{"T2 Y+ own-ladder attempt " ^ var.nsew_attempt ^ "/" ^ var.nsew_max_attempts ^ ", depth=" ^ var.nsew_depth ^ "mm"}
        G53 G1 Z{var.rough_z + var.lift_z} F2000
        G53 G1 X{var.center_x} Y{var.probe_y + var.spread} F{var.traverse_speed}
        G53 G1 Z{var.rough_z - var.nsew_depth} F600
        set var.sample_sum = 0
        set var.sample_count = 0
        while var.sample_count < var.probe_samples
            G38.2 K1 Y{var.probe_y - var.spread} F240
            if result >= 2
                if abs(move.axes[1].userPosition - (var.probe_y + var.spread)) < abs(move.axes[1].userPosition - (var.probe_y - var.spread))
                    G53 G1 Z{var.safe_z} F6000
                    abort "Calibration aborted: T2 Y+ touch failed (probe already triggered at start) - see console."
                M118 P0 S{"T2 Y+ MISS attempt " ^ var.nsew_attempt ^ " depth " ^ var.nsew_depth ^ "mm"}
                set var.nsew_miss = true
                break
            set var.sample_reading = move.axes[1].userPosition
            echo >>"0:/sys/zoff_nsew_log.csv" var.run_time ^ "," ^ "T2" ^ "," ^ "TY+" ^ "," ^ var.sample_reading ^ "," ^ var.nsew_attempt ^ "," ^ (var.sample_count + 1) ^ "," ^ var.nsew_depth ^ ",,,,,,"
            set var.sample_sum = var.sample_sum + var.sample_reading
            set var.sample_count = var.sample_count + 1
            if var.sample_count < var.probe_samples
                G53 G1 Y{move.axes[1].userPosition + var.nsew_retract} F{var.traverse_speed}
                G53 G1 X{var.center_x} Y{var.probe_y + var.spread} F{var.traverse_speed}
        if !var.nsew_miss
            set var.y_plus = var.sample_sum / var.sample_count
            M118 P0 S{"T2 Y+ done: " ^ var.y_plus ^ " (" ^ var.sample_count ^ "x, depth " ^ var.nsew_depth ^ "mm, own ladder)"}
        set var.nsew_attempt = var.nsew_attempt + 1
    if var.nsew_miss
        G53 G1 Z{var.safe_z} F6000
        abort "Calibration aborted: T2 Y+ never made contact after own ladder of " ^ var.nsew_max_attempts ^ " attempts (deepest tried " ^ (var.nsew_drop_z * var.nsew_max_attempts) ^ "mm) - see console."

set var.center_y = (var.y_minus + var.y_plus) / 2

G53 G1 Z{var.rough_z + var.lift_z} F2000

echo >>"0:/sys/zoff_nsew_log.csv" var.run_time ^ "," ^ "T2" ^ "," ^ "S" ^ "," ^ var.x_minus ^ "," ^ var.x_plus ^ "," ^ var.y_minus ^ "," ^ var.y_plus ^ "," ^ var.center_x ^ "," ^ var.center_y ^ ",," ^ var.x_depth ^ "," ^ var.y_depth

G53 G1 X{var.center_x} Y{var.center_y} F{var.traverse_speed}

set var.sample_sum = 0
set var.sample_count = 0
while var.sample_count < var.probe_samples
    G30 K1 S-1
    set var.sample_reading = move.axes[2].userPosition
    echo >>"0:/sys/zoff_nsew_log.csv" var.run_time ^ "," ^ "T2" ^ "," ^ "TC" ^ "," ^ var.sample_reading ^ ",," ^ (var.sample_count + 1) ^ ",,,,,,,"
    set var.sample_sum = var.sample_sum + var.sample_reading
    set var.sample_count = var.sample_count + 1
    if var.sample_count < var.probe_samples
        G53 G1 Z{move.axes[2].userPosition + var.probe_retract} F2000
var t2_z = var.sample_sum / var.sample_count
M118 P0 S{"T2 CENTER done: " ^ var.t2_z ^ " (" ^ var.sample_count ^ "x)"}

G53 G1 Z{var.final_lift_z + var.t2_z} F2000

echo >>"0:/sys/zoff_nsew_log.csv" var.run_time ^ "," ^ "T2" ^ "," ^ "C,,,,," ^ var.center_x ^ "," ^ var.center_y ^ "," ^ var.t2_z ^ "," ^ (var.t2_z - var.master_z)

G10 P2 Z{var.t2_z - var.master_z}
M118 P0 S{"T2 Z-offset applied: " ^ (var.t2_z - var.master_z)}
M118 P0 S{"Center X=" ^ var.center_x ^ " Y=" ^ var.center_y ^ " (ref only, X/Y=DuetToolAlign)"}

; ===== FINALIZE - M500 P10 specifically, not bare M500: bare M500 does NOT
; save tool offsets at all. See sex-z-nipple.readme.md "Key design decisions". =====
G53 G1 Z{var.safe_z} F6000
M500 P10
M118 P0 S"N/S/E/W calibration complete. All offsets saved."
