; tpost0.g - Pick up Tool 0

G90
;
G53 G1 Y{global.dock_y} F{global.speed_dock_y}                  ; Slide into dock (SLOW Y)
;
G53 G1 Z{global.dock_z_high} F{global.speed_dock_z}             ; LIFT TOOL off pins (VERY SLOW Z)
;
; =======================================================
; 3. SET UP PROBE AND VERIFY TOOL PRESENCE
; =======================================================
; Map the probe to Tool 0's CAN board
M558 K0 P8 C"^20.io1.in" H5:4 F400:200 A5 S0.01 T24800 			        ; set Z probe type to Opto | H-Dive Height | F-Speed | A-Probe Tries | S-tolerance of probes
G31 K0 P5 Z-1.635 X0 Y0   		               					        ; K-probe number | P-set trigger value |  Z-trigger height - OptoTap triggers below 0 
G4 P240                                                                 ; Wait a fraction of a second for the CAN board and sensor to register

; 4. SAFETY VERIFICATION 
if !exists(sensors.probes[0]) || sensors.probes[0].value[0] == 1000      ; If value is 1000, the sensor is empty. The tool didn't attach!
    abort "ERROR: Tool 0 Pickup Failed! No Probe Found"
; =======================================================
;
G53 G1 Y{global.dock_safe_y_loaded} F{global.speed_xy_fast}             ; Retreat loaded to Y125
;
G53 G1 Z{global.dock_z_low} F{global.speed_z_fast}                      ; Drop gantry under the canopy (FAST Z)
;
; RESTORE OR PARK
if move.axes[0].homed && move.axes[1].homed && move.axes[2].homed
    ; If the machine is homed, always return to the pre-toolchange coordinates
    G1 R2 X0 F{global.speed_xy_fast}
    G1 R2 Z5 F{global.speed_z_fast}
    G1 R2 Y0 F{global.speed_xy_fast}
    G1 R2 Z0 F{global.speed_z_fast}
else
    ; Fallback park if the machine somehow picked up a tool without being homed
    G53 G1 X150 F{global.speed_xy_fast}
    G53 G1 Z100 F{global.speed_z_fast}
    G53 G1 Y150 F{global.speed_xy_fast}


;M208 Z230 S0                                               ; CLOSE THE Z-CEILING FOR SAFE PRINTING (Adjust 230 to your safe height)