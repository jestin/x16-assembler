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

cur_token_length: .res 1

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

;------------------------------------------------------------
; state procs
;------------------------------------------------------------

.proc new_token_state

	; read the next character (it will still need to be read later)
	lda (code_ptr)
	beq @end_of_code
	
	; TODO: check for invalid first characters for tokens

	stz cur_token_length

	; check for whitespace
	jsr check_whitespace
	bcc @nonwhitespace
	; if whitespace increment the cope pointer and return
	inc code_ptr
	bne :+
	inc code_ptr+1
:
	rts
@nonwhitespace:
	jsr check_numeric_start
	bcc :+
	bra @numeric_literal
:
	jsr check_operator
	bcc :+
	bra @operator
:
	; if we get this far, we are invalid
	bra @error

@numeric_literal:
	; add the token type
	ldy #0
	lda #TOKEN_TYPE_NUMERIC_LITERAL
	sta (token_type_ptr),y
	
	; update the state
	lda #STATE_NUMERIC_LITERAL
	sta state
	bra @end
@operator:
	; add the token type
	ldy #0
	lda #TOKEN_TYPE_OPERATOR
	sta (token_type_ptr),y
	
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
	; increment next token character
	inc token_type_ptr
	bne :+
	inc token_type_ptr+1
:
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
	beq @completed_numeric

	; increment next character
	; increment next token character
	inc code_ptr
	bne :+
	inc code_ptr+1
:

	; check if we are a format prefix
	jsr check_number_prefix
	bcc @check_numeric

	; check if we are the first character in the token, otherwise error
	pha
	lda cur_token_length
	bne @format_not_at_start_error
	pla
	bra @add_to_token

@check_numeric:
	; check if we are a number
	jsr check_numeric
	bcs @add_to_token

	; here we are neither a numeric, a prefix, nor the end of code
	; we should only end with end of code, whitespace, or an operator

	jsr check_whitespace
	bcs @completed_numeric

	jsr check_operator
	bcs @completed_with_operator

	; we are now in an error condition
	bra @error

@add_to_token:
	; increment current token length
	inc cur_token_length

	; add to the current token
	ldy #0
	sta (token_char_ptr),y

	; increment next token character
	inc token_char_ptr
	bne :+
	inc token_char_ptr+1
:
	; return in the same state
	rts
@completed_with_operator:
	; need to decrement the code_ptr
	lda code_ptr
	bne :+
	dec code_ptr+1
:
	dec code_ptr
@completed_numeric:
	; set the state to COMPLETED TOKEN
	lda #STATE_COMPLETED_TOKEN
	sta state
	rts
@format_not_at_start_error:
	pla
@error:
	; set the state to ERROR
	lda #STATE_ERROR
	sta state
	rts
.endproc

.proc operator_state
	; read the next character
	lda (code_ptr)
	beq @completed_operator

	; increment next character
	; increment next token character
	inc code_ptr
	bne :+
	inc code_ptr+1
:
	; check that we are still a number 
	jsr check_operator
	bcc @completed_operator

	; add to the current token
	ldy #0
	sta (token_char_ptr),y

	; increment next token character
	inc token_char_ptr
	bne :+
	inc token_char_ptr+1
:

@completed_operator:
	lda #STATE_COMPLETED_TOKEN
	sta state
	rts
.endproc

;------------------------------------------------------------
; character detection procs
;
; Each of these functions expect the character to be in A,
; and will set the carry bit if it matches
;------------------------------------------------------------

.proc check_whitespace
	; check for whitespace
	cmp #$20 ; space
	beq @whitespace
	cmp #$60 ; graphic space
	beq @whitespace
	cmp #$a0 ; space reversed
	beq @whitespace
	cmp #$e0 ; graphic space reversed
	beq @whitespace
	clc
	rts
@whitespace:
	; carry will already be set if we get here
	rts
.endproc ; check_whitespace

.proc check_numeric
	; check for a numeric value
	cmp #$30 ; PETSCII 0
	bmi @not_number ; less than PETSCII 0
	cmp #$3a ; PETSCII : (one greater than PETSCII 9)
	bcs @not_number
	sec
@not_number:

	rts
.endproc ; check_numeric

.proc check_numeric_start

	jsr check_numeric
	bcc :+
	; it is 0-9, so return with carry set (from the above jsr)
	rts
:
	jsr check_number_prefix
	bcc @not_prefix
	rts
@not_prefix:
	rts

@format_prefix:
	; carry will already be set if we get here
	rts

.endproc ; check_numeric_start

.proc check_number_prefix
	; check for hex prefix
	cmp #$24
	beq @format_prefix
	; check for binary prefix
	cmp #$25
	beq @format_prefix

	; neither a prefix nor numeric
	clc
	rts
@format_prefix:
	; carry will already be set if we get here
	rts
.endproc ;check_number_prefix

.proc check_operator
	; check for operator
	cmp #$2a ; PETSCII *
	beq @operator
	cmp #$2b ; PETSCII +
	beq @operator
	cmp #$2d ; PETSCII -
	beq @operator
	cmp #$2f ; PETSCII -
	beq @operator

	; not an operator
	clc
	rts
@operator:
	; carry will already be set if we get here
	rts
.endproc ; check_operator

.endscope ; Tokenizer

.segment "DATA"

test_syntax:
.literal "%24 + $345-1",0

.endif ; TOKENIZER_ASM

