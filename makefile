#-------------------------------
# Space Invaders Test ROM
# Documented and transfered to TASM
# By Timothy Shiels
# 08/2008
# www.outerworldarcade.com
#-------------------------------
# Little refactor here by Fabrice GIRARDOT on 16-sept-2017 :-)
#-------------------------------
# as8085 and aslink can be download at http://shop-pdp.net/ashtml/asxget.php
# hex2bin can be downloaded at http://hex2bin.sourceforge.net/
# This makefile assumes those tools are present in the current directory
#-------------------------------

TARGET  := test
ROM     := $(TARGET).h
SRC     := main.asm io.asm crc32.asm test_ram.asm shifter.asm 

AS      := ./as8085
LD      := ./aslink
HEX2BIN := ./hex2bin

OBJ     := $(SRC:.asm=.rel)
ASFLAGS := -l -o

# Default target if make in run with no target
all: $(ROM)
	@echo Binary file $< is ready to be flashed to a 2716 EPROM
	@ls -al $<

# Generate ZIP file with test code as ROM 'h' + original game files
../tst_invd.zip: $(ROM) ../invaders.e ../invaders.f ../invaders.g
	rm -f $@
	zip -5 -j $@ $^

# Convert Intel HEX format to raw binary
$(ROM): $(TARGET).ihx
	$(HEX2BIN) -l 800 -p a5 $(TARGET).ihx
	mv $(TARGET).bin $@

# Link
$(TARGET).ihx: $(OBJ)
	$(LD) -n -u -o -b _DATA=0x2000 -i $@ $^

# Assemble
%.rel: %.asm
	$(AS) $(ASFLAGS) $@ $<

clean:
	rm -f *.rel *.lst *.sym *.rst *.bak *.hlr $(TARGET).ihx $(TARGET).bin $(ROM)
