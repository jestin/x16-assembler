.ifndef OPCODE_CHECKERS_ASM
OPCODE_CHECKERS_ASM = 1

; Included inside the Tokenizer scope

.segment "CODE"

;----------------------------------------------------------------------------
; opcode detection procs
;
; Each of these functions expect the potential opcode to be in cur_token_ptr,
; and will set the carry bit if it matches
;----------------------------------------------------------------------------

.proc check_cur_token_for_opcode
	lda (cur_token_ptr)
	cmp #$41 ; PETSCII A
	bne :+
	jsr check_opcodes_A
	rts
:
	cmp #$42 ; PETSCII B
	bne :+
	jsr check_opcodes_B
	rts
:

; not found, so manually clear carry
	clc
	rts
.endproc ; check_cur_token_for_opcode

.proc check_opcodes_A
	pha

	ldy #1
	lda (cur_token_ptr),y
	cmp #$44 ; PETSCII D
	beq @D
	cmp #$4e ; PETSCII N
	beq @N
	cmp #$53 ; PETSCII S
	beq @S

	bra @notopcode

@D:
	ldy #2
	lda (cur_token_ptr),y
	cmp #$43 ; PETSCII C
	bne @notopcode
	bra @opcode				; ADC
@N:
	ldy #2
	lda (cur_token_ptr),y
	cmp #$44 ; PETSCII D
	bne @notopcode
	bra @opcode				; AND
@S:
	ldy #2
	lda (cur_token_ptr),y
	cmp #$4c ; PETSCII L
	bne @notopcode
	bra @opcode				; ASL

@opcode:
	sec
	pla
	rts
@notopcode:
	clc
	pla
	rts
.endproc ; check_opcodes_A

.proc check_opcodes_B
	pha

	ldy #1
	lda (cur_token_ptr),y
	cmp #$42 ; PETSCII B
	beq @B
	cmp #$43 ; PETSCII C
	beq @C
	cmp #$45 ; PETSCII E
	beq @E
	cmp #$49 ; PETSCII I
	beq @I
	cmp #$4d ; PETSCII M
	beq @M
	cmp #$4e ; PETSCII N
	beq @N
	cmp #$50 ; PETSCII P
	beq @P
	cmp #$52 ; PETSCII R
	beq @R
	cmp #$56 ; PETSCII V
	beq @V

	bra @notopcode

@B:
	ldy #2
	lda (cur_token_ptr),y
	cmp #$52 ; PETSCII R
	beq @opcode				; BBR
	cmp #$53 ; PETSCII S
	beq @opcode				; BBS
	bra @notopcode
@C:
	ldy #2
	lda (cur_token_ptr),y
	cmp #$43 ; PETSCII C
	beq @opcode				; BCC
	cmp #$53 ; PETSCII S
	beq @opcode				; BCS
	bra @notopcode
@E:
	ldy #2
	lda (cur_token_ptr),y
	cmp #$51 ; PETSCII Q
	beq @opcode				; BEQ
	bra @notopcode
@I:
	ldy #2
	lda (cur_token_ptr),y
	cmp #$54 ; PETSCII T
	beq @opcode				; BIT
	bra @notopcode
@M:
	ldy #2
	lda (cur_token_ptr),y
	cmp #$49 ; PETSCII I
	beq @opcode				; BMI
	bra @notopcode
@N:
	ldy #2
	lda (cur_token_ptr),y
	cmp #$45 ; PETSCII E
	beq @opcode				; BNE
	bra @notopcode
@P:
	ldy #2
	lda (cur_token_ptr),y
	cmp #$4c ; PETSCII L
	beq @opcode				; BPL
	bra @notopcode
@R:
	ldy #2
	lda (cur_token_ptr),y
	cmp #$41 ; PETSCII A
	beq @opcode				; BRA
	cmp #$4b ; PETSCII K
	beq @opcode				; BRK
	bra @notopcode
@V:
	ldy #2
	lda (cur_token_ptr),y
	cmp #$43 ; PETSCII C
	beq @opcode				; BVC
	cmp #$53 ; PETSCII K
	beq @opcode				; BVS
	bra @notopcode
	

@opcode:
	sec
	pla
	rts
@notopcode:
	clc
	pla
	rts
.endproc ; check_opcodes_B

.endif ; OPCODE_CHECKERS_ASM
