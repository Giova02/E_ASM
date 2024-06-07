.section .data
    filename:
        .ascii "Ordini.txt"

.section .bss
    buffer:
        .space 1            # buffer per leggere un carattere alla volta
    filesize:
        .space 4            # variabile per memorizzare la dimensione del file
    char_read:
        .space 1            # variabile per memorizzare il carattere letto

    # Variabili .ascii per le sottostringhe
    substring_0:
        .space 257          # Spazio per 256 caratteri più un carattere di terminazione nulla
    substring_1:
        .space 257
    substring_2:
        .space 257
    substring_3:
        .space 257
    substring_4:
        .space 257
    substring_5:
        .space 257
    substring_6:
        .space 257
    substring_7:
        .space 257
    substring_8:
        .space 257
    substring_9:
        .space 257
    substring_tmp:
        .space 257

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

    mov %eax, %edi          # Salva il file descriptor in %edi

    # Ottiene la dimensione del file
    mov $19, %eax           # syscall fstat
    mov %edi, %ebx          # file descriptor
    mov $filesize, %ecx     # puntatore alla struttura stat
    int $0x80               # chiamata di sistema

    # Controllo errore fstat
    test %eax, %eax
    js errore               # se c'è stato un errore, salta a 'errore'

    # Carica la dimensione del file
    mov filesize, %eax

    #   # Controlla se il file è vuoto
    #   test %eax, %eax
    #   jz fine_programma       # se il file è vuoto, termina il programma

    # Inizializza le sottostringhe con il carattere di terminazione nulla
    mov $0, substring_0
    mov $0, substring_1
    mov $0, substring_2
    mov $0, substring_3
    mov $0, substring_4
    mov $0, substring_5
    mov $0, substring_6
    mov $0, substring_7
    mov $0, substring_8
    mov $0, substring_9
    mov $0, substring_tmp

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
    je stampa_sottostringhe

    # Controlla se il carattere letto è '\n'
    cmpb $10, buffer
    je nuova_sottostringa
    
    # Salva il carattere nella prima sottostringa
    mov buffer, %al
    mov %al, substring_0(%ecx)
    inc %ecx

    jmp ciclo_lettura

nuova_sottostringa:
    # Aggiunge un carattere di terminazione nulla alla fine della sottostringa
    mov $0, substring_0(%ecx)

    # Incrementa il contatore delle sottostringhe
    inc %edi

    # Controlla se siamo oltre il numero massimo di sottostringhe
    cmp $10, %edi
    jge fine_programma

    # Resetta l'indice per la nuova sottostringa
    mov $0, %ecx

    jmp ciclo_lettura

stampa_sottostringhe:
    # Close file (syscall 6)
    movl $6, %eax          # Syscall number for 'close'
    movl %edi, %ebx        # Carica il file descriptor in %ebx
    int $0x80              # Call kernel
    test %eax, %eax        # Test if close was successful
    js errore              # Jump to error if close failed

    # Stampa il contenuto di ogni sottostringa sul terminale
    mov $0, %esi           # Inizializza il contatore delle sottostringhe a 0

stampa_loop:
    cmp $10, %esi          # Controlla se siamo oltre il numero massimo di sottostringhe
    jge fine_programma

    mov %esi, %edi         # Carica l'indice della sottostringa da stampare
    mov $substring_0, %esi # Carica l'indirizzo della prima sottostringa

    add %edi, %esi         # Aggiunge l'offset per ottenere l'indirizzo della sottostringa corrente
    mov $4, %eax           # syscall write
    mov $1, %ebx           # File descriptor (stdout)
    mov %esi, %ecx         # Indirizzo della sottostringa da stampare
    mov $256, %edx         # Lunghezza della sottostringa (escludendo il carattere di terminazione nulla)
    int $0x80              # chiamata di sistema

    inc %esi               # Passa alla prossima sottostringa
    jmp stampa_loop

fine_programma:
    # Termina il programma
    mov $1, %eax            # syscall exit
    xor %ebx, %ebx          # codice di uscita 0
    int $0x80               # chiamata di sistema

errore:
    # Gestisce l'errore
    mov $1, %eax            # syscall exit
    mov $1, %ebx            # codice di uscita 1 (errore)
    int $0x80               # chiamata di sistema

