.ifndef FILE_ASM
FILE_ASM = 1

.scope File

.segment "BSS"

output_ptr: .res 2

.segment "CODE"

; redefinitions

base_ptr = u0
filename_ptr = u1

;---------------------------------------------------------------
; get_list_file_name
;
; Function:  Constructs a list file name from a base name.
;            
;
; Pass:        u0     pointer to zero-terminated base of the filename
;              u1     pointer to where the filename should be
;                     constructed
; Affects:     X,Y,u1
; Preserves:   X,Y,u1
;---------------------------------------------------------------
.proc get_list_file_name
	phx
	phy
	lda u1L
	pha
	lda u1H
	pha

	; construct list filename
	; these first two characters cause the file to be overwritten
	lda #$40 ; @
	sta (u1)
	IncW u1
	lda #$3a ; :
	sta (u1)
	IncW u1
	ldy #0
@constuct_list_filename_loop:
	lda (u0),y
	beq @end_of_base
	sta (u1)
	IncW u1
	iny
	bra @constuct_list_filename_loop
@end_of_base:
	; add the .LST extension
	lda #$2e ; .
	sta (u1)
	IncW u1
	lda #$4c ; L
	sta (u1)
	IncW u1
	lda #$53 ; S
	sta (u1)
	IncW u1
	lda #$54 ; T
	sta (u1)
	IncW u1
	; these last few characters cause the file to be writeable (regardless of
	; the secondary address used
	lda #$2c ; ,
	sta (u1)
	IncW u1
	lda #$53 ; S
	sta (u1)
	IncW u1
	lda #$2c ; ,
	sta (u1)
	IncW u1
	lda #$57 ; W
	sta (u1)

	pla
	sta u1H
	pla
	sta u1L
	ply
	plx
	rts
.endproc ; get_list_file_name

;---------------------------------------------------------------
; get_program_file_name
;
; Function:  Constructs a program file name from a base name.
;            
;
; Pass:        u0     pointer to zero-terminated base of the filename
;              u1     pointer to where the filename should be
;                     constructed
; Affects:     X,Y,u1
; Preserves:   X,Y,u1
;---------------------------------------------------------------
.proc get_program_file_name
	phx
	phy
	lda u1L
	pha
	lda u1H
	pha

	; construct list filename
	; these first two characters cause the file to be overwritten
	lda #$40 ; @
	sta (u1)
	IncW u1
	lda #$3a ; :
	sta (u1)
	IncW u1
	ldy #0
@constuct_list_filename_loop:
	lda (u0),y
	beq @end_of_base
	sta (u1)
	IncW u1
	iny
	bra @constuct_list_filename_loop
@end_of_base:
	; add the .PRG extension
	lda #$2e ; .
	sta (u1)
	IncW u1
	lda #$50 ; P
	sta (u1)
	IncW u1
	lda #$52 ; R
	sta (u1)
	IncW u1
	lda #$47 ; G
	sta (u1)
	IncW u1
	; these last few characters cause the file to be writeable (regardless of
	; the secondary address used
	lda #$2c ; ,
	sta (u1)
	IncW u1
	lda #$53 ; S
	sta (u1)
	IncW u1
	lda #$2c ; ,
	sta (u1)
	IncW u1
	lda #$57 ; W
	sta (u1)

	pla
	sta u1H
	pla
	sta u1L
	ply
	plx
	rts
.endproc ; get_program_file_name

.endscope ; File

.endif ; FILE_ASM
