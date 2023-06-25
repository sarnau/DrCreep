BIN           = ~/GitHub/cc65/bin/cl65
OBJDIR        = ./Objects

clean:
	rm -rf $(OBJDIR)/

all:
	mkdir -p $(OBJDIR)/
	$(BIN) -C c64-asm.cfg creepload.s --start-addr 0xc000 -o $(OBJDIR)/creepload.prg
	$(BIN) -C c64-asm.cfg object.s --start-addr 0x0800 -Ln $(OBJDIR)/object.vs -o $(OBJDIR)/object.prg
	cat $(OBJDIR)/object.vs | awk '/al ([0-9A-Fa-f]+) \.SNDEFFECT_TABLE$$/{print "OPTION_MENU_START := $$" $$2}' > SET_OPTION_MENU_START.asm
	# Because REMOVE_PROTECTION can change the size of the program, we compile again after changing OPTION_MENU_START
	$(BIN) -C c64-asm.cfg object.s --start-addr 0x0800 -Ln $(OBJDIR)/object.vs -o $(OBJDIR)/object.prg
	$(BIN) -C c64-asm.cfg object_sndEffect.s -o $(OBJDIR)/object_sndEffect.prg
	# skip 2 header bytes of a PRG file (the load address, which is irrelevant in our case)
	# and append to the application
	tail -c +3 $(OBJDIR)/object_sndEffect.prg >> $(OBJDIR)/object.prg
	rm $(OBJDIR)/object_sndEffect.prg

	java --class-path /Applications/KickAssembler/KickAss.jar cml.kickass.KickAssembler DrCreep_Build.asm
	rm DrCreep_Build.sym
	/Applications/VICE/bin/x64sc -basicload $(OBJDIR)"/The Castles of Dr. Creep.d64"
