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

			.area IO (REL)

ScreenStart .equ 0x2400
ScreenHeight .equ 32
ScreenWidth .equ 32
ScreenOrig .equ (ScreenStart + ScreenHeight - 1)

printbyte:: push psw
            rrc
            rrc
            rrc
            rrc
            ani #0xf
            call drawchar
            pop psw
            ani	#0x0f
            call drawchar
            ret

printword:: push psw
            push b
            mvi b, 4
printwdlp:  mov a, m
            inx h
            call printbyte
            dcr b
            jnz printwdlp
                       
            pop b
            pop psw
            ret

;-------------------------------------
; Draw a text string to screen
;-------------------------------------
print::     ldax d           ;load A with character number from address in DE
            inx d            ;increment it by 1
            cpi 0xff
            jz printexit
            call drawchar    ;draw character
            jmp print
printexit:  ret


;-----------------------------------------------
;Clear Screen -> Zero out memory 0x2400 - 0x4000
;-----------------------------------------------
clrscrn::   lxi h,0x2400
clrloop:    mvi m,0x00
            inx h
            mov a,h
            cpi 0x40
            jnz clrloop
            ret

drawYline:  mvi	b, 32
drawYllp:   mvi m,0xFF
            inx h
            mov a,h
            dcr	b
            jnz drawYllp
            ret

drawXline:  lxi d, 0x20
            mvi b, 224
drawXlp:    mov a, m
            ora c
            mov m, a
            dad d
            dcr	b
            jnz drawXlp
            
            ret

;------------------------------------------------
;screen Screen -> Zero out memory 0x2400 - 0x4000
;------------------------------------------------
ptrnscrn::  call clrscrn     ; Clear Screen -> Zero out memory 0x2400 - 0x4000
            lxi h,0x2402
            mvi	c, 224

boxgrnlp1:  mvi	b, 7
boxgrnlp2:  mvi m,0xFF
            inx h
            mov a,h
            dcr	b
            jnz boxgrnlp2

            lxi d, 32 - 7
            dad d
			
            dcr c
            jnz boxgrnlp1

            lxi h,0x2600
            mvi	c, 118
boxgrn2lp1:	mvi	b, 2
boxgrn2lp2:	mvi m,0xFF
            inx h
            mov a,h
            dcr	b
            jnz boxgrn2lp2

            lxi d, 32 - 2
            dad d
            dcr c
            jnz boxgrn2lp1

            lxi h,0x2418
            mvi	c, 224
boxredlp1:  mvi	b, 3
            mvi m,0xF8
            inx h
boxredlp2:  mvi m,0xFF
            inx h
            mov a,h
            dcr	b
            jnz boxredlp2
            lxi d, 32 -4
            dad d
            dcr c
            jnz boxredlp1

            lxi h,0x2400
dyllp:		call drawYline
            lxi d, 0x360
            dad d
            cpi 0x3f
            jm	dyllp
            lxi h,0x3FE0
            call drawYline

            mvi c, 0x01
            lxi h,0x2400
            call drawXline

            lxi h,0x240C
            call drawXline
            lxi h,0x2410
            call drawXline
            lxi h,0x2414
            call drawXline
            lxi h,0x2418
            call drawXline
            mvi c, 0x20
            lxi h,0x241C
            call drawXline
            mvi c, 0x80
            lxi h,0x241F
            call drawXline

            ret

; draw a character
; A = is the char
drawchar::
            push b
            push d
            push h
            mov c,a ; save character
            lxi	d, ScreenOrig

            xra a; clear carry
            lxi h, curs_y ; substract curs_y to address
            mov a,e
            sbb M
            mov e,a

            lxi h, curs_x ; add 32 * 8 * curs_x
            mov a, d
            add m
            mov d, a

            lxi h, charset ; compute charset addess
            mvi b,0
            dad b
            dad b
            dad b
            dad b
            dad b
            xchg
            
            mvi b, 6      ; draw  the char's 8 byte
            xra a
drawloop:
            mov m, a
            push d
			lxi d, 0x0020
            dad d
            pop d
            ldax d
            inx	d
            dcr b
            jnz drawloop			
            xra a
            inx d
            mov m, a
            push d
			lxi d, 0x0020
            dad d
            pop d
            mov m, a

            lxi h, curs_x ; compute next position
            inr m
; no check => smaller code
;            mvi a, 0x1c
;            cmp m
;            jnz drawxtst
;            mvi m, 0
;            lxi h, curs_y
;            inr m
;            mvi a, 0x20
;            cmp m
;            jnz drawxtst
;            mvi m, 0
;drawxtst:			
            pop h
            pop d
            pop b
            ret

;---------------------------
; Sound Test
; Port 3
; A = (01) 21 = UFO.F Sound
; A = (02) 22 = MISSL Sound
; A = (04) 24 = LAU.H Sound
; A = (08) 28 = INV.H Sound
; A = (10) 30 = EXTRA Sound
;----------------------------
drawlabel:: mvi b,15
            lxi d,txtlabel
drawllp:    ldax d
			inx d
            lxi h,curs_x    ; print ">CHECK INPORT"
            mov m,a

            ldax d
			inx d
            lxi h,curs_y
            mov m,a

            call print

            dcr b
            jnz drawllp
			ret

sndtest::   mvi b, 0
			mvi a,0x01       ; A = sound to play
_loopz:     push psw

            ori 0x20         
            out 0x03         ; play the sound                           
            call drawO       ; draw "O" and update port info for awhile 
            mvi a,0x20                                                   
            out 0x03         ; quit playing the sound                  
            call clearO      ; clear "O" and update port info for awhile
            pop psw
            rlc
            inr b
            cpi 0x20
            jnz _loopz

;---------------------------
; Sound Test
; Port 5
; A = 01 = Invader 1 Sound
; A = 02 = Invader 2 Sound
; A = 04 = Invader 3 Sound
; A = 08 = Invader 4 Sound
; A = 10 = UFO.H Sound
; A = 20 = VID.R Sound
;----------------------------

sndloop2:   mvi a,0x01       ; A = sound to play
sndloop3:   push psw
            out 0x05         ; play the sound
            call drawO       ; draw "O" and update port info for awhile
            xra a
            out 0x05         ; quit playing the sound

            call clearO      ; clear "O" and update port info for awhile
            pop psw
            rlc
            inr b
            cpi 0x40
            jnz sndloop3
            dcr b
			ret

drawO:      lxi h,curs_x
            mvi m,4
            lxi h,curs_y
			mvi a, 16
			add b
            mov m,a

            mvi a,0x18       ; load A with character "O"
            call drawchar    ; draw the "O"
            jmp portsmain

clearO:     call portsmain       
 	        lxi h,curs_x
            mvi m,4
            lxi h,curs_y
			mvi a,16
			add b
            mov m,a
            mvi a,0x26       ; load A with character " "               
            call drawchar    ; draw the " "                            
            ret

portsmain:  mvi a,0x60       ;counter do this 96 (0x60) times.  Pause??
_loop:      call portstat    ;draw status of ports to screen and output A to Port 6
            dcr a
            jnz _loop
            ret

;-----------------------------
;draw current status of ports
;-----------------------------
drawports:
 			push psw
 			push b
            lxi h,curs_x
            mvi m,11
            lxi h,curs_y
            mvi m,11
            in 0x01         ;load A with info on port 1
            call drawbin     ;draw it on screen

            lxi h,curs_x
            mvi m,11
            lxi h,curs_y
            mvi m,13
            in 0x02         ;load A with info on port 1
            call drawbin     ;draw it on screen

 			pop b
            pop psw         ;restore af
            ret

;---------------------------------
;draw binary *'s for what's in A
;----------------------------------
drawbin::   mvi b,0x08
drbinlp:    rrc
			push psw
            mvi a,0x26       ;" " (blank)
            jc _skip       
            mvi      a,0x28      ;"*"
_skip:      call    drawchar    ;draw "*" or " " to screen
            pop psw
            dcr     b           ;decrement counter
            jnz     drbinlp     ;if not at end of eight cycles do it again
            ret

portstat:   call    drawports       ;draw current state of ports
            out     0x06
            ret



; CHARACTER IMAGES
charset:
            .byte 0x3E, 0x45, 0x49, 0x51, 0x3E ; "0"
            .byte 0x00, 0x21, 0x7F, 0x01, 0x00 ; "1"
            .byte 0x23, 0x45, 0x49, 0x49, 0x31 ; "2"
            .byte 0x42, 0x41, 0x49, 0x59, 0x66 ; "3"
            .byte 0x0C, 0x14, 0x24, 0x7F, 0x04 ; "4"
            .byte 0x72, 0x51, 0x51, 0x51, 0x4E ; "5"
            .byte 0x1E, 0x29, 0x49, 0x49, 0x46 ; "6"
            .byte 0x40, 0x47, 0x48, 0x50, 0x60 ; "7"
            .byte 0x36, 0x49, 0x49, 0x49, 0x36 ; "8"
            .byte 0x31, 0x49, 0x49, 0x4A, 0x3C ; "9"
            .byte 0x1F, 0x24, 0x44, 0x24, 0x1F ; "A" 
            .byte 0x7F, 0x49, 0x49, 0x49, 0x36 ; "B"
            .byte 0x3E, 0x41, 0x41, 0x41, 0x22 ; "C"
            .byte 0x7F, 0x41, 0x41, 0x41, 0x3E ; "D"
            .byte 0x7F, 0x49, 0x49, 0x49, 0x41 ; "E"
            .byte 0x7F, 0x48, 0x48, 0x48, 0x40 ; "F"
            .byte 0x3E, 0x41, 0x41, 0x45, 0x47 ; "G"
            .byte 0x7F, 0x08, 0x08, 0x08, 0x7F ; "H"
            .byte 0x00, 0x41, 0x7F, 0x41, 0x00 ; "I"
            .byte 0x02, 0x01, 0x01, 0x01, 0x7E ; "J"
            .byte 0x7F, 0x08, 0x14, 0x22, 0x41 ; "K"
            .byte 0x7F, 0x01, 0x01, 0x01, 0x01 ; "L"
            .byte 0x7F, 0x20, 0x18, 0x20, 0x7F ; "M"
            .byte 0x7F, 0x10, 0x08, 0x04, 0x7F ; "N"
            .byte 0x3E, 0x41, 0x41, 0x41, 0x3E ; "O"
            .byte 0x7F, 0x48, 0x48, 0x48, 0x30 ; "P" 
            .byte 0x3E, 0x41, 0x45, 0x42, 0x3D ; "Q"
            .byte 0x7F, 0x48, 0x4C, 0x4A, 0x31 ; "R"
            .byte 0x32, 0x49, 0x49, 0x49, 0x26 ; "S"
            .byte 0x40, 0x40, 0x7F, 0x40, 0x40 ; "T"
            .byte 0x7E, 0x01, 0x01, 0x01, 0x7E ; "U"
            .byte 0x7C, 0x02, 0x01, 0x02, 0x7C ; "V"
            .byte 0x7F, 0x02, 0x0C, 0x02, 0x7F ; "W"
            .byte 0x63, 0x14, 0x08, 0x14, 0x63 ; "X"
            .byte 0x60, 0x10, 0x0F, 0x10, 0x60 ; "Y"
            .byte 0x43, 0x45, 0x49, 0x51, 0x61 ; "Z"
            .byte 0x08, 0x14, 0x22, 0x41, 0x00 ; "<"
            .byte 0x00, 0x41, 0x22, 0x14, 0x08 ; ">"
            .byte 0x00, 0x00, 0x00, 0x00, 0x00 ; " "
            .byte 0x14, 0x14, 0x14, 0x14, 0x14 ; "="
            .byte 0x22, 0x14, 0x7F, 0x14, 0x22 ; "*"
            .byte 0x08, 0x08, 0x08, 0x08, 0x08 ; "-"

; 0  1  2  3  4  5  6  7  8  9  A  B  C  D  E  F  G  H  I  J  K
;00 01 02 03 04 05 06 07 08 09 0A 0B 0C 0D 0E 0F 10 11 12 13 14
;
; L  M  N  O  P  Q  R  S  T  U  V  W  X  Y  Z  <  >    =  *  -
;15 16 17 18 19 1A 1B 1C 1D 1E 1F 20 21 22 23 24 25 26 27 28 29
txtlabel:
txtChkInp:  .byte 4,9 ; position
            .byte 0x25, 0x0C, 0x11, 0x0E, 0x0C, 0x14, 0x26, 0x12
            .byte 0x17, 0x19, 0x18, 0x1B, 0x1D, 0xFF; ">CHECK INPORT"
            .byte 5,10 ; position
            .byte 0x19, 0x18, 0x1B, 0x1D, 0x01, 0x26, 0x00, 0x01
            .byte 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0xFF; "PORT 1  01234567"
            .byte 5,12 ; position
            .byte 0x19, 0x18, 0x1B, 0x1D, 0x02, 0x26, 0x00, 0x01
            .byte 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0xFF; "PORT 1  01234567"
           
            .byte 4,15 ; position
            .byte 0x25, 0x0C, 0x11, 0x0E, 0x0C, 0x14, 0x26, 0x1C
            .byte 0x18, 0x1E, 0x17, 0x0D, 0xFF; ">CHECK SOUND"
            .byte 5, 16
            .byte 0x28, 0x1E, 0x0F, 0x18, 0x29, 0x0F, 0xFF; "*UFO-F"
            .byte 5,17
            .byte 0x28, 0x16, 0x12, 0x1C, 0x1C, 0x15, 0xFF; "*MISSL"
            .byte 5,18
            .byte 0x28, 0x15, 0x0A, 0x1E, 0x29, 0x11, 0xFF; "*LAU-H"
            .byte 5, 19
            .byte 0x28, 0x12, 0x17, 0x1F, 0x29, 0x11, 0xFF; "*INV-H"
            .byte 5, 20
            .byte 0x28, 0x0E, 0x21, 0x1D, 0x1B, 0x0A, 0xFF; "*EXTRA"
            .byte 5, 21
            .byte 0x28, 0x12, 0x17, 0x1F, 0x29, 0x01, 0xFF; "*INV-1"
            .byte 5, 22
            .byte 0x28, 0x12, 0x17, 0x1F, 0x29, 0x02, 0xFF; "*INV-2"
            .byte 5, 23
            .byte 0x28, 0x12, 0x17, 0x1F, 0x29, 0x03, 0xFF; "*INV-3"
            .byte 5, 24
            .byte 0x28, 0x12, 0x17, 0x1F, 0x29, 0x04, 0xFF; "*INV-4"
            .byte 5, 25
            .byte 0x28, 0x1E, 0x0F, 0x18, 0x29, 0x11, 0xFF; "*UFO-H"
            .byte 5, 26
            .byte 0x28, 0x1F, 0x12, 0x0D, 0x29, 0x1B, 0xFF; "*VID-R"

            .area _DATA (DSEG)
curs_x:: .ds 1
curs_y:: .ds 1
