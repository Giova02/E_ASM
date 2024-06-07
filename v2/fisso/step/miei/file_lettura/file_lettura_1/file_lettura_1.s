.section .data
    file_name:
        .ascii "Ordini.txt"
    read_error_msg:
        .ascii "Errore durante la lettura del file\n"
    open_error_msg:
        .ascii "Errore durante l'apertura del file\n"
        
file_descriptor:
    .int 0                      # File descriptor

    # Variabili .ascii per le sottostringhe
    substring_0:
        .skip 256
    substring_1:
        .skip 256
    substring_2:
        .skip 256
    substring_3:
        .skip 256
    substring_4:
        .skip 256
    substring_5:
        .skip 256
    substring_6:
        .skip 256
    substring_7:
        .skip 256
    substring_8:
        .skip 256
    substring_9:
        .skip 256

.section .bss

.section .text
    .globl _start

_start:
    # Apri il file
    movl $5, %eax               # syscall per open
    movl $file_name, %ebx       # indirizzo del nome del file
    movl $0, %ecx               # modalità di apertura (0 = read-only)
    int $0x80
    
    cmpl $0, %eax               # verifica se l'apertura ha avuto successo
    jl open_error               # se eax < 0, l'apertura ha fallito

    movl %eax, file_descriptor  # salva il descrittore del file

read_loop:
    xorl %ebx, %ebx             # indice della variabile .ascii corrente
    xorl %edi, %edi             # puntatore all'interno della variabile .ascii corrente

read_substring:
    movl %ebx, %edx             # copia l'indice della variabile .ascii in edx
    sall $8, %edx               # moltiplica edx per 256 (dimensione delle variabili .ascii)
    movl $substring_0, %eax     # carica l'indirizzo di substring_0 in eax
    addl %edx, %eax             # calcola l'indirizzo della variabile .ascii corrente
    addl %edi, %eax             # aggiungi l'offset all'interno della variabile .ascii

    movl $3, %eax               # syscall per read
    movl file_descriptor, %ebx  # descrittore del file
    movl %eax, %ecx             # indirizzo di destinazione della lettura
    movl $1, %edx               # numero di byte da leggere
    int $0x80
    cmp $0, %eax                # verifica se la lettura ha avuto successo
    jle read_error              # se eax <= 0, la lettura ha fallito

    cmpb $10, (%eax)            # verifica se il carattere letto è newline
    je next_substring           # se sì, passa alla prossima sottostringa

    incl %edi                   # incrementa il puntatore all'interno della variabile .ascii
    jmp read_substring          # continua a leggere la sottostringa corrente

next_substring:
    incl %ebx                   # passa alla prossima variabile .ascii
    cmpl $10, %ebx              # verifica se abbiamo raggiunto il limite di 10 variabili
    je read_loop_end            # se sì, esci dal loop

    jmp read_loop               # continua a leggere la prossima sottostringa

read_loop_end:
    # Chiudi il file
    movl $6, %eax               # syscall per close
    movl file_descriptor, %ebx  # descrittore del file
    int $0x80

    # Esci dal programma
    movl $1, %eax               # syscall per exit
    xorl %ebx, %ebx             # codice di uscita 0
    int $0x80

open_error:
    # Stampa il messaggio di errore di apertura del file
    movl $4, %eax               # syscall per write
    movl $1, %ebx               # stdout
    movl $open_error_msg, %ecx  # indirizzo del messaggio di errore
    movl $36, %edx              # lunghezza del messaggio
    int $0x80

    # Esci dal programma
    movl $1, %eax               # syscall per exit
    movl $1, %ebx               # codice di uscita 1 (errore)
    int $0x80

read_error:
    # Stampa il messaggio di errore di lettura del file
    movl $4, %eax               # syscall per write
    movl $1, %ebx               # stdout
    movl $read_error_msg, %ecx  # indirizzo del messaggio di errore
    movl $36, %edx              # lunghezza del messaggio
    int $0x80

exit:
    # Esci dal programma
    movl $1, %eax               # syscall per exit
    movl $1, %ebx               # codice di uscita 1 (errore)
    int $0x80
