; 0:/macros/print_start.g
; Usage: M98 P"print_start.g" T{initial_tool} B{first_layer_bed_temperature} H{first_layer_temperature[initial_tool]}

; ========================
; 1. Parameter Validation
; ========================

if !exists(param.T) || !exists(param.B) || !exists(param.H)
    abort "Error: Missing parameters (T, B, or H). Slicer configuration is incorrect."

; ====================
; 2. Prep & Safety - Tool attached / Homed ? 
; ====================

; ====================
; 2A. Tool Presence Check
; ====================
M98 P"0:/macros/05_discover_tool.g"     ; Run your existing discovery macro

if state.currentTool == -1
    abort "Error: No tool attached to the shuttle! Attach a tool before starting."

; ====================
; 2B. Tool / Axis' Homed 
; ====================

if !move.axes[0].homed || !move.axes[1].homed || !move.axes[2].homed
    abort "Error: Printer not homed! Please home the machine before starting a print."

G21                                     ; Set units to millimeters
G90                                     ; Absolute positioning
M83                                     ; Extruder relative mode   
M140 S{param.B}                         ; Start bed heat promptly


; ====================
; 3. Mesh/Prime / Prep 
; ====================
M561                                ; Clear any old mesh - Disable mesh
G29 S1 P"heightmap.csv"             ; Enable most recent mesh grid compensation

M98 P"0:/macros/prime_lines.g"      ; Run the prime lines for all needed tools in print job 

; ====================
; 4. Heating Routine
; ====================

M291 P"Waiting for Bed..." S0 T2
M116 H0 ; Wait for bed

M291 P"Heating Tools for Print" S0 T2
M116 P{param.T} ; Wait only for the INITIAL tool to reach printing temp to start


; ====================
; 5. Select Tool
; ====================
T{param.T} P0   

M291 P"Print Started" S0 T2




