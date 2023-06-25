.SUFFIXES:

all:
	/Users/sarnau/GitHub/cc65/bin/cl65  -C c64-asm.cfg creepload.s --start-addr 0xc000 -o creepload.prg
	/Users/sarnau/GitHub/cc65/bin/cl65  -C c64-asm.cfg object_sndEffect.s --start-addr 0x7574 -o object_sndEffect.prg
	/Users/sarnau/GitHub/cc65/bin/cl65  -C c64-asm.cfg object.s --start-addr 0x0800 -o object.prg
	# skip 2 header bytes of a PRG file and append to the application
	tail -c +3 object_sndEffect.prg >> object.prg
	rm object_sndEffect.prg
