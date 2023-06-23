; C64 Kernal routines
; https:;ia800905.us.archive.org/30/items/Compute_s_Programming_the_Commodore_64_The_Definitive_Guide/Compute_s_Programming_the_Commodore_64_The_Definitive_Guide.pdf
.scope kernal
	CINT := $FF81 ; Initialize screen editor
	IOINIT := $FF84 ; Initialize input/output
	RAMTAS := $FF87 ; Initialize RAM, allocate tape buffer, set screen $0400
	RESTOR := $FF8A ; Restore default I/O vectors
	VECTOR := $FF8D ; Read/set vectored I/O
	SETMSG := $FF90 ; Control KERNAL messages
	SECOND := $FF93 ; Send secondary address after LISTEN
	TKSA := $FF96 ; Send secondary address after TALK
	MEMTOP := $FF99 ; Read/set the top of memory
	MEMBOT := $FF9C ; Read/set the bottom of memory
	SCNKEY := $FF9F ; Scan keyboard
	SETTMO := $FFA2 ; Set timeout on serial bus
	ACPTR := $FFA5 ; Input byte from serial port
	CIOUT := $FFA8 ; Output byte to serial port
	UNTLK := $FFAB ; Command serial bus to UNTALK
	UNLSN := $FFAE ; Command serial bus to UNLISTEN
	LISTEN := $FFB1 ; Command devices on the serial bus to LISTEN
	TALK := $FFB4 ; Command serial bus device to TALK
	READST := $FFB7 ; Read I/O status word
	SETLFS := $FFBA ; Set logical, first, and second addresses
	SETNAM := $FFBD ; Set file name
	OPEN := $FFC0 ; Open a logical file
	CLOSE := $FFC3 ; Close a specified logical file
	CHKIN := $FFC6 ; Open channel for input
	CHKOUT := $FFC9 ; Open channel for output
	CLRCHN := $FFCC ; Close input and output channels
	CHRIN := $FFCF ; Input character from channel
	CHROUT := $FFD2 ; Output character to channel
	LOAD := $FFD5 ; Load RAM from a device
	SAVE := $FFD8 ; Save RAM to device
	SETTIM := $FFDB ; Set real time clock
	RDTIM := $FFDE ; Read real time clock
	STOP := $FFE1 ; Scan stop key
	GETIN := $FFE4 ; Get character from keyboard queue (keyboard buffer)
	CLALL := $FFE7 ; Close all channels and files
	UDTIM := $FFEA ; Increment real time clock
	SCREEN := $FFED ; Return X,Y organization of screen
	PLOT := $FFF0 ; Read/set X,Y cursor position
	IOBASE := $FFF3 ; Returns base address of I/O devices
.endscope
