.segment "STARTUP"
.segment "INIT"
.segment "ONCE"
.segment "CODE"

.scope Main

	jmp Main::main

.include "x16.inc"
.include "vera.inc"
.include "macros.inc"

.include "memory.inc"
.include "file.asm"
.include "tokenizer.asm"

.segment "BSS"

list_filename: .res 22 ; @: + 16 characters + ,S,W

token_type: .res 1
space_counter: .res 1
cur_line: .res 256
location_counter: .res 2

.segment "CODE"

; test files

hello_asm: .literal "HELLO.ASM"
end_hello_asm:

hello_base: .literal "HELLO",0
end_hello_base:

; redefinitions

string_ptr = u0
scratch = u1L

; constants

ASSEMBLY_FILE = 1
LIST_FILE = 2

.proc main

	; Open input file for reading
	lda #(end_hello_asm-hello_asm)
	ldx #<hello_asm
	ldy #>hello_asm
	jsr SETNAM
	lda #ASSEMBLY_FILE
	ldx #8
	ldy #0
	jsr SETLFS
	jsr OPEN
	
	; load the address of the result file name
	lda #<list_filename
	sta u1L
	lda #>list_filename
	sta u1H
	; load the address of the base file name
	lda #<hello_base
	sta u0L
	lda #>hello_base
	sta u0H

	jsr File::get_list_file_name

	; Open list file for writing
	lda #(end_hello_base-hello_base)+10
	ldx #<list_filename
	ldy #>list_filename
	jsr SETNAM
	lda #LIST_FILE
	ldx #8
	ldy #2
	jsr SETLFS
	jsr OPEN

	; reset the location counter
	stz location_counter
	stz location_counter+1

	ldx #0

@line_loop:
	jsr CLRCHN
	ldx #ASSEMBLY_FILE
	jsr CHKIN
	ldx #0
	stz Tokenizer::token_count
@char_loop:
	jsr BASIN
	sta cur_line,x
	cmp #$0d		; eol
	beq @end_of_line
	inx
	bra @char_loop

@end_of_line:
	txa
	beq @line_loop

	; write a 0 to end the string
	inx
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

	; read the status for end of file
	jsr READST
	pha				; push status word to stack to check later
					; in case the file ends on this line

	; if no tokens were read, continue rather than print
	lda Tokenizer::token_count
	beq @check_end_of_file

	jsr print_tokens

	; at this point we need to:
	; 1.  Evaluate any expressions
	; 2.  Determine byte size of all tokens
	; 3.  Update the location counter
	; 4.  Write out line to listing file
	; 5.  Probably other stuff

	jsr CLRCHN

	ldx #LIST_FILE
	jsr CHKOUT
	jsr print_cur_line

@check_end_of_file:

	pla				; pull the status word from the last read
	and #%01000000
	beq @line_loop

@end_of_file:

	; reset output
	jsr CLRCHN

	; close the input file
	lda #ASSEMBLY_FILE
	jsr CLOSE

	; close the list file
	lda #LIST_FILE
	jsr CLOSE

@end:
	rts
.endproc

.proc print_cur_line
	ldx #0
@print_loop:
	lda cur_line,x
	beq @end
	jsr BSOUT
	jsr READST
	inx
	bra @print_loop

@end:
	rts
.endproc ;print_cur_line

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
	lda (Tokenizer::token_char_ptr),y
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
	adc Tokenizer::token_char_ptr
	sta Tokenizer::token_char_ptr
	lda #0
	adc Tokenizer::token_char_ptr+1
	sta Tokenizer::token_char_ptr+1

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
	cmp #Tokenizer::TOKEN_TYPE_STARTING_PARENTHESIS
	beq @token_type_starting_parenthesis
	cmp #Tokenizer::TOKEN_TYPE_ENDING_PARENTHESIS
	beq @token_type_ending_parenthesis
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
@token_type_starting_parenthesis:
	lda #<starting_parenthesis_label
	sta string_ptr
	lda #>starting_parenthesis_label
	sta string_ptr+1
	bra :+
@token_type_ending_parenthesis:
	lda #<ending_parenthesis_label
	sta string_ptr
	lda #>ending_parenthesis_label
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
starting_parenthesis_label: .literal "STARTING PARENTHESIS",0
ending_parenthesis_label: .literal "ENDING PARENTHESIS",0
symbol_label: .literal "SYMBOL",0
