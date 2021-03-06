        .include "via.inc"
        .include "zeropage.inc"
        .include "utils.inc"
        .include "lcd.inc"
        .include "acia.inc"
        .include "blink.inc"
        .include "keyboard.inc"

        .import __USERRAM_START__
        .import __USERRAM_SIZE__

        .export _system_init
        .export _interrupt_handler
        .export _register_system_break

        .code

; POSITIVE C COMPLIANT
; Main system initialization routine
; LCD initialization
; ACIA initialization
; Disable BCD mode
; Enable interrupt handling
_system_init:
        ; Clear system break flag
        stz system_break_flag
        ; Set system break address to init vector
        lda $fffc
        sta system_break_address
        lda $fffd
        sta system_break_address+1
        lda #$ff
        sta system_break_sp
        ; Initialize BLINK LED
        jsr _blink_init
        ; Short BLINK LED strobe
        jsr _strobe_led
        ; Enable BLINK LED during init operation
        lda #(BLINK_LED_ON)
        jsr _blink_led
        ; Initialize C stack for loadable modules
        lda #<(__USERRAM_START__ + __USERRAM_SIZE__)
        sta sp
        lda #>(__USERRAM_START__ + __USERRAM_SIZE__)
        sta sp+1
        ; Initialize LCD
        jsr _lcd_init
        ; Initialize ACIA
        jsr _acia_init
        ; Initialize keyboard
        jsr _keyboard_init
        ; Disable BCD mode
        cld
        ; Enable interrupt processing
        cli
        ; Turn off BLINK LED, init done
        lda #(BLINK_LED_OFF)
        jsr _blink_led
        ; Done, return from subroutine
        rts

; TENTATIVE C COMPLIANT
; Main interrupt handling routine
; Uses ACIA and keyboard handling routines
_interrupt_handler:
        ; Test ACIA first
        bit ACIA_STATUS
        bpl check_via1
        jsr _handle_acia_irq
check_via1:
        bit VIA1_IFR
        bpl check_via2
        pha
        lda VIA1_IFR
        and VIA1_IER
        and #%00000010 ; IFR_CA1
        beq not_keyboard
        jsr _handle_keyboard_irq
not_keyboard:
        pla
check_via2:
        bit VIA2_IFR
        ; Test for system break flag
        pha
        lda system_break_flag
        bne system_break_request
        pla
        rti
system_break_request:
        ; Replace return pointer with our own
        ldx system_break_sp
        txs
        lda system_break_address+1
        pha
        lda system_break_address
        pha
        ; Clear interrupt flag upon return
        cli
        php
        ; Clear flag
        stz system_break_flag
        rti

; POSITIVE C COMPLIANT
_register_system_break:
        ; Save address provided in parameters
        sta system_break_address
        stx system_break_address+1
        ; Get current stack pointer
        tsx
        ; Remove last address - it's our own
        inx
        inx
        ; Save for break operation
        stx system_break_sp
        rts