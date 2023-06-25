.SUFFIXES:

all:
	/Users/sarnau/GitHub/cc65/bin/cl65  -C c64-asm.cfg creepload.s --start-addr 0xc000 -o creepload.prg
#	/Users/sarnau/GitHub/cc65/bin/cl65  -C c64-asm.cfg object.s --start-addr 0x0800 -o object.prg
