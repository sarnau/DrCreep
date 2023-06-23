.include "C64_IO_REGS.inc"
.include "C64_KERNAL.inc"

SCREENRAM := $0400 ; original video base address
START := $800 ; BASIC memory start, used to load data
CREEPLOAD_START := $C000 ; code to load the title screen

; the VIC is mapped to the upper 16kb
TOP_SCREENRAM := $CC00 ; video memory, in highres multicolor mode the additional colors
TOP_HIGHRESVIDEORAM := $E000 ; address of the 8kb highres video data

; standard ASCII encoding
.MACPACK cbm
	scrcode

; set a pointer to an address
.macro SetPtr ptr,addr
	lda     #<(addr)
	sta     ptr
	lda     #>(addr)
	sta     ptr+1
.endmacro
