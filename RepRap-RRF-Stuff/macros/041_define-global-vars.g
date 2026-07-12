; Macro for defining Global variables at start
;
; ===================================================
;   Docking Variables - X AXIS Locations            |
; ===================================================
;   T0-X8 T1-X71 T2-X133 T3-X190 T4-X240 T5-X290    |
; ===================================================

; ============================================
; EDITABLE DOCK X / Y LOCATIONS  (edit here)
; ============================================
if !exists(global.dock_x_0)
    global dock_x_0 = 8
else
    set global.dock_x_0 = 8
if !exists(global.dock_x_1)
    global dock_x_1 = 71
else
    set global.dock_x_1 = 71
if !exists(global.dock_x_2)
    global dock_x_2 = 133
else
    set global.dock_x_2 = 133
if !exists(global.dock_x_3)
    global dock_x_3 = 190
else
    set global.dock_x_3 = 190
if !exists(global.dock_x_4)
    global dock_x_4 = 240
else
    set global.dock_x_4 = 240
if !exists(global.dock_x_5)
    global dock_x_5 = 290
else
    set global.dock_x_5 = 290
; ==============================================
; --- Indexable X array (for prime_lines.g) ---
;===============================================

if !exists(global.dock_x)
    global dock_x = {global.dock_x_0, global.dock_x_1, global.dock_x_2, global.dock_x_3, global.dock_x_4, global.dock_x_5}
else
    set global.dock_x = {global.dock_x_0, global.dock_x_1, global.dock_x_2, global.dock_x_3, global.dock_x_4, global.dock_x_5}

; =========================================
; --- Physical dock Y location ---
; =========================================
if !exists(global.dock_y)
    global dock_y = 12
else
    set global.dock_y = 12

; ==========================================
; JOB / TEMP STATE VARIABLES
; ==========================================
if !exists(global.bed_temp)
    global bed_temp = heat.heaters[0].active

if !exists(global.hotend_temp)
    global hotend_temp = heat.heaters[1].active

if !exists(global.job_completion)
    global job_completion = 0

; ==========================================
;  GLOBAL TOOLCHANGING SPEED SETTING VARS
; ==========================================
if !exists(global.speed_xy_fast)
    global speed_xy_fast = 21000     ; 350 mm/s for safe, fast XY travel
else
    set global.speed_xy_fast = 21000

if !exists(global.speed_z_fast)
    global speed_z_fast = 2400       ; 30 mm/s for large Z canopy moves
else
    set global.speed_z_fast = 2400

if !exists(global.speed_dock_y)
    global speed_dock_y = 4000        ; 50 mm/s for sliding into the dock smoothly
else
    set global.speed_dock_y = 4000

if !exists(global.speed_dock_z)
    global speed_dock_z = 1200        ; 15 mm/s for gently dropping onto/lifting off pins
else
    set global.speed_dock_z = 1200

; ==========================================
; STEALTHCHANGER DOCKING VARIABLES
; ==========================================

; --- Y Coordinates (Safe Approach and Dock) ---
if !exists(global.dock_safe_y_loaded)
    global dock_safe_y_loaded = 120     ; Safe Y when carrying a tool (clears toolboards)
else
    set global.dock_safe_y_loaded = 120

if !exists(global.dock_safe_y_empty)
    global dock_safe_y_empty = 30       ; Closer Safe Y when carriage is empty
else
    set global.dock_safe_y_empty = 30


; --- Z Coordinates (High/Carry and Low/Drop) ---
if !exists(global.dock_z_high)
    global dock_z_high = 288
else
    set global.dock_z_high = 288

if !exists(global.dock_z_low)
    global dock_z_low = 272
else
    set global.dock_z_low = 272

; ==========================================
; CAMERA ALIGNMENT VARIABLES (BtnCmd)
; ==========================================

; Initialize T0 alignment origin variables so BtnCmd OM Panels don't throw an error
if !exists(global.t_zero_alignment_origin_x)
    global t_zero_alignment_origin_x = 0
else
    set global.t_zero_alignment_origin_x = 0

if !exists(global.t_zero_alignment_origin_y)
    global t_zero_alignment_origin_y = 0
else
    set global.t_zero_alignment_origin_y = 0