.ifndef CHARACTER_CHECKERS_ASM
CHARACTER_CHECKERS_ASM = 1

; Included inside the Tokenizer scope

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
	rts
@not_number:
	clc
	rts
.endproc ; check_numeric

.proc check_binary
	; check for a numeric value
	cmp #$30 ; PETSCII 0
	bmi @not_binary ; less than PETSCII 0
	cmp #$32 ; PETSCII : (one greater than PETSCII 1)
	bcs @not_binary
	sec
	rts
@not_binary:
	clc
	rts
.endproc ; check_binary

.proc check_hexadecimal
	; check for a numeric value
	cmp #$30 ; PETSCII 0
	bmi @not_number ; less than PETSCII 0
	cmp #$3a ; PETSCII : (one greater than PETSCII 9)
	bcs @not_number
	sec
	rts
@not_number:
	; check if it is A-F
	cmp #$41 ; PETSCII A
	bmi @not_alpha_hex ; less than PETSCII A
	cmp #$47 ; PETSCII : (one greater than PETSCII F)
	bcs @not_alpha_hex
	sec
@not_alpha_hex:
	rts
.endproc ; check_hexadecimal

.proc check_alpha
	; check for an alpha value
	cmp #$41 ; PETSCII A
	bmi @not_alpha ; less than PETSCII A
	cmp #$5b ; PETSCII : (one greater than PETSCII Z)
	bcs @not_alpha
	sec
@not_alpha:

	rts
.endproc ; check_alpha

.proc check_hexadecimal_prefix
	; check for hex prefix
	cmp #$24
	beq @hexadecimal_prefix
	; neither a prefix nor numeric
	clc
@hexadecimal_prefix:
	; carry will already be set if we get here
	rts
.endproc ;check_hexadecimal_prefix

.proc check_binary_prefix
	; check for hex prefix
	cmp #$25
	beq @binary_prefix
	; neither a prefix nor numeric
	clc
@binary_prefix:
	; carry will already be set if we get here
	rts
.endproc ;check_binary_prefix

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

.proc check_directive_start
	cmp #$2e
	bne @not_period
	rts
@not_period:
	clc
	rts

@format_prefix:
	; carry will already be set if we get here
	rts

.endproc ; check_directive_start

.endif ; CHARACTER_CHECKERS_ASM
