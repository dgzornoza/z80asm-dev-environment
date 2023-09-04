;--------------------------------------------------------------------
; ScanKeys
; Scans the control keys and returns the pressed keys.
; Output: D -> Keys pressed.
;         Bit 0 -> A pressed 0/1.
;         Bit 1 -> Z pressed 0/1.
;         Bit 2 -> 0 pressed 0/1.
;         Bit 3 -> O pressed 0/1.
; Alters the value of the AF and D registers.
;--------------------------------------------------------------------
ScanKeys:
    ld   d, $00                ; D = 0

scanKeys_A:
    ld   a, $fd                ; Load in A the A-G half-stack
    in   a, ($fe)              ; Read status of the semi-stack
    and  $01                   ; Checks if the A has been pressed
    jr   nz, scanKeys_Z        ; If not clicked, skips
    set  $00, d                ; Set the bit corresponding to A to one

scanKeys_Z:
    ld   a, $fe                ; Load in A the CS-V half-stack
    in   a, ($fe)              ; Read status of the half-stack
    and  $02                   ; Checks whether Z has been pressed
    jr   nz, scanKeys_0        ; If not clicked, skips
    set  $01, d                ; Sets the bit corresponding to Z to one

    ; Check that the two arrow keys have not been pressed
    ld   a, d                  ; Load the value of D into A
    sub  $03                   ; Checks whether A and Z have been pressed
                            ; at the same time
    jr   nz, scanKeys_0        ; If not pressed, skips
    ld   d, a                  ; Sets D to zero

scanKeys_0:
    ld   a, $ef                ; Load the half-stack 0-6
    in   a, ($fe)              ; Read status of the semi-stack
    and  $01                   ; Checks if 0 has been pressed
    jr   nz, scanKeys_O        ; If not pressed, skip
    set  $02, d                ; Set the bit corresponding to 0 to a one

scanKeys_O:
    ld   a, $cf                ; Load the P-Y half-stack
    in   a, ($fe)              ; Read status of the semi-stack
    and  $02                   ; Checks if the O has been pressed
    ret  nz                    ; If not pressed, jumps to
    set  $03, d                ; Sets the bit corresponding to O to one

    ; Check that the two arrow keys have not been pressed
    ld   a, d                  ; Load the value of D into A
    and  $0c                   ; Keeps the 0 and O bits
    cp   $0c                   ; Check if the two keys have been pressed
    ret  nz                    ; If they have not been pressed, it exits
    ld   a, d                  ; Pressed, loads the value of D in A
    and  $03                   ; Takes the bits of A and Z
    ld   d, a                  ; Load the value in D

    ret

;--------------------------------------------------------------------
; WaitStart.
; Wait for the 5 key to be pressed to start the game.
; Alters the value of the AF register.
;--------------------------------------------------------------------
WaitStart:
    ld   a, $f7                ; A = half-row 1-5
    in   a, ($fe)              ; Read keyboard
    bit  $04, a                ; 5 pressed?
    jr   nz, WaitStart         ; Not pressed, loop

    ret
