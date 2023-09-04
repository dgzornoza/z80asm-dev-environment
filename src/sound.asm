; -------------------------------------------------------------------
; Sound.asm
; File with the sounds
; -------------------------------------------------------------------
; Point
C_3:    EQU $0D07
C_3_FQ: EQU $0082 / $10

; Paddle
C_4:    EQU $066E
C_4_FQ: EQU $0105 / $10

; Rebound
C_5:    EQU $0326
C_5_FQ: EQU $020B / $10

; -------------------------------------------------------------------
; ROM beeper routine.
;
; Input: HL -> Note.
;        DE -> Duration.
;
; Alters the value of the AF, BC, DE, HL and IX registers.
; -------------------------------------------------------------------
BEEPER: EQU $03B5

; -------------------------------------------------------------------
; Reproduces the sound of bouncing.
; Input: A -> Sound type: 1. Dot
;                         2. Paddle
;                         3. Border
; -------------------------------------------------------------------
PlaySound:
; Preserves the value of records
    push de
    push hl

    cp   $01                   ; Evaluates sound dot
    jr   z, playSound_point    ; Sound point? Jump

    cp   $02                   ; Evaluates sound shovel
    jr   z, playSound_paddle   ; Sound paddle? Jump

    ; The edge sound is emitted
    ld   hl, C_5               ; HL = note
    ld   de, C_5_FQ            ; DE = duration (frequency)
    jr   beep                  ; Jumps to beep

; The sound of Dot is emitted
playSound_point:
    ld   hl, C_3               ; HL = note
    ld   de, C_3_FQ            ; DE = duration (frequency)
    jr   beep                  ; Jumps to beep

; The paddle sound is emitted
playSound_paddle:
    ld   hl, C_4               ; HL = note
    ld   de, C_4_FQ            ; DE = duration (frequency)

; Sounds the note
beep:
    ; Preserves registers; ROM BEEPER routine alters them.
    push af
    push bc
    push ix

    call BEEPER                ; Call BEEPER from ROM

    ; Retrieves the value of the registers
    pop  ix
    pop  bc
    pop  af

    pop  hl
    pop  de

    ret
