; ============================================
; PRIME LINES - SEQUENTIAL X-AXIS PURGE
; STAGE 3: multi-tool, tool changes + per-tool heat wait
; SAFE-LANE VERSION: all X traverse at safe Y, dock via G53
; ============================================

; --- Configuration ---
var prime_start_x   = 10       ; X start of the first tool's purge strip (bed coord)
var prime_y         = 22       ; Y of the purge line (front row, under canopy)
var strip_width     = 30       ; X length of each purge strip (mm)
var strip_spacing   = 5        ; X gap between adjacent tool strips (mm)
var lines_per_tool  = 6        ; number of serpentine passes per tool
var line_step_y     = 2        ; Y step-down between serpentine passes (mm)
var ratio           = 4        ; extrusion ratio: E per strip = strip_width / ratio
var pre_prime       = 8        ; pre-purge blob extrusion amount (mm)
var wipe_length     = 6        ; X distance of the wipe move after purge (mm)
var tool_retract    = 0.5      ; retract before wipe/lift (mm)
var z_prime_pos     = 0.3      ; Z height for laying down the purge lines (mm)
var z_move_pos      = 1        ; (reserved) short-hop Z height (mm) - unused currently
var z_safe          = 15       ; safe Z for travel / lifts clear of bed & parts (mm)
var safe_y          = 120      ; forward-safe Y for all X traverse (clears docks)
; --- Speeds (mm/min) ---
var travel_speed     = 21000   ; open-air XY travel to strip at safe Y (fast)
var approach_y_speed = 6000    ; Y-drop from safe_y down to prime_y (near dock zone)
var z_lift_speed     = 2400    ; Z lift up to safe height (bed drops away, low risk)
var z_prime_speed    = 1200    ; gentle final Z drop to prime height (bed approach)
var prime_speed      = 1000    ; extrusion speed for blob + serpentine lines
var wipe_speed       = 3000    ; retract + wipe move speed
; --- Loop / detection state ---
var i               = 0            ; outer loop index over all defined tools
var tn              = 0            ; current tool number being processed
var used_count      = 0            ; count of tools active in this job (detection)
var lane            = 0            ; sequential lane index among USED tools only
var standby_offset  = 45           ; set used tools stdby temp [ print_temp minus offset ]

; ===========================================
; --- Dynamic Tool Audit / Detection ---
; ===========================================
echo "===================== PRIME DETECTION ====================="
echo "Tools defined on machine (#tools): " ^ #tools
while var.i < #tools
    if tools[var.i].active[0] > 0
        set var.used_count = var.used_count + 1
        M568 P{var.i} R{tools[var.i].active[0] - var.standby_offset} A1
        echo "USED -> T" ^ var.i ^ " '" ^ tools[var.i].name ^ "'"
        echo "        active/first-layer temp : " ^ tools[var.i].active[0] ^ " C"
        echo "        standby temp            : " ^ tools[var.i].standby[0] ^ " C"
        echo "        heater index            : " ^ tools[var.i].heaters[0]
        echo "        XYZ offset              : " ^ tools[var.i].offsets[0] ^ ", " ^ tools[var.i].offsets[1] ^ ", " ^ tools[var.i].offsets[2]
        echo "        state                   : " ^ tools[var.i].state
    else
        echo "skip -> T" ^ var.i ^ " '" ^ tools[var.i].name ^ "'  (active=" ^ tools[var.i].active[0] ^ "C, not used this job)"
    set var.i = var.i + 1
echo "-----------------------------------------------------------"
echo "JOB TYPE : " ^ var.used_count ^ "-tool job"
echo "==========================================================="

; --- Guard: nothing detected ---
if var.used_count == 0
    abort "PRIME: No active tools detected (no G10 temps set). Check slicer output."

; =====================
;  Priming Routine  -- STAGE 3: safe-lane multi-tool
; =====================
; Dock-approach moves use GLOBAL dock speeds (match tfree/tpre/tpost).
; Travel-to-strip = travel_speed, Y-drop = approach_y_speed,
; bed approach = z_prime_speed (gentle). Purge uses prime/wipe speeds.
; =====================

; Safety gate before any motion
M291 P{"STAGE 3: multi-tool PURGE (" ^ var.used_count ^ " tools) with tool changes. OK to proceed?"} R"Prime Routine" S3

G90
M83

set var.i = 0
set var.lane = 0
while var.i < #tools
    set var.tn = var.i
    if tools[var.tn].active[0] > 0
        var strip_x = var.prime_start_x + (var.lane * (var.strip_width + var.strip_spacing))
        echo "PRIME T" ^ var.tn ^ "  lane=" ^ var.lane ^ "  strip_x=" ^ var.strip_x

        ; --- move to this tool's dock lane at SAFE Y (global dock speeds), then change ---
        G1 Z{var.z_safe} F{var.z_lift_speed}
        G53 G1 Y{var.safe_y} F{global.speed_xy_fast}
        G53 G1 X{global.dock_x[var.tn]} F{global.speed_xy_fast}
        T{var.tn}

        ; --- approach purge strip: X at safe Y first, then drop Y ---
        G1 Z{var.z_safe} F{var.z_lift_speed}
        G53 G1 Y{var.safe_y} F{global.speed_xy_fast}
        G1 X{var.strip_x} F{var.travel_speed}
        G1 Y{var.prime_y} F{var.approach_y_speed}

        echo "STAGE 3: at strip, waiting for T" ^ var.tn ^ " to reach active temp..."
        M116 P{var.tn}
        echo "STAGE 3: T" ^ var.tn ^ " at temp. Purging."

        ; --- gentle drop to prime Z ---
        G1 Z{var.z_prime_pos} F{var.z_prime_speed}

        ; pre-prime blob
        G1 E{var.pre_prime} F{var.prime_speed}

        ; --- serpentine: lines_per_tool passes WITH extrusion ---
        var pass = 0
        while var.pass < var.lines_per_tool
            var y_here = var.prime_y - (var.pass * var.line_step_y)
            if mod(var.pass, 2) == 0
                G1 X{var.strip_x + var.strip_width} Y{var.y_here} E{var.strip_width / var.ratio} F{var.prime_speed}
            else
                G1 X{var.strip_x} Y{var.y_here} E{var.strip_width / var.ratio} F{var.prime_speed}
            set var.pass = var.pass + 1

        ; --- retract, wipe, lift clear ---
        G1 E-{var.tool_retract} F{var.wipe_speed}
        G1 X{var.strip_x + var.wipe_length} F{var.wipe_speed}
        G1 Z{var.z_safe} F{var.z_lift_speed}

        set var.lane = var.lane + 1
    set var.i = var.i + 1

echo ">>> STAGE 3 complete (" ^ var.lane ^ " tool(s) primed)."