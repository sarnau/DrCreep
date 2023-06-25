.SUFFIXES:

clean:
	rm -rf "bin/"

all:
	mkdir -p "bin/"
	/Users/sarnau/GitHub/cc65/bin/cl65  -C c64-asm.cfg creepload.s --start-addr 0xc000 -o ./bin/creepload.prg
	/Users/sarnau/GitHub/cc65/bin/cl65  -C c64-asm.cfg object_sndEffect.s --start-addr 0x7574 -o ./bin/object_sndEffect.prg
	/Users/sarnau/GitHub/cc65/bin/cl65  -C c64-asm.cfg object.s --start-addr 0x0800 -o ./bin/object.prg
	# skip 2 header bytes of a PRG file and append to the application
	tail -c +3 ./bin/object_sndEffect.prg >> ./bin/object.prg
	rm ./bin/object_sndEffect.prg

	java --class-path /Applications/KickAssembler/KickAss.jar cml.kickass.KickAssembler "DrCreep_Build.asm" -log "bin/BuildLog.txt" -symbolfiledir "./bin"
	/Applications/VICE/bin/x64sc -basicload "bin/The Castles of Dr. Creep.d64"
