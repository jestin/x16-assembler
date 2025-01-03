.segment "STARTUP"
.segment "INIT"
.segment "ONCE"
.segment "CODE"

	jmp main

.include "x16.inc"
.include "vera.inc"

.include "memory.inc"
.include "parser.asm"

.proc main

	jsr Parser::parse
	jsr print_tokens

	rts
.endproc

.proc print_tokens
	lda #TOKEN_BANK
	sta $00

	ldx token_count

	lda #<TOKEN_BANK_ADDRESS
	sta u2L
	lda #>TOKEN_BANK_ADDRESS
	sta u2H

@token_loop:

	ldy #0

@print_loop:
	lda (u2),y
	beq @end_print_loop
	jsr BSOUT
	iny
@continue:
	bra @print_loop
@end_print_loop:

	; end with a return
	lda #$0d
	jsr BSOUT

	dex
	beq @end_token_loop

	clc
	iny
	tya
	adc u2L
	sta u2L
	lda #0
	adc u2H
	sta u2H

	bra @token_loop

@end_token_loop:

@end:
	rts
.endproc

.proc print_line
	pha
	phx
	phy

	ldx #0

@print_loop:
	lda string_to_print,x
	beq @end
	jsr BSOUT
	inx
@continue:
	bra @print_loop
@end:

	; end with a return
	lda #$0d
	jsr BSOUT

	ply
	plx
	pla
	rts
.endproc

.segment "BSS"

string_to_print:
.res 256
