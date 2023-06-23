#importonce

// C64 Kernal routines
// https://ia800905.us.archive.org/30/items/Compute_s_Programming_the_Commodore_64_The_Definitive_Guide/Compute_s_Programming_the_Commodore_64_The_Definitive_Guide.pdf
.namespace kernal {
  .label CINT = $FF81 // Initialize screen editor
  .label IOINIT = $FF84 // Initialize input/output
  .label RAMTAS = $FF87 // Initialize RAM, allocate tape buffer, set screen $0400
  .label RESTOR = $FF8A // Restore default I/O vectors
  .label VECTOR = $FF8D // Read/set vectored I/O
  .label SETMSG = $FF90 // Control KERNAL messages
  .label SECOND = $FF93 // Send secondary address after LISTEN
  .label TKSA = $FF96 // Send secondary address after TALK
  .label MEMTOP = $FF99 // Read/set the top of memory
  .label MEMBOT = $FF9C // Read/set the bottom of memory
  .label SCNKEY = $FF9F // Scan keyboard
  .label SETTMO = $FFA2 // Set timeout on serial bus
  .label ACPTR = $FFA5 // Input byte from serial port
  .label CIOUT = $FFA8 // Output byte to serial port
  .label UNTLK = $FFAB // Command serial bus to UNTALK
  .label UNLSN = $FFAE // Command serial bus to UNLISTEN
  .label LISTEN = $FFB1 // Command devices on the serial bus to LISTEN
  .label TALK = $FFB4 // Command serial bus device to TALK
  .label READST = $FFB7 // Read I/O status word
  .label SETLFS = $FFBA // Set logical, first, and second addresses
  .label SETNAM = $FFBD // Set file name
  .label OPEN = $FFC0 // Open a logical file
  .label CLOSE = $FFC3 // Close a specified logical file
  .label CHKIN = $FFC6 // Open channel for input
  .label CHKOUT = $FFC9 // Open channel for output
  .label CLRCHN = $FFCC // Close input and output channels
  .label CHRIN = $FFCF // Input character from channel
  .label CHROUT = $FFD2 // Output character to channel
  .label LOAD = $FFD5 // Load RAM from a device
  .label SAVE = $FFD8 // Save RAM to device
  .label SETTIM = $FFDB // Set real time clock
  .label RDTIM = $FFDE // Read real time clock
  .label STOP = $FFE1 // Scan stop key
  .label GETIN = $FFE4 // Get character from keyboard queue (keyboard buffer)
  .label CLALL = $FFE7 // Close all channels and files
  .label UDTIM = $FFEA // Increment real time clock
  .label SCREEN = $FFED // Return X,Y organization of screen
  .label PLOT = $FFF0 // Read/set X,Y cursor position
  .label IOBASE = $FFF3 // Returns base address of I/O devices
}
