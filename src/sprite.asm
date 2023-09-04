ZERO:          EQU $00
FILL:	       EQU $ff
LINE:          EQU $80

; Limits of the objects on the screen
BALL_BOTTOM:   EQU $b8     ; TTLLLSSS
BALL_TOP:      EQU $02     ; TTLLLLLSSSSS
CROSS_LEFT:    EQU $01
CROSS_RIGHT:   EQU $1d
CROSS_LEFT_ROT:  EQU $ff
CROSS_RIGHT_ROT: EQU $01
MARGIN_LEFT:   EQU $00
MARGIN_RIGHT:  EQU $1e
PADDLE_BOTTOM: EQU $a6     ; TTLLLSSS
PADDLE_TOP:    EQU $02     ; TTLLLLLSSSSS

; Ball sprite:
;     1 line at 0, 4 lines 3c, 1 line at 0
ballRight:     ;  Right        Sprite         Left
    db $3c, $00    ; +0/$00 00111100    00000000 -8/$f8
    db $1e, $00    ; +1/$01 00011110    00000000 -7/$f9
    db $0f, $00    ; +2/$02 00001111    00000000 -6/$fa
    db $07, $80    ; +3/$03 00000111    10000000 -5/$fb
    db $03, $c0    ; +4/$04 00000011    11000000 -4/$fc
    db $01, $e0    ; +5/$05 00000001    11100000 -3/$fd
    db $00, $f0    ; +6/$06 00000000    11110000 -2/$fe
    db $00, $78    ; +7/$07 00000000    01111000 -1/$ff
ballLeft:
    db $00, $3c    ; +8/$08 00000000    00111100 +0/$00

; Ball position
BALLPOS_INI:  EQU $4850
ballPos:      dw $4870     ; 010T TSSS LLLC CCCC
ballMovCount: db $00

; Ball speed and direction.
; bits 0 to 2:  Ball movements to change the Y position. 
;               Values 7 = half-plane, 2 = half-diagonal, 1 = diagonal
; bits 3 to 5:  ball speed: 2 very fast, 3 fast, 4 slow
; bit 6:        X direction: 0 right / 1 left
; bit 7:        Y direction: 0 up / 1 down
; ballSetting:   db $21      ; 0010 0001
ballSetting:   db $19      ; 0001 1001
; Ball rotation
; Positive values right, negative values left
ballRotation:  db $f8

; PADDLE:        EQU$3c
PADDLE1:       EQU $0f
PADDLE2:       EQU $f0
PADDLE1POS_INI:EQU $4861
PADDLE2POS_INI:EQU $487e
paddle1pos:    dw  $4861   ; 010T TSSS LLLC CCCC
paddle2pos:    dw  $487e   ; 010T TSSS LLLC CCCC

POINTS_P1:     EQU $450d
POINTS_P2:     EQU $4511
POINTS_X1_L:   EQU $0c
POINTS_X1_R:   EQU $0f
POINTS_X2_L:   EQU $10
POINTS_X2_R:   EQU $13
POINTS_Y_B:    EQU $14

White_sprite:
    ds $10	; 16 spaces = 16 bytes at $00

Zero_sprite:
    db $00, $7e, $7e, $66, $66, $66, $66, $66
    db $66, $66, $66, $66, $66, $7e, $7e, $00

One_sprite:
    db $00, $18, $18, $18, $18, $18, $18, $18
    db $18, $18, $18, $18, $18, $18, $18, $00

Two_sprite:
    db $00, $7e, $7e, $06, $06, $06, $06, $7e
    db $7e, $60, $60, $60, $60, $7e, $7e, $00

Three_sprite:
    db $00, $7e, $7e, $06, $06, $06, $06, $3e
    db $3e, $06, $06, $06, $06, $7e, $7e, $00

Four_sprite:
    db $00, $66, $66, $66, $66, $66, $66, $7e
    db $7e, $06, $06, $06, $06, $06, $06, $00

Five_sprite:
    db $00, $7e, $7e, $60, $60, $60, $60, $7e
    db $7e, $06, $06, $06, $06, $7e, $7e, $00

Six_sprite:
    db $00, $7e, $7e, $60, $60, $60, $60, $7e
    db $7e, $66, $66, $66, $66, $7e, $7e, $00

Seven_sprite:
    db $00, $7e, $7e, $06, $06, $06, $06, $06
    db $06, $06, $06, $06, $06, $06, $06, $00

Eight_sprite:
    db $00, $7e, $7e, $66, $66, $66, $66, $7e
    db $7e, $66, $66, $66, $66, $7e, $7e, $00

Nine_sprite:
    db $00, $7e, $7e, $66, $66, $66, $66, $7e
    db $7e, $06, $06, $06, $06, $7e, $7e, $00

Zero:
    dw White_sprite, Zero_sprite

One:
    dw White_sprite, One_sprite

Two:
    dw White_sprite, Two_sprite

Three:
    dw White_sprite, Three_sprite

Four:
    dw White_sprite, Four_sprite

Five:
    dw White_sprite, Five_sprite

Six:
    dw White_sprite, Six_sprite

Seven:
    dw White_sprite, Seven_sprite

Eight:
    dw White_sprite, Eight_sprite

Nine:
    dw White_sprite, Nine_sprite

Ten:
    dw One_sprite, Zero_sprite

Eleven:
    dw One_sprite, One_sprite

Twelve:
    dw One_sprite, Two_sprite

Thirteen:
    dw One_sprite, Three_sprite

Fourteen:
    dw One_sprite, Four_sprite

Fifteen:
    dw One_sprite, Five_sprite
