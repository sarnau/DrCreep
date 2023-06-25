BIN           = ~/GitHub/cc65/bin/cl65
OBJDIR        = ./Objects

clean:
	rm -rf $(OBJDIR)/

all:
	mkdir -p $(OBJDIR)/
	$(BIN) -C c64-asm.cfg creepload.s --start-addr 0xc000 -o $(OBJDIR)/creepload.prg
	$(BIN) -C c64-asm.cfg object_sndEffect.s --start-addr 0x7574 -o $(OBJDIR)/object_sndEffect.prg
	$(BIN) -C c64-asm.cfg object.s --start-addr 0x0800 -Ln $(OBJDIR)/object.sym -o $(OBJDIR)/object.prg
	# skip 2 header bytes of a PRG file and append to the application
	tail -c +3 $(OBJDIR)/object_sndEffect.prg >> $(OBJDIR)/object.prg
	rm $(OBJDIR)/object_sndEffect.prg

	java --class-path /Applications/KickAssembler/KickAss.jar cml.kickass.KickAssembler "DrCreep_Build.asm" -log $(OBJDIR)/BuildLog.txt -symbolfiledir $(OBJDIR)
	/Applications/VICE/bin/x64sc -basicload $(OBJDIR)"/The Castles of Dr. Creep.d64"
