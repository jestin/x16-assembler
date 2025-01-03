.ifndef PARSER_ASM
PARSER_ASM = 1

.segment "BSS"

; states of the state machine
STATE_NEW_TOKEN = 0
STATE_COMPLETED_TOKEN = 1
STATE_END_OF_CODE = 2
STATE_ERROR = 3
STATE_NUMERIC_LITERAL = 4
STATE_OPERATOR = 5

; Tokens will be stored in banked memory separated by 0s
TOKEN_BANK = 1
TOKEN_BANK_ADDRESS = $A000

; store the current state of the state machine
state: .res 1

; the number of tokens
token_count: .res 1

.segment "CODE"

; split jump table of state routines
parser_state_jump_table_lo:
	.byte <new_token_state
	.byte <complete_token_state
	.byte <end_of_code_state
	.byte <error_state
	.byte <numeric_literal_state
	.byte <operator_state

parser_state_jump_table_hi:
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
	sta u2L
	lda #>TOKEN_BANK_ADDRESS
	sta u2H

	; point to the syntax
	lda #<test_syntax
	sta u0L
	lda #>test_syntax
	sta u0H
	
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
	lda parser_state_jump_table_lo,x
	sta u1L
	lda parser_state_jump_table_hi,x
	sta u1H
	jmp (u1)
@end_state_loop:
	; we shouldn't get this far because the end_of_code_state routine should
	; return from the parser

.endproc

.proc new_token_state

	; read the next character
	lda (u0)

	; increment next character
	; increment next token character
	inc u0L
	bne :+
	inc u0H
:
	
	; TODO: check for invalid first characters for tokens

	ldy #0
	sta (u2),y

	; increment next token character
	inc u2L
	bne :+
	inc u2H
:

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
	lda #STATE_END_OF_CODE
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
	sta (u2),y

	; increment next token character
	inc u2L
	bne :+
	inc u2H
:

	; set the state to NEW TOKEN
	lda #STATE_NEW_TOKEN
	sta state

	rts
.endproc

.proc end_of_code_state
	; pull the top of the loop off the stack so that rts returns from the
	; parser
	pla
	pla

	; this should now return to whomever called parser
	rts
.endproc

.proc error_state
	; pull the top of the loop off the stack so that rts returns from the
	; parser
	stp
	pla
	pla
	rts
.endproc

.proc numeric_literal_state
	; for now, we assume each token is a single character which has already
	; been read
	; set the state to COMPLETED TOKEN
	lda #STATE_COMPLETED_TOKEN
	sta state
	rts
.endproc

.proc operator_state
	; for now, we assume each token is a single character which has already
	; been read
	; set the state to COMPLETED TOKEN
	lda #STATE_COMPLETED_TOKEN
	sta state
	rts
.endproc

.segment "DATA"

test_syntax:
.literal "2+3",0

.endif ; PARSER_ASM

