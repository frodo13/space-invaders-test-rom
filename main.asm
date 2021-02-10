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

			.area MAIN (REL)

			.globl ramtest
			.globl print, clrscrn ,drawchar, curs_x, curs_y, printword, ptrnscrn
			.globl drawlabel, sndtest
			.globl test_roms
			.globl test_shifter


TopStack .equ 0x2400
;--------
; Set-up
;--------
            xra a
            out 0x03

            jmp ramtest
endramtest::
            lxi sp,TopStack    ; set stack pointer to 0x2400

            out 0x06

            call ptrnscrn
 
            lxi d,txtRamOK  ;
            lxi h,curs_x    ; print "RAMS => OK"
            mvi m,4
            lxi h,curs_y
            mvi m,4
            call print

            call test_roms

            call drawlabel
            call sndtest
            call sndtest
            
            call test_shifter

end:        jmp end

txtRamOK:
.byte 0x1B, 0x0A, 0x16, 0x26, 0x27, 0x26, 0x18, 0x14, 0xFF; "RAM = OK"
            .area _DATA (DSEG)


                                                 
