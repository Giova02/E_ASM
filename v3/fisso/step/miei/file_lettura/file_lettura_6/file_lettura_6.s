.section .data
    product_n:
        .byte 0
    filename:
        .ascii "Ordini.txt" # Nome del file di testo da leggere
    fd:
        .int 0              # File descriptor
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
        .zero 1024              # Spazio per il buffer di input
        
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

open_file:
    # Apre il file 
    movl $5, %eax           # SystemCall OPEN
    leal filename, %ebx     # Nome del file
    movl $0, %ecx           # Modalità di apertura (Read-Only)
    int $0x80               # Interrupt del kernel

    cmpl $0, %eax           # Se c'è un errore, esce
    jl file_open_error

    movl %eax, fd           # Salva il file descriptor in EBX


read_file:
    # Legge e salva il contenuto del file in "buffer" 
    movl $3, %eax           # SystemCall READ
    movl fd, %ebx           # File descriptor
    leal buffer, %ecx       # Buffer di input
    movl $1024, %edx        # Lunghezza buffer
    int $0x80               # Interrupt del kernel


    # salva le sottostringhe
    leal substring_s, %edx              # salva l'indirizzo dell'allocazione della prima stringa nella variabile EDX
    leal buffer, %ebx                   # salva l'indirizzo dell'allocazione del buffer in EBX

    xorl %eax, %eax                     # pulisce EAX

save_loop:
    cmpb $0, (%ebx)                     # verifica se è stata raggiunta la fine del buffer
    je print_saved

    cmpb $10, (%ebx)                    # Controlla se il carattere letto è "\n"
    je next_substring                   # se "\n", salta a "next_substring"

    movb (%ebx), %cl                    # carica il carattere letto in CL
    movb %cl, (%eax, %edx)              # carica CL nel byte puntato nella sottostringa

    incl %eax                           # incrementa l'offset puntando al prossimo byte nella sottostringa
    incl %ebx                           # incrementa il puntatore al buffer di un byte 
    
    jmp save_loop

next_substring:
    incl %ebx                           # incrementa il puntatore al buffer di un byte 
    incb product_n                      # incrementa il numero di prodotti che sono stati salvati
    xorl %eax, %eax                     # pulisce EAX
    
    cmpb $0, (%ebx)                     # verifica se è stata raggiunta la fine del buffer
    je print_saved

    addl $19, %edx                      # incrementa EDX puntando alla prossima sottostringa nella quale salvare i dati
    jmp save_loop


close_file:
    # Chiude il file 
    movl $6, %eax           # SystemCall CLOSE
    movl %ebx, %ecx         # File descriptor
    int $0x80               # Interrupt del kernel
    
    jmp exit

    
file_open_error:
    # Stampa il messaggio d'errore "(!) Errore: Impossibile aprire il file"
    movl $4, %eax
    movl $1, %ebx
    leal file_open_error_msg, %ecx
    movl file_open_error_msg_len, %edx
    int $0x80

    jmp exit_w_error


print_saved:
    movl $4, %eax
    movl $1, %ebx
    movl $substring_s, %ecx
    movl $19456, %edx       # 1024 * 19 = 19456
    int $0x80

    jmp exit


exit:  
    # Uscita senza errori
    movl $1, %eax           # SystemCall exit
    xorl %ebx, %ebx         # Codice di uscita 0
    int $0x80               # Interrupt del kernel
    

exit_w_error:
    # Uscita con errori
    movl $1, %eax           # SystemCall EXIT
    movl $1, %ebx           # EXIT code 1 (Errore)
    int $0x80
