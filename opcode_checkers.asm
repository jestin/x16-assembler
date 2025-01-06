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
	cmp #$43 ; PETSCII C
	bne :+
	jsr check_opcodes_C
	rts
:
	cmp #$44 ; PETSCII D
	bne :+
	jsr check_opcodes_D
	rts
:
	cmp #$45 ; PETSCII E
	bne :+
	jsr check_opcodes_E
	rts
:
	cmp #$49 ; PETSCII I
	bne :+
	jsr check_opcodes_I
	rts
:
	cmp #$4a ; PETSCII J
	bne :+
	jsr check_opcodes_J
	rts
:
	cmp #$4c ; PETSCII L
	bne :+
	jsr check_opcodes_L
	rts
:
	cmp #$4e ; PETSCII N
	bne :+
	jsr check_opcodes_N
	rts
:
	cmp #$4f ; PETSCII O
	bne :+
	jsr check_opcodes_O
	rts
:
	cmp #$50 ; PETSCII P
	bne :+
	jsr check_opcodes_P
	rts
:
	cmp #$52 ; PETSCII R
	bne :+
	jsr check_opcodes_R
	rts
:
	cmp #$53 ; PETSCII S
	bne :+
	jsr check_opcodes_S
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

.proc check_opcodes_C
	pha

	ldy #1
	lda (cur_token_ptr),y
	cmp #$4c ; PETSCII L
	beq @L
	cmp #$4d ; PETSCII M
	beq @M
	cmp #$50 ; PETSCII P
	beq @P

	bra @notopcode

@L:
	ldy #2
	lda (cur_token_ptr),y
	cmp #$43 ; PETSCII C
	beq @opcode				; CLC
	cmp #$44 ; PETSCII D
	beq @opcode				; CLD
	cmp #$49 ; PETSCII I
	beq @opcode				; CLI
	cmp #$56 ; PETSCII I
	beq @opcode				; CLV
	bra @notopcode
@M:
	ldy #2
	lda (cur_token_ptr),y
	cmp #$50 ; PETSCII P
	beq @opcode				; CMP
	bra @notopcode
@P:
	ldy #2
	lda (cur_token_ptr),y
	cmp #$58 ; PETSCII X
	beq @opcode				; CPX
	cmp #$59 ; PETSCII Y
	beq @opcode				; CPY
	bra @notopcode

@opcode:
	sec
	pla
	rts
@notopcode:
	clc
	pla
	rts
.endproc ; check_opcodes_C

.proc check_opcodes_D
	pha

	ldy #1
	lda (cur_token_ptr),y
	cmp #$45 ; PETSCII E
	beq @E

	bra @notopcode

@E:
	ldy #2
	lda (cur_token_ptr),y
	cmp #$43 ; PETSCII C
	beq @opcode				; DEC
	cmp #$58 ; PETSCII X
	beq @opcode				; DEX
	cmp #$59 ; PETSCII Y
	beq @opcode				; DEY
	bra @notopcode

@opcode:
	sec
	pla
	rts
@notopcode:
	clc
	pla
	rts
.endproc ; check_opcodes_D

.proc check_opcodes_E
	pha

	ldy #1
	lda (cur_token_ptr),y
	cmp #$4f ; PETSCII O
	beq @O

	bra @notopcode

@O:
	ldy #2
	lda (cur_token_ptr),y
	cmp #$52 ; PETSCII R
	beq @opcode				; EOR
	bra @notopcode

@opcode:
	sec
	pla
	rts
@notopcode:
	clc
	pla
	rts
.endproc ; check_opcodes_E

.proc check_opcodes_I
	pha

	ldy #1
	lda (cur_token_ptr),y
	cmp #$4e ; PETSCII N
	beq @N

	bra @notopcode

@N:
	ldy #2
	lda (cur_token_ptr),y
	cmp #$43 ; PETSCII C
	beq @opcode				; INC
	cmp #$58 ; PETSCII X
	beq @opcode				; INX
	cmp #$59 ; PETSCII Y
	beq @opcode				; INY
	bra @notopcode

@opcode:
	sec
	pla
	rts
@notopcode:
	clc
	pla
	rts
.endproc ; check_opcodes_I

.proc check_opcodes_J
	pha

	ldy #1
	lda (cur_token_ptr),y
	cmp #$4d ; PETSCII M
	beq @M
	cmp #$53 ; PETSCII S
	beq @S

	bra @notopcode

@M:
	ldy #2
	lda (cur_token_ptr),y
	cmp #$50 ; PETSCII P
	beq @opcode				; JMP
	bra @notopcode
@S:
	ldy #2
	lda (cur_token_ptr),y
	cmp #$52 ; PETSCII R
	beq @opcode				; JSR
	bra @notopcode

@opcode:
	sec
	pla
	rts
@notopcode:
	clc
	pla
	rts
.endproc ; check_opcodes_J

.proc check_opcodes_L
	pha

	ldy #1
	lda (cur_token_ptr),y
	cmp #$44 ; PETSCII D
	beq @D

	bra @notopcode

@D:
	ldy #2
	lda (cur_token_ptr),y
	cmp #$41 ; PETSCII A
	beq @opcode				; LDA
	cmp #$58 ; PETSCII X
	beq @opcode				; LDX
	cmp #$59 ; PETSCII Y
	beq @opcode				; LDY
	bra @notopcode

@opcode:
	sec
	pla
	rts
@notopcode:
	clc
	pla
	rts
.endproc ; check_opcodes_L

.proc check_opcodes_N
	pha

	ldy #1
	lda (cur_token_ptr),y
	cmp #$4f ; PETSCII O
	beq @O

	bra @notopcode

@O:
	ldy #2
	lda (cur_token_ptr),y
	cmp #$50 ; PETSCII P
	beq @opcode				; NOP
	bra @notopcode

@opcode:
	sec
	pla
	rts
@notopcode:
	clc
	pla
	rts
.endproc ; check_opcodes_N

.proc check_opcodes_O
	pha

	ldy #1
	lda (cur_token_ptr),y
	cmp #$52 ; PETSCII R
	beq @R

	bra @notopcode

@R:
	ldy #2
	lda (cur_token_ptr),y
	cmp #$41 ; PETSCII A
	beq @opcode				; ORA
	bra @notopcode

@opcode:
	sec
	pla
	rts
@notopcode:
	clc
	pla
	rts
.endproc ; check_opcodes_O

.proc check_opcodes_P
	pha

	ldy #1
	lda (cur_token_ptr),y
	cmp #$48 ; PETSCII H
	beq @H
	cmp #$4c ; PETSCII L
	beq @L

	bra @notopcode

@H:
	ldy #2
	lda (cur_token_ptr),y
	cmp #$41 ; PETSCII A
	beq @opcode				; PHA
	cmp #$50 ; PETSCII P
	beq @opcode				; PHP
	cmp #$58 ; PETSCII X
	beq @opcode				; PHX
	cmp #$59 ; PETSCII Y
	beq @opcode				; PHY
	bra @notopcode
@L:
	ldy #2
	lda (cur_token_ptr),y
	cmp #$41 ; PETSCII A
	beq @opcode				; PLA
	cmp #$50 ; PETSCII P
	beq @opcode				; PLP
	cmp #$58 ; PETSCII X
	beq @opcode				; PLX
	cmp #$59 ; PETSCII Y
	beq @opcode				; PLY
	bra @notopcode

@opcode:
	sec
	pla
	rts
@notopcode:
	clc
	pla
	rts
.endproc ; check_opcodes_P

.proc check_opcodes_R
	pha

	ldy #1
	lda (cur_token_ptr),y
	cmp #$4d ; PETSCII M
	beq @M
	cmp #$4f ; PETSCII O
	beq @O
	cmp #$54 ; PETSCII T
	beq @T

	bra @notopcode

@M:
	ldy #2
	lda (cur_token_ptr),y
	cmp #$42 ; PETSCII B
	beq @opcode				; RMB
	bra @notopcode
@O:
	ldy #2
	lda (cur_token_ptr),y
	cmp #$4c ; PETSCII L
	beq @opcode				; ROL
	cmp #$52 ; PETSCII R
	beq @opcode				; ROR
	bra @notopcode
@T:
	ldy #2
	lda (cur_token_ptr),y
	cmp #$49 ; PETSCII I
	beq @opcode				; RTI
	cmp #$53 ; PETSCII S
	beq @opcode				; RTS
	bra @notopcode

@opcode:
	sec
	pla
	rts
@notopcode:
	clc
	pla
	rts
.endproc ; check_opcodes_R

.proc check_opcodes_S
	pha

	ldy #1
	lda (cur_token_ptr),y
	cmp #$42 ; PETSCII B
	beq @B
	cmp #$45 ; PETSCII E
	beq @E
	cmp #$4d ; PETSCII M
	beq @M
	cmp #$54 ; PETSCII T
	beq @T

	bra @notopcode

@B:
	ldy #2
	lda (cur_token_ptr),y
	cmp #$43 ; PETSCII C
	beq @opcode				; SBC
	bra @notopcode
@E:
	ldy #2
	lda (cur_token_ptr),y
	cmp #$43 ; PETSCII C
	beq @opcode				; SEC
	cmp #$44 ; PETSCII D
	beq @opcode				; SED
	cmp #$49 ; PETSCII I
	beq @opcode				; SEI
	bra @notopcode
@M:
	ldy #2
	lda (cur_token_ptr),y
	cmp #$42 ; PETSCII B
	beq @opcode				; SMB
	bra @notopcode
@T:
	ldy #2
	lda (cur_token_ptr),y
	cmp #$41 ; PETSCII A
	beq @opcode				; STA
	cmp #$50 ; PETSCII P
	beq @opcode				; STP
	cmp #$58 ; PETSCII X
	beq @opcode				; STX
	cmp #$59 ; PETSCII Y
	beq @opcode				; STY
	cmp #$5a ; PETSCII Z
	beq @opcode				; STZ
	bra @notopcode

@opcode:
	sec
	pla
	rts
@notopcode:
	clc
	pla
	rts
.endproc ; check_opcodes_S

.endif ; OPCODE_CHECKERS_ASM
