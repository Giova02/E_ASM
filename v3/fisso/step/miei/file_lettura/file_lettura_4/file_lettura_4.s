.section .data
    time:
        .byte 0
    p_time:
        .byte 100
        
    product_num:
        .byte 0
    
    filename:
        .ascii "Ordini.txt" # Nome del file di testo da leggere
    fd:
        .int 0              # File descriptor
    
    newline: 
        .byte 10            # Valore del simbolo di nuova linea
    chars: 
        .byte 0             # Numero di caratteri

    offset: 
        .byte 0             # offset salvataggio dati

    errore_same_id_msg:
        .ascii "(!) Errore: Stessi dati prodotto trovati più volte\n"
    errore_same_id_msg_len:
        .long . - errore_same_id_msg
    

.section .bss
    buffer: 
        .ascii              # Spazio per il buffer di input

    addr_v_distance:
        .zero 2
        
    penality_val:
        .zero 2
        
    substring_s_tmp:
        .zero 11
    substring_len_tmp:
        .zero 4
    substring_id_tmp:
        .zero 1
    substring_du_tmp:
        .zero 1
    substring_dl_tmp:
        .zero 1
    substring_pr_tmp:
        .zero 1

    substring_s:
        .zero 11
    substring_len:
        .zero 4
    substring_id:
        .zero 1
    substring_du:
        .zero 1
    substring_dl:
        .zero 1
    substring_pr:
        .zero 1


.section .text
    .globl _start


_start:

# Apre il file
open:
    movl $5, %eax           # syscall open
    leal filename, %ebx     # Nome del file
    movl $0, %ecx           # Modalità di apertura (O_RDONLY)
    int $0x80               # Interrupt del kernel

    cmpl $0, %eax           # Se c'è un errore, esce
    jl exit

    movl %eax, fd           # Salva il file descriptor in ebx


read_loop:                  # Legge il file riga per riga
    movl $3, %eax           # syscall read
    movl fd, %ebx           # File descriptor
    leal buffer, %ecx       # Buffer di input
    movl $1, %edx           # Lunghezza massima
    int $0x80               # Interrupt del kernel

    cmpl $0, %eax           # Controllo se ci sono errori o EOF
    jle close_file          # Se ci sono errori o EOF, chiudo il file

    # Controllo se ho una nuova linea
    movb buffer, %al        # copio il carattere dal buffer ad AL
    cmpb newline, %al       # confronto AL con il carattere \n
    je next_string          # quando trova un carattere NewLine salta a "next_string" (sottrae il numero di caratteri trovati alla dimensione della struttura dati per trovare il corretto offset)
    jne print_line          # se sono diversi stampo la linea

next_string:
    incb product_num              # altrimenti, incremento il contatore

    leal chars, %eax        # carica l'indirizzo del numero di caratteri trovati
    movb $19, %bl           # carica la dimensione della struttura dati in BL (19 bytes)

    subb (%eax), %bl        # sottrae il numero di caratteri trovati alla dimensione della struttura dati per trovare il corretto offset
    leal offset, %eax       # carica l'indirizzo della variabile "offset" in EAX
    addb %bl, (%eax)        # salva il valore calcolato nella variabile "offset" puntata da EAX

    leal chars, %eax        # carica il valore di caratteri trovati in EAX
    movb $0, (%eax)         # azzera il contatore di caratteri trovati


print_line:
    # Stampa il contenuto della riga
    movl $4, %eax           # syscall write
    movl $1, %ebx           # File descriptor standard output (stdout)
    leal buffer, %ecx       # Buffer di output
    int $0x80               # Interrupt del kernel

    incb chars              # incrementa il contatore di caratteri trovati per riga

    jmp read_loop           # Torna alla lettura del file

# Chiude il file
close_file:
    movl $6, %eax           # syscall close
    movl %ebx, %ecx         # File descriptor
    int $0x80               # Interrupt del kernel

exit:  
    movl $1, %eax           # syscall exit
    xorl %ebx, %ebx         # Codice di uscita 0
    int $0x80               # Interrupt del kernel


.type save_byte, @function
save_byte:
    leal buffer, %eax
    leal substring_s, %ebx
    movb (%eax), %cl
    leal offset, %eax
    addl (%eax), %ebx
    movb %cl, (%ebx)
    incb offset
    ret
