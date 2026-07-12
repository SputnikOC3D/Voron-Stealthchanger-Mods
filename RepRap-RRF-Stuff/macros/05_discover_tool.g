; 05_discover_tool.g
; Iterates through CAN boards to find which tool is attached to the shuttle

echo "Discovering attached tool..."

; --- CHECK TOOL 0 (CAN 20) ---
M558 K0 P8 C"^20.io1.in" H5:4 F200:400 A5 S0.01 T24800 		; set Z probe type to Opto | H-Dive Height | F-Speed | A-Probe Tries | S-tolerance of probes
G4 P250                                                     ; Wait 250ms for CAN board to report
if sensors.probes[0].value[0] == 0
    echo "Tool 0 discovered on shuttle."
    T0 P0                                                   ; Silently select Tool 0
    G31 K0 P5 Z-1.635 X0 Y0   		               			; K-probe number | P-set trigger value |  Z-trigger height - OptoTap triggers below 0
    M99                                                     ; EXIT MACRO! (We found it, stop looking)

; --- CHECK TOOL 1 (CAN 21) ---
M558 K0 P8 C"^21.io1.in" H5:4 F200:400 A5 S0.01 T24800 		; set Z probe type to Opto | H-Dive Height | F-Speed | A-Probe Tries | S-tolerance of probes
G4 P250
if sensors.probes[0].value[0] == 0
    echo "Tool 1 discovered on shuttle."
    T1 P0                                                   ; Silently select Tool 1
    G31 K0 P5 Z-1.635 X0 Y0   		               			; K-probe number | P-set trigger value |  Z-trigger height - OptoTap triggers below 0
    M99                                                     ; EXIT MACRO!


; --- CHECK TOOL 2 (CAN 22) ---
M558 K0 P8 C"^22.io2.in" H5:4 F200:400 A5 S0.01 T24800 		; set Z probe type to Opto | H-Dive Height | F-Speed | A-Probe Tries | S-tolerance of probes
G4 P250
if sensors.probes[0].value[0] == 0
    echo "Tool 2 discovered on shuttle."
    T2 P0                                                   ; Silently select Tool 2
    G31 K0 P5 Z-1.635 X0 Y0   		               			; K-probe number | P-set trigger value |  Z-trigger height - OptoTap triggers below 0
    M99                                                     ; EXIT MACRO!


; --- CHECK TOOL 3 (CAN 23) ---
;M558 K0 P8 C"^23.io1.in" H5:4 F200:400 A5 S0.01 T24800 		; set Z probe type to Opto | H-Dive Height | F-Speed | A-Probe Tries | S-tolerance of probes
;G4 P250
;if sensors.probes[0].value[0] == 0
;    echo "Tool 3 discovered on shuttle."
;    T3 P0                                                   ; Silently select Tool 3
;    G31 K0 P5 Z-1.635 X0 Y0   		               			; K-probe number | P-set trigger value |  Z-trigger height - OptoTap triggers below 0
;    M99                                                     ; EXIT MACRO!


; --- CHECK TOOL 4 (CAN 24) ---
;M558 K0 P8 C"^24.io1.in" H5:4 F200:400 A5 S0.01 T24800 		; set Z probe type to Opto | H-Dive Height | F-Speed | A-Probe Tries | S-tolerance of probes
;G4 P250
;if sensors.probes[0].value[0] == 0
;    echo "Tool 4 discovered on shuttle."
;    T4 P0                                                   ; Silently select Tool 4
;    G31 K0 P5 Z-1.635 X0 Y0   		               			; K-probe number | P-set trigger value |  Z-trigger height - OptoTap triggers below 0
;   M99                                                     ; EXIT MACRO!

; --- CHECK TOOL 5 (CAN 25) ---
;M558 K0 P8 C"^25.io1.in" H5:4 F200:400 A5 S0.01 T24800 		; set Z probe type to Opto | H-Dive Height | F-Speed | A-Probe Tries | S-tolerance of probes
;G4 P250
;if sensors.probes[0].value[0] == 0
;    echo "Tool 5 discovered on shuttle."
;    T5 P0                                                   ; Silently select Tool 5
;    G31 K0 P5 Z-1.635 X0 Y0   		               			; K-probe number | P-set trigger value |  Z-trigger height - OptoTap triggers below 0
;    M99                                                     ; EXIT MACRO!

; --- IF NO TOOL IS FOUND ---
; If the script gets to this point, all sensors read 1000 (Empty)
echo "WARNING: No tool detected on the shuttle!"
M558 K0 P0                                                  ; Clear the probe mapping