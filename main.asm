.segment "STARTUP"
.segment "INIT"
.segment "ONCE"
.segment "CODE"

.scope Main

	jmp Main::main

.include "x16.inc"
.include "vera.inc"

.include "memory.inc"
.include "tokenizer.asm"

.segment "BSS"

token_type: .res 1

.segment "CODE"

; redefinitions

string_ptr = u0

.proc main

	jsr Tokenizer::parse
	
	; check for error flag
	beq :+

	; print tokenizer error
	lda #<tokenizer_error_label
	sta string_ptr
	lda #>tokenizer_error_label
	sta string_ptr+1
	jsr print_string
:
	jsr print_tokens

	rts
.endproc

.proc print_tokens
	pha
	phx
	phy

	lda #TOKEN_BANK
	sta $00

	ldx #0

	lda #<TOKEN_BANK_ADDRESS
	sta Tokenizer::token_char_ptr
	lda #>TOKEN_BANK_ADDRESS
	sta Tokenizer::token_char_ptr+1

@token_loop:

	ldy #0

	; print out the current token
@print_loop:
	lda (u2),y
	beq @end_print_loop
	jsr BSOUT
	iny
@continue:
	bra @print_loop
@end_print_loop:

	; print spaces for separators
	lda #$20 ; PETSCII space
	jsr BSOUT
	jsr BSOUT
	jsr BSOUT
	jsr BSOUT

	; print the token type on the same line
	lda TOKEN_TYPE_BANK_ADDRESS,x
	cmp #Tokenizer::TOKEN_TYPE_OPCODE
	beq @token_type_opcode
	cmp #Tokenizer::TOKEN_TYPE_DIRECTIVE
	beq @token_type_directive
	cmp #Tokenizer::TOKEN_TYPE_NUMERIC_LITERAL
	beq @token_type_numeric_literal
	cmp #Tokenizer::TOKEN_TYPE_OPERATOR
	beq @token_type_operator
	bra @next_line

@token_type_opcode:
	lda #<opcode_label
	sta string_ptr
	lda #>opcode_label
	sta string_ptr+1
	bra :+
@token_type_directive:
	lda #<directive_label
	sta string_ptr
	lda #>directive_label
	sta string_ptr+1
	bra :+
@token_type_numeric_literal:
	lda #<numeric_literal_label
	sta string_ptr
	lda #>numeric_literal_label
	sta string_ptr+1
	bra :+
@token_type_operator:
	lda #<operator_label
	sta string_ptr
	lda #>operator_label
	sta string_ptr+1

:
	jsr print_string

@next_line:

	; end with a return
	lda #$0d
	jsr BSOUT

	inx
	cpx Tokenizer::token_count
	beq @end_token_loop

	; update the next token address
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
	ply
	plx
	pla

	rts
.endproc

.proc print_string
	pha
	phx
	phy

	ldy #0

@print_loop:
	lda (string_ptr),y
	beq @end
	jsr BSOUT
	iny
@continue:
	bra @print_loop
@end:

	ply
	plx
	pla
	rts
.endproc

.endscope ; Main

.segment "DATA"

tokenizer_error_label: .literal $1c,"TOKENIZER ERROR!",$05,$0d,0
opcode_label: .literal "OPCODE",0
directive_label: .literal "DIRECTIVE",0
numeric_literal_label: .literal "NUMERIC LITERAL",0
operator_label: .literal "OPERATOR",0
