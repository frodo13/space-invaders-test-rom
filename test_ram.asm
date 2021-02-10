;-------------------------------
; Space Invaders Test ROM
;
; version 1.3 by Marc Deslauriers
; 03/27/2019
; version 1.2 by Frederic Rodo
; 10/12/2017
; version 1.1 by Fabrice GIRARDOT
; 09/16/2017
; version 1.0 by Frederic Rodo
; 10/12/2013
; preversion by Timothy Shiels
; 08/2008
; www.outerworldarcade.com
;-------------------------------

			.area TEST_RAM (REL)

			.globl endramtest
;---------------------------------------
; First RAM test
;---------------------------------------
ramtest::   mvi     d,0x00       ; clear the odd error register
            mvi     e,0x00       ; clear the even error register
            mvi     c,0x03       ; We'll do the ram tests three times - keep track in c

            ;---------------------------------------
            ;Store #0x55 in all memory 0x2000 - 0x4000
            ;---------------------------------------
ramtest1:   mvi     b,0x55
            lxi     h,0x2000
rmtst1:     mov     m,b
            inx     h
            mov     a,h
            cpi     0x40
            jnz     rmtst1

            ;---------------------------------------
            ;Check each stored value 0x2000 - 0x4000
            ;---------------------------------------
            lxi     h,0x2000
rmtst2:     mov     a,m
            xri     0x55
            jz      rmtst2_cont    ; no error, test next byte
            mov     b,a            ; save A in B
            mov     a,l            ; YES- load L into A
            rrc
            jc      rmtst2_bad_odd
            mov     a, e
            ora     b
            mov     e, a
            jmp     rmtst2_cont
rmtst2_bad_odd:
            mov     a, d
            ora     b
            mov     d, a
rmtst2_cont:
            inx     h
            mov     a,h
            cpi     0x40
            jnz     rmtst2

            ;---------------------------------------
            ; Store #0xAA in all memory 0x2000 - 0x4000
            ;---------------------------------------
            mvi     b,0xaa
            lxi     h,0x2000
rmtst3:     mov     m,b
            inx     h
            mov     a,h
            cpi     0x40
            jnz     rmtst3

            ;---------------------------------------
            ;Check each stored value 0x2000 - 0x4000
            ;---------------------------------------
            lxi     h,0x2000
rmtst4:     mov     a,m
            xri     0xaa
            jz      rmtst4_cont    ; no error, test next byte
            mov     b,a            ; save A in B
            mov     a,l            ; YES- load L into A
            rrc
            jc      rmtst4_bad_odd
            mov     a, e
            ora     b
            mov     e, a
            jmp     rmtst4_cont
rmtst4_bad_odd:
            mov     a, d
            ora     b
            mov     d, a
rmtst4_cont:
            inx     h
            mov     a,h
            cpi     0x40
            jnz     rmtst4

            dcr     c
            jnz     ramtest1    ; start again if not done with 3 tests

;----------------------------------------------
; Second RAM test
; fill memory with incremental values 0x00 - 0xFF
;----------------------------------------------
ramtest2:   lxi     h,0x2000
            mvi     b,0x00
rmtst5:     mov     a,b
            mov     m,a
            inx     h
            inr     b
            mov     a,b
            cpi     0xff
            jnz     rmtst6
            mvi     b,0x00       ;start back at 0x00
rmtst6:   	mov     a,h
            cpi     0x40
            jnz     rmtst5

            ;---------------------
            ; verify each one
            ;---------------------
            lxi     h,0x2000
            mvi     b,0x00
rmtst7:    	mov     a,m
            xra     b

            jz      rmtst7_cont    ; no error, test next byte
            mov     c,a            ; save A in c
            mov     a,l            ; YES- load L into A
            rrc
            jc      rmtst7_bad_odd
            mov     a, e
            ora     c
            mov     e, a
            jmp     rmtst7_cont
rmtst7_bad_odd:
            mov     a, d
            ora     c
            mov     d, a
rmtst7_cont:
            inr     b
            mov     a,b
            cpi     0xff
            jnz     rmtst8
            mvi     b,0x00
rmtst8:    	inx     h
            mov     a,h
            cpi     0x40
            jnz     rmtst7

            mov     a,d
            ora     e
            jnz     badram      ; jump to bad if there's at least one error
            jmp     endramtest

;--------------
;Bad RAM found 
; display on screen 1st bad bit found
;  a contains bad bits
;  h contains bad address
;--------------
badram:     lxi     h,0x2400
clrloop:    mvi     m,0x00  ; clear screen
            inx     h
            mov     a,h
            cpi     0x40
            jnz     clrloop

            mov     b,d ; transfer error word from D to B
            mov     c,e
            lxi     h,0x3000    ;HL = location to draw to the screen
            
bdlp:       mov     a,b  ; shift 16 bits error
            rar     
            mov     b,a
            mov     a,c
            rar
            mov     c,a
            jc      bdlp_wrong        ; if this bits is wrong goto
            lxi     d, charfull       ; else write a fullchar
            
				mvi     a, 0x01 ; draw on upper line
            ora     h  
				mov     h, a

            jmp     bdlp_cont

bdlp_wrong: lxi     d, charnum
				mov     a,l
				rlc
				rlc
				rlc
				add     e
				mov     e,a
				jnc     bdlp_uline
            inr     d
            
bdlp_uline:	mvi     a, 0xfe ; draw on upper line
            ana     h  
				mov     h, a

bdlp_cont:  
				mov     a,l
            cpi     0x10
            jz      end
            jmp     _draw            
end:		   out     0x06  ; clear watchdog
				out     0x07  ; woarkaround for mame :(		   
			   jmp     end 

;	_draw subroutine
;           input :
;                  DE = character location pointer
;                  HL = location to draw to the screen
;           use :
;                  A
_draw:		lxi     sp, 0x0020
            ldax    d           ;load A with a byte of character image
            ani     0xfe
            mov     m,a         ;draw a line of error code image to screen

            ldax    d           ;test last car bit
            ani     0x01
            jnz     _draw_out   ; exit if set
            inx     d           ;increment character location pointer
            dad     sp          ;add +0x20 to HL, next screen location is +0x20
            jmp     _draw
            
_draw_out:  inx     d
				mov     a, l
				ani     0x1f
				mov     l, a
				inx     h
				
            jmp     bdlp



; CHARACTER IMAGES USED BY BAD RAM ROUTINE
charnum:    .byte 0x00, 0x20, 0x30, 0x20, 0x20, 0x20, 0x20, 0x71 ;"1"
            .byte 0x00, 0x70, 0x88, 0x80, 0x60, 0x10, 0x08, 0xF9 ;"2"
            .byte 0x00, 0xF8, 0x80, 0x40, 0x60, 0x80, 0x88, 0x71 ;"3"
            .byte 0x00, 0x40, 0x60, 0x50, 0x48, 0xF8, 0x40, 0x41 ;"4"
            .byte 0x00, 0xF8, 0x08, 0x78, 0x80, 0x80, 0x88, 0x71 ;"5"
            .byte 0x00, 0xE0, 0x10, 0x08, 0x78, 0x88, 0x88, 0x71 ;"6"
            .byte 0x00, 0xF8, 0x80, 0x40, 0x20, 0x10, 0x10, 0x11 ;"7"
            .byte 0x00, 0x70, 0x88, 0x88, 0x70, 0x88, 0x88, 0x71 ;"8"
charbad:    .byte 0x20, 0x50, 0x88, 0x88, 0xF8, 0x88, 0x88, 0x01 ;"A"
            .byte 0x78, 0x88, 0x88, 0x78, 0x88, 0x88, 0x78, 0x01 ;"B"
            .byte 0x70, 0x88, 0x08, 0x08, 0x08, 0x88, 0x70, 0x01 ;"C"
            .byte 0x70, 0x90, 0x90, 0x90, 0x90, 0x90, 0x70, 0x01 ;"D"
            .byte 0xE0, 0x20, 0x20, 0xE0, 0x20, 0x20, 0xE0, 0x01 ;"E"
            .byte 0x3E, 0x02, 0x02, 0x1E, 0x02, 0x02, 0x02, 0x01 ;"F"
            .byte 0x3C, 0x02, 0x02, 0x02, 0x32, 0x22, 0x3C, 0x01 ;"G"
            .byte 0x22, 0x22, 0x22, 0x3E, 0x22, 0x22, 0x22, 0x01 ;"H"
charfull:   .byte 0xFE, 0xFE, 0xFE, 0xFE, 0xFE, 0xFE, 0xFE, 0xFF ; black

