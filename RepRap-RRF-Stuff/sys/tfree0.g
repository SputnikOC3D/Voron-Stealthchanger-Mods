; =====================================================================================
; tfree0.g - Put away Tool 0
; Note: Since you have a V2.4 (Flying Z), raising Z lifts the gantry away from the bed.
; SEE Global Vars Macro - 001_define-global-vars.g
; =====================================================================================
;
; --- Hard Safety Abort & State Reset ---
if !move.axes[0].homed || !move.axes[1].homed || !move.axes[2].homed
    T-1 P0  ; CRITICAL: Silently deselect the tool so RRF doesn't think it's attached
    
    ; Throw a blocking prompt with only two choices
    M291 P"Tool change blocked: Printer is UNHOMED. Choose action:" R"CRITICAL SAFETY" S4 K{"Home All", "Emergency Stop"}
    
    if input == 0
        ; User clicked "Home All"
        G28
        abort "Tool change cancelled. Homing printer..."
    elif input == 1
        ; User clicked "Emergency Stop"
        M112




; ============================================
;  NEW VERSION - SPEEDS N FEEDS GLOBALS tfree0.g - Drop Off Tool 0
; ============================================
;
; M208 Z260 S0                                                    ; 1. OPEN Z-CEILING FOR TOOLCHANGE
;
G91                                                             ; Relative positioning
G1 Z15 F{global.speed_z_fast}                                   ; Lift gantry 15mm to clear the printed part
G90                                                             ; Back to absolute positioning
;
G53 G1 Y{global.dock_safe_y_loaded} F{global.speed_xy_fast}     ; Move to LOADED Safe Y (Y125)
;
G53 G1 X{global.dock_x_0} F{global.speed_xy_fast}               ; Move X to align with dock
;
G53 G1 Z{global.dock_z_high} F{global.speed_z_fast}             ; Push UP into canopy slot (FAST Z)
;
G53 G1 Y{global.dock_y} F{global.speed_dock_y}                  ; Slide into Dock (SLOW Y)
;
G53 G1 Z{global.dock_z_low} F{global.speed_dock_z}              ; DROP TOOL onto pins (VERY SLOW Z)
;
G53 G1 Y{global.dock_safe_y_empty} F{global.speed_xy_fast}      ; Retreat empty carriage to Safe Y (Y25)
M558 K0 P0                                                      ; Disable probe mapping
