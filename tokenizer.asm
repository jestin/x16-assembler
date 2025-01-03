.ifndef TOKENIZER_ASM
TOKENIZER_ASM = 1

.scope Tokenizer

.segment "BSS"

; states of the state machine
STATE_NEW_TOKEN = 0
STATE_COMPLETED_TOKEN = 1
STATE_END_OF_CODE = 2
STATE_ERROR = 3
STATE_NUMERIC_LITERAL = 4
STATE_OPERATOR = 5

; token types
TOKEN_TYPE_OPCODE = 0
TOKEN_TYPE_DIRECTIVE = 1
TOKEN_TYPE_NUMERIC_LITERAL = 2
TOKEN_TYPE_OPERATOR = 3

; store the current state of the state machine
state: .res 1

; the number of tokens
token_count: .res 1

.segment "CODE"


; redefinitions

code_ptr = u0
token_char_ptr = u2
token_type_ptr = u3

; split jump table of state routines
tokenizer_state_jump_table_lo:
	.byte <new_token_state
	.byte <complete_token_state
	.byte <end_of_code_state
	.byte <error_state
	.byte <numeric_literal_state
	.byte <operator_state

tokenizer_state_jump_table_hi:
	.byte >new_token_state
	.byte >complete_token_state
	.byte >end_of_code_state
	.byte >error_state
	.byte >numeric_literal_state
	.byte >operator_state


.proc parse

	; set the token count to 0
	lda #0
	sta token_count

	; set the token bank (do not change in any of these routines)
	lda #TOKEN_BANK
	sta $00

	; initialize next token address
	lda #<TOKEN_BANK_ADDRESS
	sta token_char_ptr
	lda #>TOKEN_BANK_ADDRESS
	sta token_char_ptr+1

	; initialize next token type address
	lda #<TOKEN_TYPE_BANK_ADDRESS
	sta token_type_ptr
	lda #>TOKEN_TYPE_BANK_ADDRESS
	sta token_type_ptr+1

	; point to the syntax
	lda #<test_syntax
	sta code_ptr
	lda #>test_syntax
	sta code_ptr+1
	
	; set the state to NEW TOKEN
	lda #STATE_NEW_TOKEN
	sta state

@state_loop:
	nop
	; Push the address of the state loop to the stack, so that each
	; state subroutine returns to the top of the loop.  The rts from
	; each subroutine will pop the value from the stack.  We will only manually
	; pop it when ending the loop
	lda #>(@state_loop)
	pha
	lda #<(@state_loop)
	pha
	
	; check the state
	ldx state
	lda tokenizer_state_jump_table_lo,x
	sta u1L
	lda tokenizer_state_jump_table_hi,x
	sta u1H
	jmp (u1)
@end_state_loop:
	; we shouldn't get this far because the end_of_code_state routine should
	; return from the tokenizer

.endproc

.proc new_token_state

	; read the next character (it will still need to be read later)
	lda (code_ptr)
	
	; TODO: check for invalid first characters for tokens

	; determine next state by the first character (when possible)

	; check for the end of the code
	cmp #0
	beq @end_of_code

	; check for a numeric value
	cmp #$30 ; PETSCII 0
	bmi :+ ; less than PETSCII 0
	cmp #$3a ; PETSCII : (one greater than PETSCII 9)
	bcs :+
	bra @numeric_literal

:
	; check for operator
	cmp #$2a ; PETSCII *
	beq @operator
	cmp #$2b ; PETSCII +
	beq @operator
	cmp #$2d ; PETSCII -
	beq @operator
	cmp #$2f ; PETSCII -
	beq @operator
	
	; if we get this far, we are invalid
	bra @error

@numeric_literal:
	lda #STATE_NUMERIC_LITERAL
	sta state
	bra @end
@operator:
	lda #STATE_OPERATOR
	sta state
	bra @end

@end_of_code:
	lda #STATE_END_OF_CODE
	sta state
	rts ; exit immediately

@error:
	lda #STATE_ERROR
	sta state
	rts ; exit immediately

@end:
	rts
.endproc

.proc complete_token_state
	; increment token count
	inc token_count

	; write a 0 as a delimeter
	lda #0
	ldy #0
	sta (token_char_ptr),y

	; increment next token character
	inc token_char_ptr
	bne :+
	inc token_char_ptr+1
:

	; set the state to NEW TOKEN
	lda #STATE_NEW_TOKEN
	sta state

	rts
.endproc

.proc end_of_code_state
	; pull the top of the loop off the stack so that rts returns from the
	; tokenizer
	pla
	pla

	; set the Z flag to zero to indicate success
	lda #0 ; 

	; this should now return to whomever called tokenizer
	rts
.endproc

.proc error_state
	; pull the top of the loop off the stack so that rts returns from the
	; tokenizer
	pla
	pla

	; set the Z flag to 1 to indicate failure
	lda #1 ; 

	rts
.endproc

.proc numeric_literal_state
	; read the next character
	lda (code_ptr)

	; increment next character
	; increment next token character
	inc code_ptr
	bne :+
	inc code_ptr+1
:
	; add to the current token
	ldy #0
	sta (token_char_ptr),y

	; increment next token character
	inc token_char_ptr
	bne :+
	inc token_char_ptr+1
:

	; add the token type
	ldy #0
	lda #TOKEN_TYPE_NUMERIC_LITERAL
	sta (token_type_ptr),y
	
	; increment next token character
	inc token_type_ptr
	bne :+
	inc token_type_ptr+1
:
	
	; set the state to COMPLETED TOKEN
	lda #STATE_COMPLETED_TOKEN
	sta state
	rts
.endproc

.proc operator_state
	; read the next character
	lda (code_ptr)

	; increment next character
	; increment next token character
	inc code_ptr
	bne :+
	inc code_ptr+1
:
	; add to the current token
	ldy #0
	sta (token_char_ptr),y

	; increment next token character
	inc token_char_ptr
	bne :+
	inc token_char_ptr+1
:

	; add the token type
	ldy #0
	lda #TOKEN_TYPE_OPERATOR
	sta (token_type_ptr),y
	
	; increment next token character
	inc token_type_ptr
	bne :+
	inc token_type_ptr+1
:

	lda #STATE_COMPLETED_TOKEN
	sta state
	rts
.endproc

.endscope ; Tokenizer

.segment "DATA"

test_syntax:
.literal "2 +3",0

.endif ; TOKENIZER_ASM

