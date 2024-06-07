.section .data
    uno_msg:
        .string "Un argomento\n"
    due_msg:
        .string "Due argomenti\n"

.section .text
    .globl _start

_start:
    # Leggi il numero di argomenti passati
    movl %esp, %ebx
    movl (%ebx), %eax

    # Verifica il numero di argomenti
    cmpl $2, %eax
    je funzione_uno
    cmpl $3, %eax
    je funzione_due

    # Esci dal programma se il numero di argomenti non è 1 o 2
    movl $1, %eax
    xorl %ebx, %ebx
    int $0x80

funzione_uno:
    # Stampa il messaggio "Un argomento"
    movl $4, %eax
    movl $1, %ebx
    movl $uno_msg, %ecx
    movl $13, %edx
    int $0x80

    # Esci dal programma
    movl $1, %eax
    xorl %ebx, %ebx
    int $0x80

funzione_due:
    # Stampa il messaggio "Due argomenti"
    movl $4, %eax
    movl $1, %ebx
    movl $due_msg, %ecx
    movl $14, %edx
    int $0x80

    # Esci dal programma
    movl $1, %eax
    xorl %ebx, %ebx
    int $0x80

