NAME = ASM
ASSEMBLER6502 = cl65
ASFLAGS = -t cx16 -l $(NAME).list

PROG = $(NAME).PRG
LIST = $(NAME).list
MAIN = main.asm
SOURCES = $(MAIN) \
		  x16.inc \
		  vera.inc \
		  tokenizer.asm

all: $(PROG)

$(PROG): $(SOURCES)
	$(ASSEMBLER6502) $(ASFLAGS) -o $(PROG) $(MAIN)

run: all
	x16emu -prg $(PROG) -run -scale 2 -debug

clean:
	rm -f $(PROG) $(LIST)
	

