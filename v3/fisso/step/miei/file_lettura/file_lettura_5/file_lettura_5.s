.section .data
    time:
        .byte 0
    p_time:
        .byte 100
        
    product_n:
        .byte 0
    
    product_printed:
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

    file_open_error_msg:
        .ascii "(!) Errore: Impossibile aprire il file\n"
    file_open_error_msg_len:
        .long . - file_open_error_msg

    file_read_error_msg:
        .ascii "(!) Errore: Impossibile leggere il contenuto del file\n"
    file_read_error_msg_len:
        .long . - file_read_error_msg
        

.section .bss
    buffer: 
        .ascii              # Spazio per il buffer di input
        
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
    movl $5, %eax           # SystemCall OPEN
    leal filename, %ebx     # Nome del file
    movl $0, %ecx           # Modalità di apertura (Read-Only)
    int $0x80               # Interrupt del kernel

    cmpl $0, %eax           # Se c'è un errore, esce
    jl file_open_error

    movl %eax, fd           # Salva il file descriptor in EBX

    leal substring_s, %esi  # salva il puntatore alla prima stringa salvata in ESI


read_loop:                  # Legge il file riga per riga
    movl $3, %eax           # SystemCall READ
    movl fd, %ebx           # File descriptor
    leal buffer, %ecx       # Buffer di input
    movl $1, %edx           # Lunghezza buffer
    int $0x80               # Interrupt del kernel

    cmpl $0, %eax           # Controlla se ci sono errori o EOF
    je close_file_eof       # EOF, chiude il file 
    jl file_read_error      # Errore durante la lettura, chiude il file, avvisa dell'errore e termina il programma

    # Controllo se ho uno \n
    movb buffer, %al        # copio il carattere dal buffer ad AL
    cmpb newline, %al       # confronto AL con il carattere \n
    jne save_char           # se sono diversi salva il carattere nella sottostringa allocata
    je save_string_len      # quando trova un carattere NewLine va a salvare la lunghezza della stringa


save_char:
    movb %al, chars(%esi)   # salva il valore del carattere letto nella corretta posizione nella sua stringa
    incb chars              # incrementa il contatore di caratteri trovati per riga

    jmp read_loop           # Torna alla lettura del file


save_string_len:
    # Salva la lunghezza della stringa in "substring_len"
    xorl %eax, %eax         # pulisce EAX
    movb chars, %al         # carica il numero di caratteri della stringa letta in AL
    movl %eax, 11(%esi)     # salva il numero di caratteri della stringa nella sua allocazione "substring_len"

    addl $19, %esi          # incrementa il puntatore alla prossima stringa da salvare

    leal chars, %eax        # carica l'indirizzo del numero di caratteri in EAX
    movb $0, (%eax)         # pulisce il contatore di caratteri in vista alla prossima stringa

    incb product_n          # incrementa il contatore i prodotti

    jmp read_loop           # Torna alla lettura del file


close_file_eof:
    # Chiude il file 
    movl $6, %eax           # SystemCall CLOSE
    movl %ebx, %ecx         # File descriptor
    int $0x80               # Interrupt del kernel

    incb product_n


file_read_error:
    # Chiude il file 
    movl $6, %eax           # SystemCall CLOSE
    movl %ebx, %ecx         # File descriptor
    int $0x80               # Interrupt del kernel

    # Stampa il messaggio d'errore "(!) Errore: Impossibile leggere il contenuto del file"
    movl $4, %eax
    movl $1, %ebx
    leal file_read_error_msg, %ecx
    movl file_read_error_msg_len, %edx
    int $0x80

    jmp exit_w_error


file_open_error:
    # Stampa il messaggio d'errore "(!) Errore: Impossibile aprire il file"
    movl $4, %eax
    movl $1, %ebx
    leal file_open_error_msg, %ecx
    movl file_open_error_msg_len, %edx
    int $0x80

    jmp exit_w_error

exit:  
    movl $1, %eax           # SystemCall exit
    xorl %ebx, %ebx         # Codice di uscita 0
    int $0x80               # Interrupt del kernel
    
exit_w_error:
    movl $1, %eax           # SystemCall EXIT
    movl $1, %ebx           # EXIT code 1 (Errore)
    int $0x80

print_substrings:
    leal substring_s, %esi      # salva in ESI l'indirizzo della base della prima sottostringa salvata
    xorl %edi, %edi             # inizializza il registro che farà da contatore

    
print_loop:
    movl $4, %eax           
    movl $1, %ebx
    movl %esi, %ecx
    movl 11(%esi), %edx

    addl $19, %esi

    leal product_printed, %eax  # salva in EAX l'indirizzo del numero di prodotti stampati
    incb (%eax)                 # incrementa il numero di prodotti stampati

    xorl %ebx, %ebx             # pulisce EBX
    movb product_n, %bl         # copia il numero di prodotti in BL

    cmpb (%eax), %bl            # verifica se sono stati stampati tutti i prodotti
    je exit                     # se si, esce
    jl print_loop               # se no, stampa il prossimo

