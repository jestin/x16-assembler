.ifndef MNEMONIC_CHECKERS_ASM
MNEMONIC_CHECKERS_ASM = 1

; Included inside the Tokenizer scope

.segment "CODE"

;----------------------------------------------------------------------------
; mnemonic detection procs
;
; Each of these functions expect the potential mnemonic to be in cur_token_ptr,
; and will set the carry bit if it matches
;----------------------------------------------------------------------------

.proc check_cur_token_for_mnemonic
	lda (cur_token_ptr)
	cmp #$41 ; PETSCII A
	bne :+
	jsr check_mnemonics_A
	rts
:
	cmp #$42 ; PETSCII B
	bne :+
	jsr check_mnemonics_B
	rts
:
	cmp #$43 ; PETSCII C
	bne :+
	jsr check_mnemonics_C
	rts
:
	cmp #$44 ; PETSCII D
	bne :+
	jsr check_mnemonics_D
	rts
:
	cmp #$45 ; PETSCII E
	bne :+
	jsr check_mnemonics_E
	rts
:
	cmp #$49 ; PETSCII I
	bne :+
	jsr check_mnemonics_I
	rts
:
	cmp #$4a ; PETSCII J
	bne :+
	jsr check_mnemonics_J
	rts
:
	cmp #$4c ; PETSCII L
	bne :+
	jsr check_mnemonics_L
	rts
:
	cmp #$4e ; PETSCII N
	bne :+
	jsr check_mnemonics_N
	rts
:
	cmp #$4f ; PETSCII O
	bne :+
	jsr check_mnemonics_O
	rts
:
	cmp #$50 ; PETSCII P
	bne :+
	jsr check_mnemonics_P
	rts
:
	cmp #$52 ; PETSCII R
	bne :+
	jsr check_mnemonics_R
	rts
:
	cmp #$53 ; PETSCII S
	bne :+
	jsr check_mnemonics_S
	rts
:
	cmp #$54 ; PETSCII T
	bne :+
	jsr check_mnemonics_T
	rts
:
	cmp #$57 ; PETSCII W
	bne :+
	jsr check_mnemonics_W
	rts
:

; not found, so manually clear carry
	clc
	rts
.endproc ; check_cur_token_for_mnemonic

.proc check_mnemonics_A
	pha

	ldy #1
	lda (cur_token_ptr),y
	cmp #$44 ; PETSCII D
	beq @D
	cmp #$4e ; PETSCII N
	beq @N
	cmp #$53 ; PETSCII S
	beq @S

	bra @notmnemonic

@D:
	ldy #2
	lda (cur_token_ptr),y
	cmp #$43 ; PETSCII C
	bne @notmnemonic
	bra @mnemonic				; ADC
@N:
	ldy #2
	lda (cur_token_ptr),y
	cmp #$44 ; PETSCII D
	bne @notmnemonic
	bra @mnemonic				; AND
@S:
	ldy #2
	lda (cur_token_ptr),y
	cmp #$4c ; PETSCII L
	bne @notmnemonic
	bra @mnemonic				; ASL

@mnemonic:
	sec
	pla
	rts
@notmnemonic:
	clc
	pla
	rts
.endproc ; check_mnemonics_A

.proc check_mnemonics_B
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

	bra @notmnemonic

@B:
	ldy #2
	lda (cur_token_ptr),y
	cmp #$52 ; PETSCII R
	beq @mnemonic				; BBR
	cmp #$53 ; PETSCII S
	beq @mnemonic				; BBS
	bra @notmnemonic
@C:
	ldy #2
	lda (cur_token_ptr),y
	cmp #$43 ; PETSCII C
	beq @mnemonic				; BCC
	cmp #$53 ; PETSCII S
	beq @mnemonic				; BCS
	bra @notmnemonic
@E:
	ldy #2
	lda (cur_token_ptr),y
	cmp #$51 ; PETSCII Q
	beq @mnemonic				; BEQ
	bra @notmnemonic
@I:
	ldy #2
	lda (cur_token_ptr),y
	cmp #$54 ; PETSCII T
	beq @mnemonic				; BIT
	bra @notmnemonic
@M:
	ldy #2
	lda (cur_token_ptr),y
	cmp #$49 ; PETSCII I
	beq @mnemonic				; BMI
	bra @notmnemonic
@N:
	ldy #2
	lda (cur_token_ptr),y
	cmp #$45 ; PETSCII E
	beq @mnemonic				; BNE
	bra @notmnemonic
@P:
	ldy #2
	lda (cur_token_ptr),y
	cmp #$4c ; PETSCII L
	beq @mnemonic				; BPL
	bra @notmnemonic
@R:
	ldy #2
	lda (cur_token_ptr),y
	cmp #$41 ; PETSCII A
	beq @mnemonic				; BRA
	cmp #$4b ; PETSCII K
	beq @mnemonic				; BRK
	bra @notmnemonic
@V:
	ldy #2
	lda (cur_token_ptr),y
	cmp #$43 ; PETSCII C
	beq @mnemonic				; BVC
	cmp #$53 ; PETSCII K
	beq @mnemonic				; BVS
	bra @notmnemonic
	

@mnemonic:
	sec
	pla
	rts
@notmnemonic:
	clc
	pla
	rts
.endproc ; check_mnemonics_B

.proc check_mnemonics_C
	pha

	ldy #1
	lda (cur_token_ptr),y
	cmp #$4c ; PETSCII L
	beq @L
	cmp #$4d ; PETSCII M
	beq @M
	cmp #$50 ; PETSCII P
	beq @P

	bra @notmnemonic

@L:
	ldy #2
	lda (cur_token_ptr),y
	cmp #$43 ; PETSCII C
	beq @mnemonic				; CLC
	cmp #$44 ; PETSCII D
	beq @mnemonic				; CLD
	cmp #$49 ; PETSCII I
	beq @mnemonic				; CLI
	cmp #$56 ; PETSCII I
	beq @mnemonic				; CLV
	bra @notmnemonic
@M:
	ldy #2
	lda (cur_token_ptr),y
	cmp #$50 ; PETSCII P
	beq @mnemonic				; CMP
	bra @notmnemonic
@P:
	ldy #2
	lda (cur_token_ptr),y
	cmp #$58 ; PETSCII X
	beq @mnemonic				; CPX
	cmp #$59 ; PETSCII Y
	beq @mnemonic				; CPY
	bra @notmnemonic

@mnemonic:
	sec
	pla
	rts
@notmnemonic:
	clc
	pla
	rts
.endproc ; check_mnemonics_C

.proc check_mnemonics_D
	pha

	ldy #1
	lda (cur_token_ptr),y
	cmp #$45 ; PETSCII E
	beq @E

	bra @notmnemonic

@E:
	ldy #2
	lda (cur_token_ptr),y
	cmp #$43 ; PETSCII C
	beq @mnemonic				; DEC
	cmp #$58 ; PETSCII X
	beq @mnemonic				; DEX
	cmp #$59 ; PETSCII Y
	beq @mnemonic				; DEY
	bra @notmnemonic

@mnemonic:
	sec
	pla
	rts
@notmnemonic:
	clc
	pla
	rts
.endproc ; check_mnemonics_D

.proc check_mnemonics_E
	pha

	ldy #1
	lda (cur_token_ptr),y
	cmp #$4f ; PETSCII O
	beq @O

	bra @notmnemonic

@O:
	ldy #2
	lda (cur_token_ptr),y
	cmp #$52 ; PETSCII R
	beq @mnemonic				; EOR
	bra @notmnemonic

@mnemonic:
	sec
	pla
	rts
@notmnemonic:
	clc
	pla
	rts
.endproc ; check_mnemonics_E

.proc check_mnemonics_I
	pha

	ldy #1
	lda (cur_token_ptr),y
	cmp #$4e ; PETSCII N
	beq @N

	bra @notmnemonic

@N:
	ldy #2
	lda (cur_token_ptr),y
	cmp #$43 ; PETSCII C
	beq @mnemonic				; INC
	cmp #$58 ; PETSCII X
	beq @mnemonic				; INX
	cmp #$59 ; PETSCII Y
	beq @mnemonic				; INY
	bra @notmnemonic

@mnemonic:
	sec
	pla
	rts
@notmnemonic:
	clc
	pla
	rts
.endproc ; check_mnemonics_I

.proc check_mnemonics_J
	pha

	ldy #1
	lda (cur_token_ptr),y
	cmp #$4d ; PETSCII M
	beq @M
	cmp #$53 ; PETSCII S
	beq @S

	bra @notmnemonic

@M:
	ldy #2
	lda (cur_token_ptr),y
	cmp #$50 ; PETSCII P
	beq @mnemonic				; JMP
	bra @notmnemonic
@S:
	ldy #2
	lda (cur_token_ptr),y
	cmp #$52 ; PETSCII R
	beq @mnemonic				; JSR
	bra @notmnemonic

@mnemonic:
	sec
	pla
	rts
@notmnemonic:
	clc
	pla
	rts
.endproc ; check_mnemonics_J

.proc check_mnemonics_L
	pha

	ldy #1
	lda (cur_token_ptr),y
	cmp #$44 ; PETSCII D
	beq @D

	bra @notmnemonic

@D:
	ldy #2
	lda (cur_token_ptr),y
	cmp #$41 ; PETSCII A
	beq @mnemonic				; LDA
	cmp #$58 ; PETSCII X
	beq @mnemonic				; LDX
	cmp #$59 ; PETSCII Y
	beq @mnemonic				; LDY
	bra @notmnemonic

@mnemonic:
	sec
	pla
	rts
@notmnemonic:
	clc
	pla
	rts
.endproc ; check_mnemonics_L

.proc check_mnemonics_N
	pha

	ldy #1
	lda (cur_token_ptr),y
	cmp #$4f ; PETSCII O
	beq @O

	bra @notmnemonic

@O:
	ldy #2
	lda (cur_token_ptr),y
	cmp #$50 ; PETSCII P
	beq @mnemonic				; NOP
	bra @notmnemonic

@mnemonic:
	sec
	pla
	rts
@notmnemonic:
	clc
	pla
	rts
.endproc ; check_mnemonics_N

.proc check_mnemonics_O
	pha

	ldy #1
	lda (cur_token_ptr),y
	cmp #$52 ; PETSCII R
	beq @R

	bra @notmnemonic

@R:
	ldy #2
	lda (cur_token_ptr),y
	cmp #$41 ; PETSCII A
	beq @mnemonic				; ORA
	bra @notmnemonic

@mnemonic:
	sec
	pla
	rts
@notmnemonic:
	clc
	pla
	rts
.endproc ; check_mnemonics_O

.proc check_mnemonics_P
	pha

	ldy #1
	lda (cur_token_ptr),y
	cmp #$48 ; PETSCII H
	beq @H
	cmp #$4c ; PETSCII L
	beq @L

	bra @notmnemonic

@H:
	ldy #2
	lda (cur_token_ptr),y
	cmp #$41 ; PETSCII A
	beq @mnemonic				; PHA
	cmp #$50 ; PETSCII P
	beq @mnemonic				; PHP
	cmp #$58 ; PETSCII X
	beq @mnemonic				; PHX
	cmp #$59 ; PETSCII Y
	beq @mnemonic				; PHY
	bra @notmnemonic
@L:
	ldy #2
	lda (cur_token_ptr),y
	cmp #$41 ; PETSCII A
	beq @mnemonic				; PLA
	cmp #$50 ; PETSCII P
	beq @mnemonic				; PLP
	cmp #$58 ; PETSCII X
	beq @mnemonic				; PLX
	cmp #$59 ; PETSCII Y
	beq @mnemonic				; PLY
	bra @notmnemonic

@mnemonic:
	sec
	pla
	rts
@notmnemonic:
	clc
	pla
	rts
.endproc ; check_mnemonics_P

.proc check_mnemonics_R
	pha

	ldy #1
	lda (cur_token_ptr),y
	cmp #$4d ; PETSCII M
	beq @M
	cmp #$4f ; PETSCII O
	beq @O
	cmp #$54 ; PETSCII T
	beq @T

	bra @notmnemonic

@M:
	ldy #2
	lda (cur_token_ptr),y
	cmp #$42 ; PETSCII B
	beq @mnemonic				; RMB
	bra @notmnemonic
@O:
	ldy #2
	lda (cur_token_ptr),y
	cmp #$4c ; PETSCII L
	beq @mnemonic				; ROL
	cmp #$52 ; PETSCII R
	beq @mnemonic				; ROR
	bra @notmnemonic
@T:
	ldy #2
	lda (cur_token_ptr),y
	cmp #$49 ; PETSCII I
	beq @mnemonic				; RTI
	cmp #$53 ; PETSCII S
	beq @mnemonic				; RTS
	bra @notmnemonic

@mnemonic:
	sec
	pla
	rts
@notmnemonic:
	clc
	pla
	rts
.endproc ; check_mnemonics_R

.proc check_mnemonics_S
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

	bra @notmnemonic

@B:
	ldy #2
	lda (cur_token_ptr),y
	cmp #$43 ; PETSCII C
	beq @mnemonic				; SBC
	bra @notmnemonic
@E:
	ldy #2
	lda (cur_token_ptr),y
	cmp #$43 ; PETSCII C
	beq @mnemonic				; SEC
	cmp #$44 ; PETSCII D
	beq @mnemonic				; SED
	cmp #$49 ; PETSCII I
	beq @mnemonic				; SEI
	bra @notmnemonic
@M:
	ldy #2
	lda (cur_token_ptr),y
	cmp #$42 ; PETSCII B
	beq @mnemonic				; SMB
	bra @notmnemonic
@T:
	ldy #2
	lda (cur_token_ptr),y
	cmp #$41 ; PETSCII A
	beq @mnemonic				; STA
	cmp #$50 ; PETSCII P
	beq @mnemonic				; STP
	cmp #$58 ; PETSCII X
	beq @mnemonic				; STX
	cmp #$59 ; PETSCII Y
	beq @mnemonic				; STY
	cmp #$5a ; PETSCII Z
	beq @mnemonic				; STZ
	bra @notmnemonic

@mnemonic:
	sec
	pla
	rts
@notmnemonic:
	clc
	pla
	rts
.endproc ; check_mnemonics_S

.proc check_mnemonics_T
	pha

	ldy #1
	lda (cur_token_ptr),y
	cmp #$41 ; PETSCII A
	beq @A
	cmp #$52 ; PETSCII R
	beq @R
	cmp #$53 ; PETSCII S
	beq @S
	cmp #$58 ; PETSCII X
	beq @X
	cmp #$59 ; PETSCII Y
	beq @Y

	bra @notmnemonic

@A:
	ldy #2
	lda (cur_token_ptr),y
	cmp #$58 ; PETSCII X
	beq @mnemonic				; TAX
	cmp #$59 ; PETSCII Y
	beq @mnemonic				; TAY
	bra @notmnemonic
@R:
	ldy #2
	lda (cur_token_ptr),y
	cmp #$42 ; PETSCII B
	beq @mnemonic				; TRB
	bra @notmnemonic
@S:
	ldy #2
	lda (cur_token_ptr),y
	cmp #$42 ; PETSCII B
	beq @mnemonic				; TSB
	cmp #$58 ; PETSCII X
	beq @mnemonic				; TSX
	bra @notmnemonic
@X:
	ldy #2
	lda (cur_token_ptr),y
	cmp #$41 ; PETSCII A
	beq @mnemonic				; TXA
	cmp #$53 ; PETSCII S
	beq @mnemonic				; TXS
	bra @notmnemonic
@Y:
	ldy #2
	lda (cur_token_ptr),y
	cmp #$41 ; PETSCII A
	beq @mnemonic				; TYA
	bra @notmnemonic

@mnemonic:
	sec
	pla
	rts
@notmnemonic:
	clc
	pla
	rts
.endproc ; check_mnemonics_T

.proc check_mnemonics_W
	pha

	ldy #1
	lda (cur_token_ptr),y
	cmp #$41 ; PETSCII A
	beq @A

	bra @notmnemonic

@A:
	ldy #2
	lda (cur_token_ptr),y
	cmp #$49 ; PETSCII I
	beq @mnemonic				; WAI
	bra @notmnemonic

@mnemonic:
	sec
	pla
	rts
@notmnemonic:
	clc
	pla
	rts
.endproc ; check_mnemonics_W

.endif ; MNEMONIC_CHECKERS_ASM
