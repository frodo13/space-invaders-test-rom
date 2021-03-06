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

            .area TEST_SHIFTER (REL)
            .globl print, drawchar, curs_x, curs_y, printword
            .globl ptrnscrn, printbyte
numTest .equ  ((shtpattern_end - shtpattern) / 3)

test_shifter::
            lxi h,shtpattern
            mvi B, numTest
            mvi C, 0
            lxi d,resultArray ; result address
testloop:
            call test_1shft
            ora C
            mov C, A
            dcr B
            jnz testloop
            mov A,C
            cpi 0
            jnz tsterr

            lxi d,txtShftOk  ;
            lxi h,curs_x    ; print "SHITERS = OK"
            mvi m,4
            lxi h,curs_y
            mvi m,27
            call print
            ret

tsterr:     call ptrnscrn
            lxi d, resultArray
 
            lxi h,curs_y
            mvi m,4

            mvi c, numTest/8
tstloop2:   lxi h,curs_y
            mov a,m
            inr a
            mov m,a
            lxi h,curs_x
            mvi m,2

            mvi b,8

tstloop3:   ldax d
            inx d
            call printbyte
            out 0x06
            mvi a, 0x26
            call drawchar
            dcr b
            jnz tstloop3
            dcr c
            jnz tstloop2

errloop:	out 0x06
			
            jmp errloop
            ret

; test_1shft: test the hardware shifter
; H is a pointer to the structure bellow :
;     (+00) = test value
;     (+01) = value value
;     (+02) = result 
test_1shft:
            mov A,M		; write the test value to the 74174 & 74175 latch,
            out 0x04  ; bit DS-8 to DS-F are set
            cpi 0xff
            jnz $1shft2
            mvi A,0   ; if data was 0xff write a 0 now
            out 0x04  ; that's a special test pattern
$1shft2:
            mov A,M  ; write the test value another time to the 74174 & 74175 latch,
            out 0x04 ; bit DS-1 to DS-7 are set;  
            
            inx H
            mov A,M  ; write the shift value to the 74175 in A4
            out 0x02 
            inx H
            in  0x03  ; read the result
            xra  M ; result xor excepted value
            stax d ; save the error result
            inx d
            inx H 
            rz    ; return 0 if result value = execpted value
            mvi A,0x01 ; else return 0
            ret

txtShftOk:
.byte 0x1C, 0x11, 0x12, 0x0f, 0x1D, 0x0E, 0x1B, 0x1C, 0x26, 0x27, 0x26, 0x18, 0x14, 0xFF; "SHIFTERS => OK"

shtpattern: ; byte, shift, result
	.byte 0x01, 0x00, 0x01, 0x01, 0x01, 0x02
	.byte 0x01, 0x02, 0x04, 0x01, 0x03, 0x08
	.byte 0x01, 0x04, 0x10, 0x01, 0x05, 0x20
	.byte 0x01, 0x06, 0x40, 0x01, 0x07, 0x80
                            
	.byte 0x02, 0x00, 0x02, 0x02, 0x01, 0x04
	.byte 0x02, 0x02, 0x08, 0x02, 0x03, 0x10
	.byte 0x02, 0x04, 0x20, 0x02, 0x05, 0x40
	.byte 0x02, 0x06, 0x80, 0x02, 0x07, 0x01
                            
	.byte 0x04, 0x00, 0x04, 0x04, 0x01, 0x08
	.byte 0x04, 0x02, 0x10, 0x04, 0x03, 0x20
	.byte 0x04, 0x04, 0x40, 0x04, 0x05, 0x80
	.byte 0x04, 0x06, 0x01, 0x04, 0x07, 0x02
                            
	.byte 0x08, 0x00, 0x08, 0x08, 0x01, 0x10
	.byte 0x08, 0x02, 0x20, 0x08, 0x03, 0x40
	.byte 0x08, 0x04, 0x80, 0x08, 0x05, 0x01
	.byte 0x08, 0x06, 0x02, 0x08, 0x07, 0x04

	.byte 0x10, 0x00, 0x10, 0x10, 0x01, 0x20
	.byte 0x10, 0x02, 0x40, 0x10, 0x03, 0x80
	.byte 0x10, 0x04, 0x01, 0x10, 0x05, 0x02
	.byte 0x10, 0x06, 0x04, 0x10, 0x07, 0x08
                                
	.byte 0x20, 0x00, 0x20, 0x20, 0x01, 0x40
	.byte 0x20, 0x02, 0x80, 0x20, 0x03, 0x01
	.byte 0x20, 0x04, 0x02, 0x20, 0x05, 0x04
	.byte 0x20, 0x06, 0x08, 0x20, 0x07, 0x10
                                
	.byte 0x40, 0x00, 0x40, 0x40, 0x01, 0x80
	.byte 0x40, 0x02, 0x01, 0x40, 0x03, 0x02
	.byte 0x40, 0x04, 0x04, 0x40, 0x05, 0x08
	.byte 0x40, 0x06, 0x10, 0x40, 0x07, 0x20
                                
	.byte 0x80, 0x00, 0x80, 0x80, 0x01, 0x01
	.byte 0x80, 0x02, 0x02, 0x80, 0x03, 0x04
	.byte 0x80, 0x04, 0x08, 0x80, 0x05, 0x10
	.byte 0x80, 0x06, 0x20, 0x80, 0x07, 0x40

	.byte 0x00, 0x00, 0x00, 0x00, 0x01, 0x00
	.byte 0x00, 0x02, 0x00, 0x00, 0x03, 0x00
	.byte 0x00, 0x04, 0x00, 0x00, 0x05, 0x00
	.byte 0x00, 0x06, 0x00, 0x00, 0x07, 0x00

	.byte 0xFF, 0x00, 0xFF, 0xFF, 0x01, 0xFE
	.byte 0xFF, 0x02, 0xFC, 0xFF, 0x03, 0xF8
	.byte 0xFF, 0x04, 0xF0, 0xFF, 0x05, 0xE0
	.byte 0xFF, 0x06, 0xC0, 0xFF, 0x07, 0x80
shtpattern_end:

            .area _DATA (DSEG)
resultArray: 
.ds numTest
