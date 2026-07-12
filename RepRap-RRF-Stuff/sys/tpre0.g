;
; ===============================
;  NEW WITH SPEED VARS tpre0.g - Prepare for Tool 0 [ T0]
; ===============================
;
; M208 Z260 S0                                                ; OPEN Z-CEILING FOR TOOLCHANGE

; --- Hard Safety Abort ---
if move.axes[0].homed == false || move.axes[1].homed == false || move.axes[2].homed == false
    M291 P"Tool change aborted: Printer not homed!" S2
    abort "Tool change aborted: Printer not homed!"


G90
G53 G1 Z{global.dock_z_low} F{global.speed_z_fast}            ; Enforce Safe Low Z (FAST Z)
G53 G1 Y{global.dock_safe_y_empty} F{global.speed_xy_fast}    ; Move Y into empty safety corridor
G53 G1 X{global.dock_x_0} F{global.speed_xy_fast}             ; Move X to Tool 0






