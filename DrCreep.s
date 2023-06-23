#import "C64_IO_REGS.s"
#import "C64_KERNAL.s"

.label SCREENRAM = $0400 // original video base address
.label START = $800 // BASIC memory start, used to load data
.label CREEPLOAD_START = $C000 // code to load the title screen

// the VIC is mapped to the upper 16kb
.label TOP_SCREENRAM = $CC00 // video memory, in highres multicolor mode the additional colors
.label TOP_HIGHRESVIDEORAM = $E000 // address of the 8kb highres video data

// Dr. Creep Zeropage variables
*=$10 "Zero Page" virtual
.zp {
}

// set a pointer to an address
.macro SetPtr(ptr,addr) {
	lda     #<addr
	sta     ptr
	lda     #>addr
	sta     ptr+1
}


// Generate the disk image
.disk [filename="bin/The Castles of Dr. Creep.d64", name="DUNGEONMASTER",id="AX22A" ]
{
	[name="CASTLE", type="prg", segments="CASTLE" ],
	[name="CREEPLOAD", type="prg", segments="CREEPLOADER" ],
	[name=@"\$81PIC A TITLE   ", type="prg", prgFiles="files/title.koa" ],
}


#import "castle.s"
#import "creepload.s"
