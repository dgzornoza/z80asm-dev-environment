;-------------------------------------------
; SJASMPLUS CONFIGURATIONS
;-------------------------------------------

    SLDOPT COMMENT WPMEM, LOGPOINT, ASSERTION
    DEVICE ZXSPECTRUM48
    ;DEVICE ZXSPECTRUM128    
    ;DEVICE NOSLOT64K

;===========================================================================
; Include main module
;===========================================================================
    include "main.asm"

;===========================================================================
; SJASMPLUS Define Stack
;===========================================================================

; Stack: this area is reserved for the stack
STACK_SIZE: equ 100    ; in words


; Reserve stack space
    defw 0  ; WPMEM, 2
stack_bottom:
    defs    STACK_SIZE*2, 0
stack_top:
    defw 0  ; WPMEM, 2


    ; SET Program name
    SAVESNA "build/output.sna", Main
    SAVETAP "build/output.tap", $5e88
