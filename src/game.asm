;--------------------------------------------------------------------
; Assesses whether there is a collision between the ball 
; and the paddles.
; Alters the value of the AF, C and HL registers.
;--------------------------------------------------------------------
CheckBallCross:
ld   a, (ballSetting)      ; A = ball direction/speed
and  $40                   ; A = bit 6 (left/right)
jr   nz, checkBallCross_left ; Bit 6 = 1 goes left, skip

checkBallCross_right:
ld   c, CROSS_RIGHT        ; C = collision column		
call CheckCrossX           ; Collide X-axis?
ret  nz                    ; No collision, exits
ld   hl, (paddle2pos)      ; HL = paddle position 2
call CheckCrossY           ; Y-axis collision?
ret  nz                    ; No collision, exits

; If it gets here there is a collision
ld   a, $02
call PlaySound
ld   a, (ballSetting)      ; A = ball direction/speed
or   $40                   ; Change direction, left
ld   (ballSetting), a      ; Load to memory
ld   a, CROSS_LEFT_ROT     ; Change ball rotation
ld   (ballRotation), a     ; Load to memory
ret                        ; Sale

checkBallCross_left:
; Ball goes to the left
ld   c, CROSS_LEFT         ; C = collision column		
call CheckCrossX           ; Collide X-axis?
ret  nz                    ; No collision, exits
ld   hl, (paddle1pos)      ; HL = paddle position 1
call CheckCrossY           ; Y-axis collision?
ret  nz                    ; No collision, exits

; If it gets here there is a collision
ld   a, $02
call PlaySound
ld   a, (ballSetting)      ; A = ball direction/speed
and  $bf                   ; Change direction, right
ld   (ballSetting), a      ; Load to memory
ld   a, CROSS_RIGHT_ROT    ; Change ball rotation
ld   (ballRotation), a     ; Load to memory
ret                        ; Exits

;--------------------------------------------------------------------
; Evaluates whether the ball collides on the X-axis with the paddle.
; Input:	C -> Column where the collision occurs. 
; Exit:	Z -> Collide.
;		NZ -> No collision.
; Alters the value of the AF registers.
;--------------------------------------------------------------------
CheckCrossX:
ld   a, (ballPos)          ; A = line and column ball
and  $1f                   ; A = column
cp   c                     ; Is there a collision?

ret                        ; Exits

; -------------------------------------------------------------------
; Evaluates whether the ball collides in the Y-axis with the paddle.
; In the event of a collision, update the ball configuration.
; Input:  HL -> Shovel position	
; Output: Z  -> Collide.
;         NZ -> No collision.
; Alters the value of the AF, BC and HL registers.
; -------------------------------------------------------------------
CheckCrossY:
call GetPtrY               ; Vertical position spade (TTLLLLSSS)
; The position points to the first scanline of the paddle which is at 0
inc  a                     ; A = next scanline
ld   c, a                  ; C = A
ld   hl, (ballPos)         ; HL = ball position
call GetPtrY               ; Vertical position ball (TTLLLSSS)
ld   b, a                  ; B = A
; Check if the ball goes over the paddle
; The ball is composed of 1 scanline at 0, 4 at $3c and another at 0
; Position points to 1st scanline, check for collision with 5th scanline
add  a, $04                ; A = 5th scanline
sub  c                     ; A = ball position - paddle position
ret  c                     ; Carry? Out, ball passes over
; Check if the ball passes under the paddle
ld   a, c                  ; A = vertical position spade
add  a, $16                ; A = penultimate scanline, last != 0
ld   c, a                  ; C = A
ld   a, b                  ; A = vertical position ball
inc  a                     ; A = 1st scanline, first != 0
sub  c                     ; A = ball position - paddle position
jr   z, checkCrossY_eval   ; 0?, crash in last scanline
ret  nc                    ; No carriage? Pass underneath

; Depending on collision location, inclination and speed
checkCrossY_eval:
ld   a, c                  ; A = penultimate paddle scanline
sub  $15                   ; A = first scanline
ld   c, a                  ; C = A

ld   a, b                  ; A = ball position
add  a, $04                ; A = lower ball
ld   b, a                  ; B = A

checkCrossY_1_5:
ld   a, c                  ; A = vertical position paddle
add  a, $04                ; A = last scanline of 1/5
cp   b                     ; Compare with ball position
jr   c, checkCrossY_2_5    ; Carry? Ball is lower, jump
ld   a, (ballSetting)      ; A = ball configuration
and  $40                   ; A = horizontal direction
; or   $21                   ; up, speed 4 and diagonal
or   $19                   ; up, speed 3 and diagonal
jr   checkCrossY_end       ; End of routine

checkCrossY_2_5:
ld   a, c                  ; A = vertical position paddel
add  a, $09                ; A = last scanline of 2/5
cp   b                     ; Compare with ball position
jr   c, checkCrossY_3_5    ; Carry? Ball is lower, jump
ld   a, (ballSetting)      ; A = ball setting 
and  $40                   ; A = horizontal direction
; or   $1a                   ; up, speed 3 and semi-diagonal
or   $12                   ; up, speed 2 and semi-diagonal
jr   checkCrossY_end       ; End of routine

checkCrossY_3_5:
ld   a, c                  ; A = vertical position paddle
add  a, $0d                ; A = last scanline of 3/5
cp   b                     ; Compare with ball position
jr   c, checkCrossY_4_5    ; Carry? Ball is lower, jump
ld   a, (ballSetting)      ; A = ball configuration
and  $c0                   ; A = horizontal and vertical direction
; or   $17                   ; speed 2 and semi flat
or   $0f                   ; speed 1 and semi flat
jr   checkCrossY_end       ; End of routine

checkCrossY_4_5:
ld   a, c                  ; A = vertical position spade
add  a, $11                ; A = last scanline of 4/5
cp   b                     ; Compare with ball position
jr   c, checkCrossY_5_5    ; Carry? Ball is lower, jump
ld   a, (ballSetting)      ; A = ball configuration
and  $40                   ; A = horizontal and vertical direction
; or   $9a                   ; down, speed 3 and semi-diagonal
or   $92                   ; down, speed 2 and semi-diagonal
jr   checkCrossY_end       ; End of routine

checkCrossY_5_5:
ld   a, (ballSetting)      ; A = ball configuration
and  $40                   ; A = horizontal direction
; or   $a1                   ; down, speed 4 and diagonal
or   $99                   ; down, speed 3 and diagonal

; There is a collision
checkCrossY_end:
ld   (ballSetting), a      ; Load into memory ball configuration
xor  a                     ; Flag Z = 1, A = 0
ld   (ballMovCount), a     ; Ball movement counter = 0
ret

;--------------------------------------------------------------------
; Calculates the position, rotation and direction of the ball
; to paint it.
; Alters the value of the AF and HL registers.
;--------------------------------------------------------------------
MoveBall:
ld   a, (ballSetting)      ; A = ball direction and ball speed
and  $80                   ; Check vertical direction
jr   nz, moveBall_down     ; bit 7 = 1?, goes down

moveBall_up:
; Ball goes up
ld   hl, (ballPos)         ; HL = ball position
ld   a, BALL_TOP           ; A = upper margin
call CheckTop              ; Reached top margin?
jr   z, moveBall_upChg     ; If reached, jumps
call MoveBallY
jr   nz, moveBall_x
call PreviousScan          ; Scanline previous to ball position
ld   (ballPos), hl         ; Loads new ball position into memory
jr   moveBall_x            ; Jump

moveBall_upChg:
; Ball goes up, has reached the stop and changes direction
ld   a, $03
call PlaySound
ld   a, (ballSetting)      ; A = ball direction and velocity
or   $80                   ; Vertical direction = down
ld   (ballSetting), a      ; Load new address ball into memory
call NextScan              ; Scanline next to ball position
ld   (ballPos), hl         ; Loads new ball position into memory
jr   moveBall_x            ; Jump

moveBall_down:
; Ball goes down
ld   hl, (ballPos)         ; HL = ball position
ld   a, BALL_BOTTOM        ; A = upper margin
call CheckBottom           ; Reached upper margin?
jr   z, moveBall_downChg   ; If reached jumps
call MoveBallY
jr   nz, moveBall_x
call NextScan              ; Scanline next to ball position
ld   (ballPos), hl         ; Loads new ball position into memory
jr   moveBall_x            ; Jump

moveBall_downChg:
; Ball goes down, has reached the stop and changes direction
ld   a, $03
call PlaySound
ld   a, (ballSetting)      ; A = ball direction and ball velocity
and  $7f                   ;Vertical direction = up
ld   (ballSetting), a      ; Load new address ball into memory
call PreviousScan          ; Scanline previous to ball position
ld   (ballPos), hl         ; Loads new ball position into memory

moveBall_x:
ld   a, (ballSetting)      ; A = ball direction and ball velocity
and  $40                   ; Check horizontal direction
jr   nz, moveBall_left     ; bit 6 = one? goes to the left

moveBall_right:
; Ball goes to the right
ld   a, (ballRotation)     ; A = ball rotation
cp   $08                   ; Last rotation?
jr   z, moveBall_rightLast ; If last rotation skip
inc  a                     ; Increases turnover 
ld   (ballRotation), a     ; Loading into memory
ret                        ; End of routine

moveBall_rightLast:
; He is in the last rotation
; If you have not reached the right limit, set the rotation to 1
; and puts the ball in the next column
ld   a, (ballPos)          ; A = line and column ball
and  $1f                   ; Remains with column
cp   MARGIN_RIGHT          ; Buy with right boundary
jr   z, moveBall_rightChg  ; Reached, skip
ld   hl, ballPos           ; HL = ball position
inc  (hl)                  ; Increments column
ld   a, $01                ; Set rotation to 1
ld   (ballRotation), a     ; Load value into memory
ret                        ; End of routine

moveBall_rightChg:
; You have reached the right limit, POINT!
ld   a, $01
call PlaySound
ld   hl, p1points          ; HL = score address player 1
inc  (hl)                  ; Increases score
call PrintPoints           ; Paint marker
call ClearBall             ; Clears ball
call SetBallLeft           ; Set ball to left
ld   a, $03
call PlaySound
ret                        ; End routine

moveBall_left:
; Ball goes to the left
ld   a, (ballRotation)     ; A = current ball rotation
cp   $f8                   ; Last rotation?
jr   z, moveBall_leftLast  ; If last rotation skip
dec  a                     ; Decreasing rotation 
ld   (ballRotation), a     ; Loading into memory
ret                        ; End of routine

moveBall_leftLast:
; He is in the last rotation
; If you have not reached the left limit, set the rotation to -1
; and puts the ball in the previous column
ld   a, (ballPos)          ; A = row and column
and  $1f                   ; It remains only with column
cp   MARGIN_LEFT           ; Left boundary?
jr   z, moveBall_leftChg   ; If it has reached it, it jumps
ld   hl, ballPos           ; HL = ball position address
dec  (hl)                  ; Goes to previous column
ld   a, $ff                ; Set rotation to -1
ld   (ballRotation), a     ; Load value into memory
ret                        ; End of routine

moveBall_leftChg:
; You have reached the left limit, POINT!
ld   a, $01
call PlaySound
ld   hl, p2points          ; HL = address score player 2
inc  (hl)                  ; Increments marker
call PrintPoints           ; Paint marker
call ClearBall             ; Clears ball
call SetBallRight          ; Set ball right
ld   a, $03
call PlaySound
ret

; -------------------------------------------------------------------
; Changes the Y position of the ball
; Alters the value of the AF and D registers.
; -------------------------------------------------------------------
MoveBallY:
ld   a, (ballSetting)      ; A = ball configuration
and  $07                   ; A = inclination
ld   d, a                  ; D = A

ld   a, (ballMovCount)     ; A = accumulated ball movements
inc  a                     ; A = A + 1
ld   (ballMovCount), a     ; Loads value into memory
cp   d                     ; Compare with inclination
ret  nz                    ; Different? Exit, no change of position

; The position must change
xor  a                     ; A = 0, flag Z = 1
ld   (ballMovCount), a     ; Accumulated ball movements = 0

ret

;--------------------------------------------------------------------
; Calculate the position of the blades to move them.
; Input: D -> Controls keystrokes
; Alters the value of the AF and HL registers.
;--------------------------------------------------------------------
MovePaddle:
bit  $00, d                ; A pressed?
jr   z, movePaddle_1Down   ; Not pressed, skip
ld   hl, (paddle1pos)      ; HL = paddle position 1
ld   a, PADDLE_TOP         ; A = top margin
call CheckTop              ; Reached top margin?
jr   z, movePaddle_2Up     ; Reached, skip
call PreviousScan          ; Scanline previous to position spade 1
ld   (paddle1pos), hl      ; Load new position paddle 1 into memory
jr   movePaddle_2Up        ; Jump

movePaddle_1Down:
bit  $01, d                ; Z pressed?
jr   z, movePaddle_2Up     ; Not pressed, skip
ld   hl, (paddle1pos)      ; HL = paddle position 1
ld   a, PADDLE_BOTTOM      ; A = bottom margin
call CheckBottom           ; Reached bottom margin?
jr   z, movePaddle_2Up     ; Reached, skip
call NextScan              ; Scanline next to position spade 1
ld   (paddle1pos), hl      ; Load new position paddle 1 into memory

movePaddle_2Up:
bit  $02, d                ; 0 pressed?
jr   z, movePaddle_2Down   ; Not pressed, skip
ld   hl, (paddle2pos)      ; HL = paddle position 2
ld   a, PADDLE_TOP         ; A = top margin
call CheckTop              ; Reached top margin?
jr   z, movePaddle_End     ; Reached, skip
call PreviousScan          ; Scanline previous to position spade 2
ld   (paddle2pos), hl      ; Loads new paddle position 2 to memory
jr   movePaddle_End        ; Jump

movePaddle_2Down:
bit  $03, d                ; Or pressed?
jr   z, movePaddle_End     ; Not pressed, skip
ld   hl, (paddle2pos)      ; HL = paddle position 2
ld   a, PADDLE_BOTTOM      ; A = bottom margin
call CheckBottom           ; Reached bottom margin?
jr   z, movePaddle_End     ; Reached, skip
call NextScan              ; Scanline next to position spade 2
ld   (paddle2pos), hl      ; Loads new paddle position 2 to memory

movePaddle_End:
ret

; -------------------------------------------------------------------
; Position the ball to the left.
; Alters the value of the AF and HL registers.
; -------------------------------------------------------------------
SetBallLeft:
ld   hl, $4d60             ; HL = ball position
ld   (ballPos), hl         ; Load value into memory
ld   a, $01                ; A = 1
ld   (ballRotation), a     ; Rotation = 1
ld   a, (ballSetting)      ; A direction and velocity ball
and  $80                   ; A = Y-direction
; or   $21                   ; X right, speed 4 and diagonal
or   $19                   ; X right, speed 3 and diagonal
ld   (ballSetting), a      ; New ball address in memory
ld   a, $00                ; A = 0
ld   (ballMovCount), a     ; Ball movement counter = 0

ret

; -------------------------------------------------------------------
; Position the ball to the right.
; Alters the value of the AF and HL registers.
; -------------------------------------------------------------------
SetBallRight:
ld   hl, $4d7e             ; HL = ball position
ld   (ballPos), hl         ; Load value into memory
ld   a, $ff                ; A = -1
ld   (ballRotation), a     ; Rotation = -1
ld   a, (ballSetting)      ; A = ball direction and velocity
and  $80                   ; A = Y-direction
; or   $61                   ; X left, speed 4 and diagonal
or   $59                   ; X left, speed 3 and diagonal
ld   (ballSetting), a      ; New ball address in memory
ld   a, $00                ; A = 0
ld   (ballMovCount), a     ; Ball movement counter = 0

ret
