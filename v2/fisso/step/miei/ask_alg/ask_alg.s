.section .data
    ask_alg_msg:
        .ascii "(?): Quale algoritmo di pianificazione dovrà usare il programma?\n\t1) Earliest Deadline First (EDF)\n\t2) Highest Priority First (HPF)\n\nPremi CTRL + C per uscire\n\n> "
    ask_alg_msg_len:
        .long . - ask_alg_msg
    invalid_alg_error_msg:
        .ascii "(!) Errore: Inserimento scelta algoritmo invalido\n"
    invalid_alg_error_msg_len:
        .long . - invalid_alg_error_msg
.section .bss
    alg:
        .byte

.section .text
    .globl _start

_start:
ask_alg:
    movl $4, %eax
    movl $1, %ebx
    leal ask_alg_msg, %ecx
    movl ask_alg_msg_len, %edx
    int $0x80
    
    movl $3, %eax
    movl $0, %ebx
    leal alg, %ecx
    movl $1, %edx
    int $0x80

    movb alg, %al
    cmpb $'1', %al
    je EDF
    cmpb $'2', %al
    je HPF
    jmp invalid_alg_error


EDF:
HPF:
    movl $4, %eax
    movl $1, %ebx
    leal alg, %ecx
    movl $1, %edx
    int $0x80
    jmp exit

invalid_alg_error:
    movl $4, %eax
    movl $1, %ebx
    leal invalid_alg_error_msg, %ecx
    movl invalid_alg_error_msg_len, %edx
    int $0x80

    jmp exit_w_error
    

exit_w_error:
    # Esci dal programma
    movl $1, %eax       # SystemCall EXIT
    movl $1, %ebx       # EXIT code 1 (Errore)
    int $0x80


exit:
    # Esci dal programma
    movl $1, %eax       # SystemCall EXIT
    movl $0, %ebx       # EXIT code 0 (Nessun errore)
    int $0x80
