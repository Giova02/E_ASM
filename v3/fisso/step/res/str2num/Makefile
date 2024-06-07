EXE=str2num
AS= as --32
LD= ld -m elf_i386
FLAGS=	-gstabs
OBJ=str2num.o

$(EXE): $(OBJ)
	$(LD) -o $(EXE) $(OBJ)

str2num.o: str2num.s
	$(AS) $(FLAGS) -o str2num.o str2num.s

clean:
	rm -f *.o $(EXE) core
