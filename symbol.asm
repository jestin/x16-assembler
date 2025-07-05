.ifndef SYMBOL_ASM
SYMBOL_ASM = 1

; This assembler supports up to 256 symbols, each with a maximum length of 16
; characters.  The symbol table is stored in banked memory

SYMBOL_TABLE_BANK = 2

MAX_SYMBOL_LENGTH = 16
MAX_NUM_SYMBOLS = 256

; NOTES:
; It might be better to implement this as a two lists; one for defined symbols
; and one for symbols whose definitions we are waiting for.  This could make it
; simpler to figure out if there are undefined symbols when we are finished
; assembling.  (Probably not, because of the SYMBOL_TYPE_UNDEFINED value)

; These are the types of symbols we may find as we parse the program
SYMBOL_TYPE_UNDEFINED = 0	; This means waiting to find the symbol definition
SYMBOL_TYPE_8_BIT = 1
SYMBOL_TYPE_16_BIT = 2

; bank values
symbols = $a000				; 4096 bytes
symbol_types = $b000		; 256 bytes
symbol_values = $b100		; 512 bytes
; b300-bfff are currently unused

.scope Symbol

.segment "BSS"

; currently we support a maximum of 256 symbols
symbol_count: .res 1

.segment "CODE"

;-------------------------------------------------------------------------------
; add_to_symbol_table
;-------------------------------------------------------------------------------
; Adds a symbol to the symbol table if it doesn't already exist.  This does not
; define the symbol's value nor type.
; 
; Inputs: cur_symbol
; Ouputs: <none>
;-------------------------------------------------------------------------------
.proc add_to_symbol_table
	; redefinitions
	cur_symbol_ptr = u0
	new_symbol_ptr = u1
	new_symbol_type_ptr = u2

	; push current bank to stack
	lda $00
	pha

	; set bank
	lda #SYMBOL_TABLE_BANK
	sta $00

	; check if the symbol exists first
	jsr find_symbol

	; if carry is set we didn't find the symbol so continue
	bcs :+
	rts
:

	; add the symbol itself
	
	; load the current symbol's address to the zero page
	lda #<cur_symbol
	sta cur_symbol_ptr
	lda #>cur_symbol
	sta cur_symbol_ptr+1

	; calculate the pointer into the symbols list
	lda symbol_count
	sta new_symbol_ptr
	AslW new_symbol_ptr
	AslW new_symbol_ptr
	AslW new_symbol_ptr
	AslW new_symbol_ptr
	clc
	lda symbols
	adc new_symbol_ptr
	sta new_symbol_ptr
	lda symbols+1
	adc new_symbol_ptr+1
	sta new_symbol_ptr+1

	ldy #0

@symbol_loop:
	lda (cur_symbol_ptr),y
	beq @end_symbol_loop
	sta (new_symbol_ptr),y
	tya
	cmp #MAX_SYMBOL_LENGTH
	bcs @end_symbol_loop
	bra @symbol_loop
@end_symbol_loop:

	; add the symbol type
	clc
	lda symbol_count
	adc symbol_types
	sta new_symbol_type_ptr
	lda #SYMBOL_TYPE_UNDEFINED
	sta (new_symbol_ptr)

	inc symbol_count

@end:
	; restore stack
	pla
	sta $00
	rts

.endproc ; add_to_symbol_table

;-------------------------------------------------------------------------------
; find_symbol
;-------------------------------------------------------------------------------
; Finds a symbol by name and returns its index.  If the symbol doesn't exist,
; we set the carry bit.
;
; Inputs: cur_symbol
; Ouputs: a (the index), c (set if not found)
;-------------------------------------------------------------------------------
.proc find_symbol
	; redefinitions
	cur_symbol_ptr = u0
	symbol_ptr = u1

	; push current bank to stack
	lda $00
	pha

	; set bank
	lda #SYMBOL_TABLE_BANK
	sta $00

	; This is just a simple sequential search

	; load the current symbol's address to the zero page
	lda #<cur_symbol
	sta cur_symbol_ptr
	lda #>cur_symbol
	sta cur_symbol_ptr+1

	; use X for the symbol index
	ldx #0

@search_symbol_loop:
	; first compare the current index with the symbol count
	txa
	cmp symbol_count
	; if X is greater or equal to the count, we didn't find it
	bpl @notfound
	
	; check the current index character by character

	; set the symbol_ptr by the current index (already in A)
	sta symbol_ptr
	AslW symbol_ptr
	AslW symbol_ptr
	AslW symbol_ptr
	AslW symbol_ptr
	clc
	lda symbols
	adc symbol_ptr
	sta symbol_ptr
	lda symbols+1
	adc symbol_ptr+1
	sta symbol_ptr+1
	ldy #0
	clc
@compare_symbol_loop:
	; if we are at or above the max symbol length, we have a match
	tya
	cmp #MAX_SYMBOL_LENGTH
	bcs @end_compare_symbol_loop
	lda (cur_symbol_ptr),y

	; if we have found a string terminator, we have a match
	cmp #0
	beq @end_compare_symbol_loop

	; if the characters aren't equal, we don't match
	cmp (symbol_ptr),y
	bne @no_match
	iny
	bra @compare_symbol_loop
@no_match:
	sec
@end_compare_symbol_loop:

	bcs @notfound

	inx
	bra @search_symbol_loop
@end_search_symbol_loop:

@notfound:
	; restore stack
	pla
	sta $00

	sec
	rts

@found:
	; restore stack
	pla
	sta $00

	clc
	rts

.endproc

;-------------------------------------------------------------------------------
; define_symbol
;-------------------------------------------------------------------------------
; Defines a symbol's value and type, whether the symbol exists or not.  Adds it
; to the symbol table if it doesn't already exist.
;
; Inputs: cur_symbol, value
; Ouputs: <none>
;-------------------------------------------------------------------------------
.proc define_symbol
.endproc

.endscope ; Symbol

.endif ; SYMBOL_ASM
