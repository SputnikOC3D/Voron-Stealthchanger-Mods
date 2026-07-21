;============================
;  Quad Level Gantry Hot - 65* Bed
;============================

; --- PRE-FLIGHT SAFETY CHECKS ---

; 1. Verify X and Y axes are homed
if !move.axes[0].homed || !move.axes[1].homed
	abort "Error: X and Y axes must be homed before Quad Gantry Leveling."

; 2. Verify a tool is physically attached (-1 means the carriage is empty)
if state.currentTool == -1
	abort "Error: No tool attached! Cannot probe the bed for QGL."

; --- PREPARE AND HEAT ---

;M98 P"led/qgl-hot.g"				; Runs the QGL Hot Macro for the LEDs (Path Fixed)
M106 P12 S0.75						; sets Case Fans 1 and 2 to 75 pct (was P2/P3 - wrong fan numbers, fixed 2026-07-17)
M106 P13 S0.75						; sets Case Fans 1 and 2 to 75 pct (was P2/P3 - wrong fan numbers, fixed 2026-07-17)
M913 Z85							; reduce motor current to 85% of max
M561								; Clear loaded bed mesh

M140 S65							; Set Bed H0 temp to 65C
M190 S65							; Wait for bed temp

; --- QGL SEQUENCE ---

; First Pass
G30 P0 X15 Y30 Z-99999 				; probe near Z Belts by X0,Y0	[ Front Left ]
G30 P1 X15 Y285 Z-99999				; probe near a leadscrew		[ Left Rear ]
G30 P2 X285 Y285 Z-99999			; probe near a leadscrew		[ Right Rear ]
G30 P3 X285 Y30 Z-99999 S4			; probe near a leadscrew		[ Front Right ]

;==========================
; Run It Again
;==========================

M558 H3								; sets probe dive height to 3mm to speed things up
G30 P0 X15 Y30 Z-99999 				; probe near Z Belts by X0,Y0	[ Front Left ]
G30 P1 X15 Y285 Z-99999				; probe near a leadscrew		[ Left Rear ]
G30 P2 X285 Y285 Z-99999			; probe near a leadscrew		[ Right Rear ]
G30 P3 X285 Y30 Z-99999 S4			; probe near a leadscrew		[ Front Right ]

M913 Z100							; increase currents back to 100%
M558 H4								; sets probe dive height back to 4mm 
G1 Z40								; raise Z to 40
G1 X150 Y150 F14400					; center the head because that's how we roll
M400								; wait till moves complete

;M98 P"led/standby.g"				; Runs the Standby Macro for the LEDs (Path Fixed)


