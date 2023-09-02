BORDCR:	EQU $5c48

;--------------------------------------------------------------------
; Evaluates whether the lower limit has been reached.
; Input:  A  -> Upper limit (TTLLLLSSS).
;         HL -> Current position (010TTSSS LLLCCCCCCC).
; Output: Z  =  Reached.
;         NZ =  Not reached.
;
; Alters the value of the AF and BC registers.
;--------------------------------------------------------------------
CheckBottom:
call checkVerticalLimit    ; Compare current position with limit
; If Z or NC has reached the ceiling, Z is set, otherwise NZ is set.
ret c
checkBottom_bottom:
xor a                      ; Active Z
ret

;--------------------------------------------------------------------
; Evaluates whether the upper limit has been reached.
; Input:  A  -> Upper margin (TTLLLLSSS).
;         HL -> Current position (010TTSSS LLLCCCCCCC).
; Output: Z  =  Reached.
;         NZ =  Not reached.
;
; Alters the value of the AF and BC registers.
;--------------------------------------------------------------------
CheckTop:
call checkVerticalLimit    ; Compare current position with limit
ret                        ; checkVerticalLimit is enough

;--------------------------------------------------------------------
; Evaluates whether the vertical limit has been reached.
; Input: A  -> Vertical limit (TTLLLLSSS).
;        HL -> Current position (010TTSSS LLLCCCCCCC).
; Alters the value of the AF and BC registers.
;--------------------------------------------------------------------
checkVerticalLimit:
ld   b, a                  ; B = A
call GetPtrY               ; Y-coordinate (TTLLLSSSS)
                           ; of the current position
cp   b                     ; A = B? B = value A = vertical limit
ret

;--------------------------------------------------------------------
; Delete the ball.
; Alters the value of the AF, B and HL registers.
;--------------------------------------------------------------------
ClearBall:
ld   hl, (ballPos)         ; HL = ball position
ld   a, l                  ; A = row and column
and  $1f                   ; A = column
cp   $10                   ; Compare with centre display
jr   c, clearBall_continue ; If carry, jump, is on left
inc  l                     ; It is in right, increase column
clearBall_continue:
ld   b, $06                ; Loop 6 scanlines
clearBall_loop:				
ld   (hl), ZERO            ; Deletes byte pointed to by HL
call NextScan              ; Next scanline
djnz clearBall_loop        ; Until B = 0

ret

; -------------------------------------------------------------------
; Clean screen, ink 7, background 0.
; Alters the value of the AF, BC, DE and HL registers.
; -------------------------------------------------------------------
Cls:
; Clean the pixels on the screen
ld   hl, $4000             ; HL = start VideoRAM
ld   (hl), $00             ; Clear pixels from that address
ld   de, $4001             ; DE = next VideoRAM address
ld   bc, $17ff             ; 6143 repetitions
ldir                       ; Clears VideoRAM pixels

; Sets the ink to white and the background to black
ld    a, $07               ; Black background, white ink
inc  hl                    ; HL = start attribute area
ld   (hl), a               ; White ink, black background
inc  de                    ; DE = next address attribute area
ld   bc, $2ff              ; 767 repetitions
ldir                       ; Assigns value to attribute area
ld   (BORDCR), a

ret

;--------------------------------------------------------------------
; Gets third, line and scanline of a memory location.
; Input:  HL -> Memory location.
; Output: A  -> Third, line and scanline obtained.
; Alters the value of the AF and E registers.
;--------------------------------------------------------------------
GetPtrY:
ld   a, h                  ; A = H (third and scanline)
and  $18                   ; A = third
rlca
rlca
rlca                       ; Passes value of third to bits 6 and 7
ld   e, a                  ; E = A
ld   a, h                  ; A = H (third and scanline)
and  $07                   ; A = scanline
or   e                     ; A OR E = Tercio and scanline
ld   e, a                  ; E = A = TT000SSS
ld   a, l                  ; A = L (row and column)
and  $e0                   ; A = line
rrca		
rrca                       ; Passes line value to bits 3 to 5
or   e                     ; A OR E = TTLLLLSSS

ret

; -------------------------------------------------------------------
; Gets the corresponding sprite to paint on the marker.
; Input:  A  -> score.
; Output: HL -> address of the sprite to be painted.
; Alters the value of the AF, BC and HL registers.
; -------------------------------------------------------------------
GetPointSprite:
; UP TO 61 POINTS
ld   hl, Zero              ; HL = address sprite Zero
; Each sprite is 4 bytes from the previous one
add  a, a                  ; A = A * 2
add  a, a                  ; A = A * 2 ( A * 4)
ld   b, ZERO
ld   c, a                  ; BC = A
add  hl, bc                ; HL = HL + BC = sprite to be painted

; ; UP TO 99 WITHOUT CHANGING MARKER PRINT ROUTINE
; ld   h, ZERO
; ld   l, a                  ; HL = points
; ; Each sprite is 4 bytes from the previous one.
; add  hl, hl                ; HL = HL * 2
; add  hl, hl                ; HL = HL * 2 (HL * 4)
; ld   bc, Zero              ; BC = sprite address Zero
; add  hl, bc                ; HL = HL + BC (sprite to be painted)

ret

;------------------------------------------------------------------
; NextScan
; https://wiki.speccy.org/cursos/ensamblador/gfx2_direccionamiento
; Gets the memory location corresponding to the scanline.
; The next to the one indicated.
;     010T TSSS LLLC CCCC
; Input:  HL -> current scanline.
; Output: HL -> scanline next.
; Alters the value of the AF and HL registers.
;------------------------------------------------------------------
NextScan:
inc  h                     ; Increment H to increase the scanline
ld   a, h                  ; Load the value in A
and  $07                   ; Keeps the bits of the scanline
ret  nz                    ; If the value is not 0, end of routine  

; Calculate the following line
ld   a, l                  ; Load the value in A
add  a, $20                ; Add one to the line (%0010 0000)
ld   l, a                  ; Load the value in L
ret  c                     ; If there is a carry-over, it has changed
                           ; its position, the top is already adjusted 
                           ; from above. End of routine.

; If you get here, you haven't changed your mind and you have to adjust 
; as the first inc h increased it.
ld   a, h                  ; Load the value in A
sub  $08                   ; Subtract one third (%0000 1000)
ld   h, a                  ; Load the value in H
ret

; -----------------------------------------------------------------
; PreviousScan
; https://wiki.speccy.org/cursos/ensamblador/gfx2_direccionamiento
; Gets the memory location corresponding to the scanline.
; The following is the first time this has been done; prior 
; to that indicated.
;     010T TSSS LLLC CCCC
; Input:  HL -> current scanline.	    
; Output: HL -> previous scanline.
; Alters the value of the AF, BC and HL registers.
;------------------------------------------------------------------
PreviousScan:
ld   a, h                  ; Load the value in A
dec  h                     ; Decrements H to decrement the scanline
and  $07                   ; Keeps the bits of the original scanline
ret  nz                    ; If not at 0, end of routine

; Calculate the previous line
ld   a, l                  ; Load the value of L into A
sub  $20                   ; Subtract one line
ld   l, a                  ; Load the value in L
ret  c                     ; If there is carry-over, end of routine

; If you arrive here, you have moved to scanline 7 of the previous line
; and subtracted a third, which we add up again
ld   a, h                  ; Load the value of H into A
add  a, $08                ; Returns the third to the way it was
ld   h, a                  ; Load the value in h
ret

;--------------------------------------------------------------------
; Paint the ball.
; Alters the value of the AF, BC, DE and HL registers.
;--------------------------------------------------------------------
PrintBall:
ld   b, $00                ; B = 0
ld   a, (ballRotation)     ; A = ball rotation, what to paint?
ld   c, a                  ; C = A
cp   $00                   ; Compare with 0, see where it rotates to
ld   a, $00                ; A = 0
jp   p, printBall_right    ; If positive jumps, rotates to right

printBall_left:
; The rotation of the ball is to the left
ld   hl, ballLeft          ; HL = address bytes ball
sub  c                     ; A = A-C, ball rotation
add  a, a                  ; A = A+A, ball = two bytes
ld   c, a                  ; C = A
sbc  hl, bc                ; HL = HL-BC (ball offset)
jr   printBall_continue

printBall_right:
; Ball rotation is clockwise
ld   hl, ballRight         ; HL = address bytes ball
add  a, c                  ; A = A+C, ball rotation
add  a, a                  ; A = A+A, ball = two bytes
ld   c, a                  ; C = A
add  hl, bc                ; HL = HL+BC (ball offset)

printBall_continue:
; The address of the ball definition is loaded in DE.
ex   de, hl
ld   hl, (ballPos)         ; HL = ball position

; Paint the first line in white
ld   (hl), ZERO            ; Moves target to screen position
inc  l                     ; L = next column
ld   (hl), ZERO            ; Moves target to screen position
dec  l                     ; L = previous column
call NextScan              ; Next scanline

ld   b, $04                ; Paint ball in next 4 scanlines
printBall_loop:
ld   a, (de)               ; A = byte 1 definition ball
ld   (hl), a               ; Load ball definition on screen
inc  de                    ; DE = next byte definition ball
inc  l                     ; L = next column
ld   a, (de)               ; A = byte 2 definition ball
ld   (hl), a               ; Load ball definition on screen
dec  de                    ; DE = first byte definition ball
dec  l                     ; L = previous column
call NextScan              ; Next scanline
djnz printBall_loop        ; Until B = 0

; Paint the last blank line
ld   (hl), ZERO            ; Moves target to screen position
inc  l                     ; L = next column
ld   (hl), ZERO            ; Moves target to screen position

ret

;--------------------------------------------------------------------
; Paint the edge of the field.
; Alters the value of AD, B, DE and HL registers.
;--------------------------------------------------------------------
PrintBorder:
ld   hl, $4100             ; HL = third 0, line 0, scanline 1
ld   de, $56e0             ; DE = third 2, line 7, scanline 6
ld   b, $20                ; B = 32 to be painted
ld   a, FILL               ; Load the byte to be painted into A

printBorder_loop:
ld   (hl), a               ; Paints direction pointed by HL
ld   (de), a               ; Paints address pointed by DE
inc  l                     ; HL = next column
inc  e                     ; DE = next column
djnz printBorder_loop      ; Loop until B reaches 0
ret

;--------------------------------------------------------------------
; Prints the centre line.
; Alters the value of the AF, B and HL registers.
;--------------------------------------------------------------------
PrintLine:
ld   b, $18                ; Prints on all 24 lines of the screen
ld   hl, $4010             ; Starts on line 0, column 16

printLine_loop:
ld   (hl), ZERO            ; In the first scanline it prints blank
inc  h                     ; Go to the next scanline

push bc                    ; Preserves BC value for second loop
ld   b, $06                ; Prints six times
printLine_loop2:
ld   (hl), LINE            ; Print byte the line, $10, b00010000
inc  h                     ; Go to the next scanline
djnz printLine_loop2       ; Loop until B = 0
pop  bc                    ; Retrieves value BC
ld   (hl), ZERO            ; Print last byte of the line
call NextScan              ; Goes to the next scanline
djnz printLine_loop        ; Loop until B = 0 = 24 lines
ret

; -------------------------------------------------------------------
; Repaint the centre line.
; Alters the value of the AF, B and HL registers.
; -------------------------------------------------------------------
ReprintLine:
ld   hl, (ballPos)         ; HL = ball position
ld   a, l                  ; A = row and column
and  $e0                   ; A = line
or   $10                   ; A = row and column 16 ($10)
ld   l, a                  ; L = A. HL = Initial position

ld   b, $06                ; Repaints 6 scanlines
reprintLine_loop:
ld   a, h                  ; A = third and scanline
and  $07                   ; A = scanline
; If it is on scanlines 0 or 7, it paints ZERO.
; If you are on scanlines 1, 2, 3, 4, 5 or 6, paint LINE.
cp   $01                   ; Scanline 1?
jr   c, reprintLine_loopCont ; Scanline < 1, skip
cp   $07                   ; Scanline 7?
jr   z, reprintLine_loopCont ; Scanline = 7, skip

ld   a, (hl)               ; A = pixels current position
or   LINE                  ; Add LINE
ld   (hl), a               ; Paints current position
reprintLine_loopCont:
call NextScan              ; Get next scan line
djnz reprintLine_loop      ; Until B = 0

ret

;--------------------------------------------------------------------
; Print the paddle.
; Input: HL -> paddle position.
;
; Alters the value of the B and HL registers.
;--------------------------------------------------------------------
PrintPaddle:
ld   (hl), ZERO            ; Prints first byte of blank paddle
call NextScan              ; Goes to the next scanline
ld   b, $16                ; Paints visible byte of spade 22 times
printPaddle_loop:
ld   (hl), c               ; Prints the paddle byte
call NextScan              ; Goes to the next scanline

djnz printPaddle_loop      ; Loop until B = 0

ld   (hl), ZERO            ; Prints last byte of blank paddle

ret

; -------------------------------------------------------------------
; Paint the scoreboard.
; Each number is 1 byte wide by 16 bytes high.
; Alters the value of the AF, BC, DE and HL registers.
; -------------------------------------------------------------------
PrintPoints:
call printPoint_1_print    ; Paints marker player 1
jr   printPoint_2_print    ; Paints marker player 2

printPoint_1_print:		
ld   a, (p1points)         ; A = points player 1
call GetPointSprite        ; Sprite to be painted on marker
; 1st digit of player 1
ld   e, (hl)               ; E = lower part 1st digit address
inc  hl                    ; HL = high side
ld   d, (hl)               ; D = upper part
push hl                    ; Preserves HL
ld   hl, POINTS_P1         ; HL = address where to paint digit
call PrintPoint            ; Paints 1st digit	
pop  hl                    ; Retrieves HL

; 2nd digit of player 1	
inc  hl                    ; HL = low part 2nd digit address
ld   e, (hl)               ; E = lower part 
inc  hl                    ; HL = high part
ld   d, (hl)               ; D = upper part
; Spirax
ld   hl, POINTS_P1 + 1     ; HL = address where to paint digit 
call PrintPoint            ; Paint2 2nd digit

ret

printPoint_2_print:	
; 1st digit of player 2
ld   a, (p2points)         ; A = points player 2
call GetPointSprite        ; Sprite to be painted on marker
ld   e, (hl)               ; E = low part 1st digit address
inc  hl                    ; HL = high part
ld   d, (hl)               ; D = upper part
push hl                    ; Preserves HL
ld   hl, POINTS_P2         ; HL = address where digit
call PrintPoint            ; Paints 1st digit
pop  hl                    ; Retrieves HL

; 2nd digit of player 2	
inc  hl                    ; HL = low part 2nd digit address
ld   e, (hl)               ; E = lower part
inc  hl                    ; HL = high part
ld   d, (hl)               ; D = upper part
; Spirax
ld   hl, POINTS_P2 + 1     ; HL address where to paint 2nd digit
; Paints the second digit of player 2's marker.

PrintPoint:
ld   b, $10                ; Each digit 1 byte by 16 (scanlines)

printPoint_printLoop:
ld   a, (de)               ; A = byte to be painted
ld   (hl), a               ; Paints the byte
inc  de                    ; DE = next byte
call NextScan              ; HL = next scanline
djnz printPoint_printLoop  ; Until B = 0

ret

; -------------------------------------------------------------------
; Repaint the scoreboard.
; Each number is 1 byte wide by 16 bytes high.
; Alters the value of the AF, BC, DE and HL registers.
; -------------------------------------------------------------------
ReprintPoints:
ld   hl, (ballPos)         ; HL = ball position
call GetPtrY               ; Third, line and scanline ball 	position
cp   POINTS_Y_B            ; Compare lower limit marker
ret  nc                    ; No Carry? Pass underneath
ld   a, l                  ; A = line and column ball position
and  $1f                   ; A = column
cp   POINTS_X1_L           ; Compare left boundary marker 1
ret  c                     ; Carry? Pass left
jr   z, printPoint_1_print ; 0? It's in left margin, paint

cp   POINTS_X2_R           ; Compare right boundary marker 2
jr   z, printPoint_2_print ; 0? It's in the right margin, paint
ret  nc                    ; No Carry? Pass on the right

reprintPoint_1:
cp   POINTS_X1_R           ; Compare right boundary marker 1
jr   z, printPoint_1_print	
jr   c, printPoint_1_print ; Z or Carry? Pass marker 1, paint
 
reprintPoint_2:					
cp   POINTS_X2_L           ; Compare right boundary marker 2
ret  c                     ; Carry? Pass on the left
; Spirax
jr   printPoint_2_print    ; Paint marker player 2
