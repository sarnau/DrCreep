#importonce

// C64 IO registers
.namespace C6510 {
	.label D6510  = $00 // 6510 data direction register
	.label R6510  = $01 // 6510 data register

	.label NMI = $FFFA // NMI vector
	.label RESET = $FFFC // RESET vector
	.label IRQ = $FFFE // IRQ vector
}

.namespace VIC {
	.label M0X    = $D000 // Sprite 0 X-position
	.label M0Y    = $D001 // Sprite 0 Y-position
	.label M1X    = $D002 // Sprite 1 X-position
	.label M1Y    = $D003 // Sprite 1 Y-position
	.label M2X    = $D004 // Sprite 2 X-position
	.label M2Y    = $D005 // Sprite 2 Y-position
	.label M3X    = $D006 // Sprite 3 X-position
	.label M3Y    = $D007 // Sprite 3 Y-position
	.label M4X    = $D008 // Sprite 4 X-position
	.label M4Y    = $D009 // Sprite 4 Y-position
	.label M5X    = $D00A // Sprite 5 X-position
	.label M5Y    = $D00B // Sprite 5 Y-position
	.label M6X    = $D00C // Sprite 6 X-position
	.label M6Y    = $D00D // Sprite 6 Y-position
	.label M7X    = $D00E // Sprite 7 X-position
	.label M7Y    = $D00F // Sprite 7 Y-position
	.label MSIGX  = $D010 // Bit 8 for the Sprite X-position (M7X8 M6X8 M5X8 M4X8 M3X8 M2X8 M1X8 M0X8)
	.label CR1    = $D011 // RST8 ECM BMM DEN RSEL YSCROLL:3
	.label RASTER = $D012 // Raster Counter bits 7-0
	.label LPX    = $D013 // Light Pen X-position
	.label LPY    = $D014 // Light Pen Y-position
	.label ME     = $D015 // M7E M6E M5E M4E M3E M2E M1E M0E
	.label CR2    = $D016 // - - RES MCM CSEL XSCROLL:3
	.label MYE    = $D017 // M7YE M6YE M5YE M4YE M3YE M2YE M1YE M0YE
	.label VM_CB  = $D018 // Screen Pointer (A13-A10):4  Bitmap/Charset Pointer (A13-A11):3 -
	.label IRQST  = $D019 // IRQ - - - ILP IMMC IMBC IRST
	.label IRQEN  = $D01A // - - - - ELP EMMC EMBC ERST
	.label SPBGPR = $D01B // M7DP M6DP M5DP M4DP M3DP M2DP M1DP M0DP
	.label SPMC   = $D01C // M7MC M6MC M5MC M4MC M3MC M2MC M1MC M0MC
	.label XXPAND = $D01D // M7XE M6XE M5XE M4XE M3XE M2XE M1XE M0XE
	.label SPSPCL = $D01E // M7M M6M M5M M4M M3M M2M M1M M0M
	.label SPBGCL = $D01F // M7D M6D M5D M4D M3D M2D M1D M0D
	.label EC_BORDER = $D020 // Border Color
	.label BGCOL0 = $D021 // Background Color 0
	.label BGCOL1 = $D022 // Background Color 1
	.label BGCOL2 = $D023 // Background Color 2
	.label BGCOL3 = $D024 // Background Color 3
	.label SPMC0  = $D025 // Sprite Multicolor 0
	.label SPMC1  = $D026 // Sprite Multicolor 1
	.label SP0COL = $D027 // Sprite 0 Color
	.label SP1COL = $D028 // Sprite 1 Color
	.label SP2COL = $D029 // Sprite 2 Color
	.label SP3COL = $D02A // Sprite 3 Color
	.label SP4COL = $D02B // Sprite 4 Color
	.label SP5COL = $D02C // Sprite 5 Color
	.label SP6COL = $D02D // Sprite 6 Color
	.label SP7COL = $D02E // Sprite 7 Color
	.label KCR    = $D02F // - - - - - Keyboard Control Register:3 (Only available on C128)
	.label FAST   = $D030 // - - - - - - TEST 2MHz (Only available on C128)
}

.namespace SID {
	.label FRELO1 = $D400
	.label FREHI1 = $D401
	.label PWLO1  = $D402
	.label PWHI1  = $D403
	.label VCREG1 = $D404
	.label ATDCY1 = $D405
	.label SUREL1 = $D406
	.label FRELO2 = $D407
	.label FREHI2 = $D408
	.label PWLO2  = $D409
	.label PWHI2  = $D40A
	.label VCREG2 = $D40B
	.label ATDCY2 = $D40C
	.label SUREL2 = $D40D
	.label FRELO3 = $D40E
	.label FREHI3 = $D40F
	.label PWLO3  = $D410
	.label PWHI3  = $D411
	.label VCREG3 = $D412
	.label ATDCY3 = $D413
	.label SUREL3 = $D414
	.label SIGVOL = $D418
}

.label COLORRAM = $D800

.namespace CIA1 {
	.label PRA  = $DC00
	.label COLM	= PRA		// keyboard matrix
	.label PRB  = $DC01
	.label ROWS	= PRB		// keyboard matrix
	.label DDRA = $DC02
	.label DDRB = $DC03
	.label T1L  = $DC04
	.label T1H  = $DC05
	.label T2L  = $DC06
	.label T2H  = $DC07
	.label TOD1 = $DC08
	.label TODS = $DC09
	.label TODM = $DC0A
	.label TODH = $DC0B
	.label SDR  = $DC0C
	.label ICR  = $DC0D
	.label CRA  = $DC0E
	.label CRB  = $DC0F
}

.namespace CIA2 {
	.label PRA	= $DD00
	.label PRB	= $DD01
	.label DDRA	= $DD02
	.label DDRB	= $DD03
	.label T1L	= $DD04
	.label T1H	= $DD05
	.label T2L	= $DD06
	.label T2H	= $DD07
	.label TOD1	= $DD08
	.label TODS	= $DD09
	.label TODM	= $DD0A
	.label TODH	= $DD0B
	.label SDR	= $DD0C
	.label ICR	= $DD0D
	.label CRA	= $DD0E
	.label CRB	= $DD0F
}
