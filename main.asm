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
space_counter: .res 1
cur_line: .res 256

.segment "CODE"

; test files

hello_asm: .literal "HELLO.ASM"
end_hello_asm:

; redefinitions

string_ptr = u0
scratch = u1L

.proc main
	lda #1
	ldx #8
	ldy #0
	jsr SETLFS
	lda #(end_hello_asm-hello_asm)
	ldx #<hello_asm
	ldy #>hello_asm
	jsr SETNAM
	jsr OPEN
	ldx #1
	jsr CHKIN

	ldx #0

@line_loop:
@char_loop:
	jsr BASIN
	sta cur_line,x
	inx
	cmp #$0d		; eol
	beq @end_of_line
	bra @char_loop

@end_of_line:
	; write a 0 to end the string
	lda #0
	sta cur_line,x

	jsr Tokenizer::parse
	
	; check for error flag
	beq :+

	; print tokenizer error
	lda #<tokenizer_error_label
	sta string_ptr
	lda #>tokenizer_error_label
	sta string_ptr+1
	jsr print_string
	bra @end
:
	jsr print_tokens

	; read the status for end of file
	jsr READST
	bit #%01000000
	bne @end_of_file

	ldx #0
	stz Tokenizer::token_count
	bra @line_loop

@end_of_file:

	; redirect input back to keyboard
	ldx #0
	jsr CHKIN

	; close the input file
	lda #1
	jsr CLOSE

@end:
	rts
.endproc

.proc print_tokens
	pha
	phx
	phy

	ldx #0

	lda #<Tokenizer::cur_tokens
	sta Tokenizer::token_char_ptr
	lda #>Tokenizer::cur_tokens
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

	tya
	sta scratch
	sec
	lda #15
	sbc scratch
	sta space_counter

	; print enough spaces to make nice columns
@space_print_loop:
	lda #$20 ; PETSCII space
	jsr BSOUT
	dec space_counter
	bmi @end_space_print_loop
	bra @space_print_loop
@end_space_print_loop:

	jsr print_token_type

@next_line:

	; end with a return
	lda #$0d
	jsr BSOUT

	inx
	cpx Tokenizer::token_count
	bcs @end_token_loop

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

.proc print_token_type
	; print the token type on the same line
	lda Tokenizer::cur_token_types,x
	cmp #Tokenizer::TOKEN_TYPE_OPCODE
	beq @token_type_opcode
	cmp #Tokenizer::TOKEN_TYPE_DIRECTIVE
	beq @token_type_directive
	cmp #Tokenizer::TOKEN_TYPE_DECIMAL_LITERAL
	beq @token_type_decimal_literal
	cmp #Tokenizer::TOKEN_TYPE_HEXADECIMAL_LITERAL
	beq @token_type_hexadecimal_literal
	cmp #Tokenizer::TOKEN_TYPE_BINARY_LITERAL
	beq @token_type_binary_literal
	cmp #Tokenizer::TOKEN_TYPE_OPERATOR
	beq @token_type_operator
	cmp #Tokenizer::TOKEN_TYPE_SEPARATOR
	beq @token_type_separator
	cmp #Tokenizer::TOKEN_TYPE_SYMBOL
	beq @token_type_symbol
	cmp #Tokenizer::TOKEN_TYPE_COMMENT
	beq @token_type_comment
	bra @end

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
@token_type_decimal_literal:
	lda #<decimal_literal_label
	sta string_ptr
	lda #>decimal_literal_label
	sta string_ptr+1
	bra :+
@token_type_hexadecimal_literal:
	lda #<hexadecimal_literal_label
	sta string_ptr
	lda #>hexadecimal_literal_label
	sta string_ptr+1
	bra :+
@token_type_binary_literal:
	lda #<binary_literal_label
	sta string_ptr
	lda #>binary_literal_label
	sta string_ptr+1
	bra :+
@token_type_operator:
	lda #<operator_label
	sta string_ptr
	lda #>operator_label
	sta string_ptr+1
	bra :+
@token_type_separator:
	lda #<separator_label
	sta string_ptr
	lda #>separator_label
	sta string_ptr+1
	bra :+
@token_type_symbol:
	lda #<symbol_label
	sta string_ptr
	lda #>symbol_label
	sta string_ptr+1
	bra :+
@token_type_comment:
	lda #<comment_label
	sta string_ptr
	lda #>comment_label
	sta string_ptr+1
:
	jsr print_string

@end:
	rts
.endproc ; print_token_type

.endscope ; Main

.segment "DATA"

tokenizer_error_label: .literal $1c,"TOKENIZER ERROR!",$05,$0d,0
opcode_label: .literal "OPCODE",0
directive_label: .literal "DIRECTIVE",0
comment_label: .literal "COMMENT",0
decimal_literal_label: .literal "DECIMAL LITERAL",0
hexadecimal_literal_label: .literal "HEXADECIMAL LITERAL",0
binary_literal_label: .literal "BINARY LITERAL",0
operator_label: .literal "OPERATOR",0
separator_label: .literal "SEPARATOR",0
symbol_label: .literal "SYMBOL",0
