.section .data

    file_lettura: 
        .int 0                      # file "Ordini.txt" dove leggere gli ordini
    file_scrittura: 
        .int 0                      # file in cui scrivere l output


.section .text     
    .global _start 

_start:

    popl %ecx                       #  salvo il valore puntato del numero di argomenti

    subl $1, %ecx                   #  sottraggo 1 a il nomero puntato in ecx (numero argomenti)

    cmp $0, %ecx
    je error

    cmp $1, %ecx
    je un_argomento

    cmp $2, %ecx
    je due_argomenti

    jg error

un_argomento:
    popl %ecx
    popl file_lettura

    jmp exit

due_argomenti:
    popl %ecx
    popl file_lettura
    popl file_scrittura

    jmp exit


exit:
    # Esci dal programma
    movl $1, %eax                       # SystemCall EXIT
    movl $0, %ebx                       # EXIT code 0 (Nessun errore)
    int $0x80
