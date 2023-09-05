;===========================================================================
; main routine - the code execution starts here.
; Sets up the new interrupt routine, the memory
; banks and jumps to the start loop.
;===========================================================================

    org  $5e88

Main:
    ld   a, $00                ; A = 0
    out  ($fe), a              ; Black border

    call Cls                   ; Clear screen
    call PrintLine             ; Print centre line
    call PrintBorder           ; Print field border
    call PrintPoints
    call WaitStart
    ld   a, ZERO
    ld   (p1points), a
    ld   (p2points), a
    call PrintPoints
    ld   hl, BALLPOS_INI
    ld   (ballPos), hl
    ld   hl, PADDLE1POS_INI
    ld   (paddle1pos), hl
    ld   hl, PADDLE2POS_INI
    ld   (paddle2pos), hl
    ld   a, $03
    call PlaySound

Loop:
    ld   a, (ballSetting)
    rrca
    rrca
    rrca
    and  $07
    ld   b, a
    ld   a, (countLoopBall)    ; A = countLoopsBall	
    inc  a                     ; It increases it
    ld   (countLoopBall), a    ; Load to memory
    cp   b                     ; Counter = 2?
    jr   nz, loop_paddle       ; Counter != 2, skip
    call MoveBall              ; Move ball
    ld   a, ZERO               ; A = 0
    ld   (countLoopBall), a    ; Counter = 0

loop_paddle:
    ld   a, (countLoopPaddle)  ; A = count number of paddle turns
    inc  a                     ; It increases it
    ld   (countLoopPaddle), a  ; Load to memory
    cp   $02                   ; Counter = 2?
    jr   nz, loop_continue     ; Counter != 2, skip
    call ScanKeys              ; Scan for keystrokes
    call MovePaddle            ; Move paddles
    ld   a, ZERO               ; A = 0
    ld   (countLoopPaddle), a  ; Counter = 0

loop_continue:
    call CheckBallCross        ; Checks for collision between ball
                            ; and paddles
    call PrintBall             ; Paint ball
    call ReprintLine           ; Reprint line
    call ReprintPoints
    ld   hl, (paddle1pos)      ; HL = paddle 1 position
    ld   c, PADDLE1
    call PrintPaddle           ; Paint paddle 1
    ld   c, PADDLE2
    ld   hl, (paddle2pos)      ; HL = paddle 2 position
    call PrintPaddle           ; Paint paddle 2
    ld   a, (p1points)
    cp   $0f
    jp   z, Main
    ld   a, (p2points)
    cp   $0f
    jp   z, Main
    jp   Loop                   ; Infinite loop



;===========================================================================
; Include modules
;===========================================================================
    include "game.asm"
    include "controls.asm"
    include "sound.asm"
    include "sprite.asm"
    include "video.asm"

countLoopBall:   db $00    ; Count turns ball
countLoopPaddle: db $00    ; Count turns paddles
p1points:        db $00
p2points:        db $00
