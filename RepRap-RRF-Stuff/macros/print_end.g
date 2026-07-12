
; --- Tool Check ---
if state.currentTool == -1
    M117 "No tool attached, skipping tool-specific end routine."
else
    M117 "Tool {state.currentTool} detected. Executing end routine."
    ; Your wipe-and-park logic goes here



G91                    ; Relative positioning
G1 Z5 F3000            ; Lift nozzle 5mm
G90                    ; Absolute positioning
G1 X20 Y280 F6000      ; Move to park position (adjust coordinates for your bed)
M104 S0                ; Turn off hotend
M140 S0                ; Turn off bed
M106 S0                ; Turn off part cooling fan
M84                    ; Disable steppers
M291 P"Print Finished" S0 T5