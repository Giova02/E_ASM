.section .data
    filename:
        .ascii "Ordini.txt"
    buffer:
        .space 1            # buffer per leggere un carattere alla volta

.section .bss
    filesize:
        .space 4            # variabile per memorizzare la dimensione del file
    char_read:
        .space 1            # variabile per memorizzare il carattere letto

.section .text
    .globl _start

_start:
    # Apre il file
    mov $5, %eax            # syscall open
    mov $filename, %ebx     # puntatore al nome del file
    mov $0, %ecx            # flags di apertura (O_RDONLY)
    int $0x80               # chiamata di sistema

    # Controllo errore apertura file
    test %eax, %eax
    js errore               # se c'è stato un errore, salta a 'errore'

    mov %eax, %edi          # Salva il file descriptor in %edi per il debug

ciclo_lettura:
    # Legge dal file
    mov $3, %eax            # syscall read
    mov %edi, %ebx          # fd del file
    mov $buffer, %ecx       # buffer per la lettura
    mov $1, %edx            # legge un carattere alla volta
    int $0x80               # chiamata di sistema

    # Controllo errore lettura file
    test %eax, %eax
    js errore               # se c'è stato un errore, salta a 'errore'

    # Controlla se abbiamo raggiunto la fine del file
    cmp $0, %eax
    je fine_programma

    # Stampa il carattere sul terminale
    mov $4, %eax            # syscall write
    mov $1, %ebx            # stdout
    mov $buffer, %ecx       # buffer contenente il carattere da stampare
    mov $1, %edx            # lunghezza del carattere da stampare (1)
    int $0x80               # chiamata di sistema

    jmp ciclo_lettura

fine_programma:
    # Chiude il file
    mov $6, %eax            # syscall close
    int $0x80               # chiamata di sistema

    # Termina il programma
    mov $1, %eax            # syscall exit
    xor %ebx, %ebx          # codice di uscita 0
    int $0x80               # chiamata di sistema

errore:
    # Gestisce l'errore
    mov $1, %eax            # syscall exit
    mov $1, %ebx            # codice di uscita 1 (errore)
    int $0x80               # chiamata di sistema

