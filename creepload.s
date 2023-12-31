; The title screen and application code loader, which is loaded by the basic starter code

.include "DrCreep.inc"

.macro COPY_MEMORY startPtr,destPtr,destEndAddr
.scope
	ldy     #0
@loop:
	lda     (startPtr),Y
	sta     (destPtr),Y
	iny
	bne     @loop
	inc     z:startPtr+1
	inc     z:destPtr+1
	lda     z:destPtr+1
	cmp     #>(destEndAddr)
	bne     @loop
.endscope
.endmacro

	.zeropage
	.org $14
SRC_PTR:	.word $0000 ; general source pointer for copy operations
DEST_PTR:	.word $0000 ; general destination pointer for copy operations

	.org CREEPLOAD_START
.proc CREEPLOADER
	.code

	; erase video ram with spaces
	SET_PTR SRC_PTR,SCREENRAM
	SET_PTR DEST_PTR,COLORRAM
	ldy     #0
@loop1:
	lda     #' '
@loop2:
	sta     (SRC_PTR),Y
	sta     (DEST_PTR),Y
	iny
	bne     @loop2
	inc     SRC_PTR+1
	inc     DEST_PTR+1
	lda     SRC_PTR+1
	cmp     #>(SCREENRAM+1024)
	bne     @loop1

	SET_PTR SRC_PTR,TITLE_TEXT
@printloop:
	ldy     #0
	lda     (SRC_PTR),Y ; X position of the string
	bmi     @printloopend ; negative => end of text list

	ldy     #1
	lda     (SRC_PTR),Y ; Y position of the string
	asl
	tax
	lda     MULT40_TABLE,X
	sta     DEST_PTR	; get the screen address for the Y pos
	lda     MULT40_TABLE+1,X
	sta     DEST_PTR+1
	dey

	; add the X position to it
	clc
	lda     DEST_PTR
	adc     (SRC_PTR),Y
	sta     DEST_PTR
	lda     DEST_PTR+1
	adc     #0
	sta     DEST_PTR+1

	; move read pointer to the beginning of the string
	clc
	lda     SRC_PTR
	adc     #2
	sta     SRC_PTR
	lda     SRC_PTR+1
	adc     #0
	sta     SRC_PTR+1
	ldy     #0
@textcopy:
	lda     (SRC_PTR),Y ; end of string?
	bmi     @textcopyend ; yes =>
	sta     (DEST_PTR),Y
	iny
	jmp     @textcopy
@textcopyend:
	and     #$7F ; last character of the string
	sta     (DEST_PTR),Y
	iny
	tya ; add length of the string to the ptr
	clc
	adc     SRC_PTR
	sta     SRC_PTR
	lda     SRC_PTR+1
	adc     #0
	sta     SRC_PTR+1
	jmp     @printloop ; continue with next string

@printloopend:
	lda     #COLOR::YELLOW
	sta     VIC::EC_BORDER ; screen colors to yellow
	sta     VIC::BGCOL0
	lda     #%00010110 ; Screen Pointer (A13-A10) = $1*$400 + $0000 = $0400
	sta     VIC::VM_CB  ; Bitmap/Charset Pointer (A13-A11) = 6 * $400 + $0000 = $1800 (ROM Font, Uppercase/Lowercase, non-inverted)

	; Load the title screen in Koala paint format
	lda     #2		; Logical number
	ldx     #8		; Device number
	ldy     #0		; Secondary address
	jsr     kernal::SETLFS  ; Set file parameters
	lda     #TITLE_FNAME_END-TITLE_FNAME ; Filename length
	ldx     #<TITLE_FNAME ; ptr to the filename
	ldy     #>TITLE_FNAME
	jsr     kernal::SETNAM  ; Set file name parameters
	lda     #0		; load
	ldx     #<START	; destination address
	ldy     #>START
	jsr     kernal::LOAD

	SET_PTR SRC_PTR,START+$1F40
	SET_PTR DEST_PTR,TOP_SCREENRAM
	COPY_MEMORY SRC_PTR,DEST_PTR,TOP_SCREENRAM+1024

	SET_PTR SRC_PTR,START
	SET_PTR DEST_PTR,TOP_HIGHRESVIDEORAM
	COPY_MEMORY SRC_PTR,DEST_PTR,TOP_HIGHRESVIDEORAM+8192

	SET_PTR SRC_PTR,START+$2328
	SET_PTR DEST_PTR,COLORRAM
	COPY_MEMORY SRC_PTR,DEST_PTR,COLORRAM+1024

	; Select the position of the VIC-memory
	lda     CIA2::DDRA
	ora     #3
	sta     CIA2::DDRA
	lda     CIA2::PRA
	and     #$fc ; %00, 0: Bank 3: $C000-$FFFF, 49152-65535
	sta     CIA2::PRA

	; ECM=0, BMM=1, MCM=1 => Multicolor bitmap mode (160x200)
	lda     #%00111011 ; ECM=0 (Extended Color Mode), BMM=1 (Bitmap Mode), DEN=1 (Video enabled), RSEL=1 (25 lines), YSCROLL=3
	sta     VIC::CR1
	lda     #%00011000 ; MCM=1 (Multi Color Mode), CSEL=1 (40 character width), XSCROLL = 0
	sta     VIC::CR2
	lda     #%00111000 ; Screen Pointer (A13-A10) = $3*$400 + $C000 = $CC00
	sta     VIC::VM_CB  ; Bitmap/Charset Pointer (A13-A11) = 8 * $400 + $C000 = $E000
	lda     #COLOR::YELLOW
	sta     VIC::EC_BORDER
	lda     #COLOR::WHITE
	sta     VIC::BGCOL0

	; Load the application code
	lda     #2		; Logical number
	ldx     #8		; Device number
	ldy     #0		; Secondary address
	jsr     kernal::SETLFS  ; Set file parameters
	lda     #OBJECT_FNAME_END-OBJECT_FNAME ; Filename length
	ldx     #<OBJECT_FNAME ; ptr to the filename
	ldy     #>OBJECT_FNAME
	jsr     kernal::SETNAM  ; Set file name parameters
	lda     #0		; load
	ldx     #<START	; destination address
	ldy     #>START
	jsr     kernal::LOAD

	; launch the application
	jmp     START

	.data

; the filename of the title screen has a special character as the first byte
TITLE_FNAME:
	.byte $81
	scrcode "PIC A TITLE   "
TITLE_FNAME_END:

; the filename of the title screen has a special character as the first byte
OBJECT_FNAME:
	scrcode "OBJECT"
OBJECT_FNAME_END:

MULT40_TABLE:
	.repeat 25, I
	.word I*40+SCREENRAM
	.endrepeat

TITLE_TEXT:
	.byte 6,1
	scrcode "BR0DERBUND SOFTWARE PRESENT"
	.byte 'S'|$80

	.byte 6,10
	.byte '"'
	scrcode "THE CASTLES OF DOCTOR CREEP"
	.byte '"'|$80

	.byte 15,13
	scrcode "BY ED HOBB"
	.byte 'S'|$80

	.byte 2,23
	scrcode "PLEASE ALLOW TWO MINUTES FOR LOADIN"
	.byte 'G'|$80

	.byte 5,15
	scrcode "(C) 1984 BR0DERBUND SOFTWAR"
	.byte 'E'|$80

	; end of the string list
	.byte $80

	; unused filler bytes
	.byte 0,0,0
.endproc
