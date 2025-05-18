.ifndef SYMBOL_ASM
SYMBOL_ASM = 1

; This assembler supports up to 256 symbols, each with a maximum length of 16
; characters.  The symbol table is stored in banked memory

SYMBOL_TABLE_BANK = 2

; NOTES:
; It might be better to implement this as a two lists; one for defined symbols
; and one for symbols whose definitions we are waiting for.  This could make it
; simpler to figure out if there are undefined symbols when we are finished
; assembling.

; bank values
symbols = $a000				; 4096 bytes
symbol_locations = $b000	; 512 bytes
; b200-bfff are currently unused

.scope Symbol

.segment "BSS"

; currently we support a maximum of 256 symbols
symbol_count: .res 1
next_symbol_ptr: .res 2

.segment "CODE"

;-------------------------------------------------------------------------------
; add_to_symbol_table
;-------------------------------------------------------------------------------
; Adds a symbol to the symbol table if it doesn't already exist.  This does not
; define the symbol's location.
; 
; Inputs: cur_symbol
; Ouputs: <none>
;-------------------------------------------------------------------------------
.proc add_to_symbol_table
.endproc ; add_to_symbol_table

;-------------------------------------------------------------------------------
; define_symbol
;-------------------------------------------------------------------------------
; Defines a symbol's location, whether the symbol exists or not.  Adds it to the
; symbol table if it doesn't already exist.
;
; Inputs: cur_symbol, location_counter
; Ouputs: <none>
;-------------------------------------------------------------------------------
.proc define_symbol
.endproc

.endscope ; Symbol

.endif ; SYMBOL_ASM
