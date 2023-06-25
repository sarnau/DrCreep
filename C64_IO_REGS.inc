; C64 IO registers
.scope C6510
	D6510  := $00 ; 6510 data direction register
	R6510  := $01 ; 6510 data register

	NMI := $FFFA ; NMI vector
	RESET := $FFFC ; RESET vector
	IRQ := $FFFE ; IRQ vector
.endscope

.enum COLOR
	BLACK
	WHITE
	RED
	CYAN
	PURPLE
	GREEN
	BLUE
	YELLOW
	ORANGE
	BROWN
	LIGHT_RED
	DARK_GREY
	GREY
	LIGHT_GREEN
	LIGHT_BLUE
	LIGHT_GREY
.endenum

.scope VIC
	M0X    := $D000 ; Sprite 0 X-position
	M0Y    := $D001 ; Sprite 0 Y-position
	M1X    := $D002 ; Sprite 1 X-position
	M1Y    := $D003 ; Sprite 1 Y-position
	M2X    := $D004 ; Sprite 2 X-position
	M2Y    := $D005 ; Sprite 2 Y-position
	M3X    := $D006 ; Sprite 3 X-position
	M3Y    := $D007 ; Sprite 3 Y-position
	M4X    := $D008 ; Sprite 4 X-position
	M4Y    := $D009 ; Sprite 4 Y-position
	M5X    := $D00A ; Sprite 5 X-position
	M5Y    := $D00B ; Sprite 5 Y-position
	M6X    := $D00C ; Sprite 6 X-position
	M6Y    := $D00D ; Sprite 6 Y-position
	M7X    := $D00E ; Sprite 7 X-position
	M7Y    := $D00F ; Sprite 7 Y-position
	MSIGX  := $D010 ; Bit 8 for the Sprite X-position (M7X8 M6X8 M5X8 M4X8 M3X8 M2X8 M1X8 M0X8)
	CR1    := $D011 ; RST8 ECM BMM DEN RSEL YSCROLL:3
	RASTER := $D012 ; Raster Counter bits 7-0
	LPX    := $D013 ; Light Pen X-position
	LPY    := $D014 ; Light Pen Y-position
	ME     := $D015 ; M7E M6E M5E M4E M3E M2E M1E M0E
	CR2    := $D016 ; - - RES MCM CSEL XSCROLL:3
	MYE    := $D017 ; M7YE M6YE M5YE M4YE M3YE M2YE M1YE M0YE
	VM_CB  := $D018 ; Screen Pointer (A13-A10):4  Bitmap/Charset Pointer (A13-A11):3 -
	IRQST  := $D019 ; IRQ - - - ILP IMMC IMBC IRST
	IRQEN  := $D01A ; - - - - ELP EMMC EMBC ERST
	SPBGPR := $D01B ; M7DP M6DP M5DP M4DP M3DP M2DP M1DP M0DP
	SPMC   := $D01C ; M7MC M6MC M5MC M4MC M3MC M2MC M1MC M0MC
	XXPAND := $D01D ; M7XE M6XE M5XE M4XE M3XE M2XE M1XE M0XE
	SPSPCL := $D01E ; M7M M6M M5M M4M M3M M2M M1M M0M
	SPBGCL := $D01F ; M7D M6D M5D M4D M3D M2D M1D M0D
	EC_BORDER := $D020 ; Border Color
	BGCOL0 := $D021 ; Background Color 0
	BGCOL1 := $D022 ; Background Color 1
	BGCOL2 := $D023 ; Background Color 2
	BGCOL3 := $D024 ; Background Color 3
	SPMC0  := $D025 ; Sprite Multicolor 0
	SPMC1  := $D026 ; Sprite Multicolor 1
	SP0COL := $D027 ; Sprite 0 Color
	SP1COL := $D028 ; Sprite 1 Color
	SP2COL := $D029 ; Sprite 2 Color
	SP3COL := $D02A ; Sprite 3 Color
	SP4COL := $D02B ; Sprite 4 Color
	SP5COL := $D02C ; Sprite 5 Color
	SP6COL := $D02D ; Sprite 6 Color
	SP7COL := $D02E ; Sprite 7 Color
	KCR    := $D02F ; - - - - - Keyboard Control Register:3 (Only available on C128)
	FAST   := $D030 ; - - - - - - TEST 2MHz (Only available on C128)
.endscope

.enum VIC_CR1_FLAGS
	YSCROLL_1 = 1
	YSCROLL_2 = 2
	YSCROLL_3 = 3
	YSCROLL_4 = 4
	YSCROLL_5 = 5
	YSCROLL_6 = 6
	YSCROLL_7 = 7
	RSEL = $08
	DEN = $10
	BMM = $20
	ECM = $40
	RST8 = $80
.endenum

.enum VIC_CR2_FLAGS
	CSEL = 8
	MCM = $10
	RES = $20
.endenum

.scope SID
	FRELO1 	:= $D400
	FREHI1 	:= $D401
	PWLO1  	:= $D402
	PWHI1  	:= $D403
	VCREG1 	:= $D404
	ATDCY1 	:= $D405
	SUREL1 	:= $D406
	FRELO2 	:= $D407
	FREHI2 	:= $D408
	PWLO2  	:= $D409
	PWHI2  	:= $D40A
	VCREG2 	:= $D40B
	ATDCY2 	:= $D40C
	SUREL2 	:= $D40D
	FRELO3 	:= $D40E
	FREHI3 	:= $D40F
	PWLO3  	:= $D410
	PWHI3  	:= $D411
	VCREG3 	:= $D412
	ATDCY3 	:= $D413
	SUREL3 	:= $D414
	FCLO    := $D415
	FCHI    := $D416
	Res_Filt:= $D417
	SIGVOL 	:= $D418
.endscope

COLORRAM := $D800

.scope CIA1
	PRA  	:= $DC00
	COLM 	:= PRA		; keyboard matrix
	PRB  	:= $DC01
	ROWS 	:= PRB		; keyboard matrix
	DDRA 	:= $DC02
	DDRB 	:= $DC03
	T1L  	:= $DC04
	T1H  	:= $DC05
	T2L  	:= $DC06
	T2H  	:= $DC07
	TOD1 	:= $DC08
	TODS 	:= $DC09
	TODM 	:= $DC0A
	TODH 	:= $DC0B
	SDR  	:= $DC0C
	ICR  	:= $DC0D
	CRA  	:= $DC0E
	CRB  	:= $DC0F
.endscope

.scope CIA2
	PRA 	:= $DD00
	PRB		:= $DD01
	DDRA	:= $DD02
	DDRB	:= $DD03
	T1L		:= $DD04
	T1H		:= $DD05
	T2L		:= $DD06
	T2H		:= $DD07
	TOD1	:= $DD08
	TODS	:= $DD09
	TODM	:= $DD0A
	TODH	:= $DD0B
	SDR		:= $DD0C
	ICR		:= $DD0D
	CRA		:= $DD0E
	CRB		:= $DD0F
.endscope
