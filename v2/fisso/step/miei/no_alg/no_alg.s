# ############### SEZIONE DATAA ################

.section .data

# ARGOMENTI
    args_1_msg:
        .ascii "(MSG) Output mode: Terminal only\n"
    args_1_msg_len:
        .long . - args_1_msg
    args_2_msg:
        .ascii "(MSG) Output mode: Terminal + File\n"
    args_2_msg_len:
        .long . - args_2_msg
    invalid_args_num_msg:
        .ascii "(!) Errore: Numero di argomenti inseriti non valido\n"
    invalid_args_num_msg_len:
        .long . - invalid_args_num_msg

# FILE LETTURA
    product_n:
        .byte 0
    filename:
        .ascii "Ordini.txt"
    fd:
        .int 0
    file_open_error_msg:
        .ascii "(!) Errore: Impossibile aprire il file\n"
    file_open_error_msg_len:
        .long . - file_open_error_msg
    file_read_error_msg:
        .ascii "(!) Errore: Impossibile leggere il contenuto del file\n"
    file_read_error_msg_len:
        .long . - file_read_error_msg  

# SUBSTRING TO DATA
    substring_s_comma_c:
        .byte 0
    substring_s_product_c:
        .byte 0
    SStoDATA_loop_nc2_mul:
        .byte 0

# ADDRESS VECTOR
    av_offset:
        .int 0
    av_addr:
        .int 0

# ASK ALG
    ask_alg_msg:
        .ascii "(?): Quale algoritmo di pianificazione dovrà usare il programma?\n\t1) Earliest Deadline First (EDF)\n\t2) Highest Priority First (HPF)\n\nPremi CTRL + C per uscire\n\n> "
    ask_alg_msg_len:
        .long . - ask_alg_msg
    invalid_alg_error_msg:
        .ascii "(!) Errore: Inserimento scelta algoritmo invalido\n"
    invalid_alg_error_msg_len:
        .long . - invalid_alg_error_msg

# ALGORITMI
    time:
        .int 0
    penality:
        .int 0

# PRINT RES
    printed_products:
        .byte 0
    substring_print_addr:
        .int 0

# Debug Print
    newline:
        .ascii "\n"
    print_product_n_msg:
        .ascii "(MSG) Products Number: "
    print_product_n_msg_len:
        .long . - print_product_n_msg
    selected_edf_msg:
        .ascii "\n(MSG) Algoritmo: EDF\n"
    selected_edf_msg_len:
        .long . - selected_edf_msg
    selected_hpf_msg:
        .ascii "\n(MSG) Algoritmo: HPF\n"
    selected_hpf_msg_len:
        .long . - selected_hpf_msg

# ############### SEZIONE BSS ################

.section .bss

# ARGOMENTI
    output_mode:                        # 1 = Terminal only   |   2 = Terminal + File
        .byte

# FILE LETTURA
    buffer: 
        .zero 1024                      # Spazio per il buffer di input

# ASK ALG
    alg:
        .byte

# EDF & HPF
    substring_tmp_addr:
        .zero 4

    substring_s:
        .zero 12
    substring_len:
        .zero 1
    substring_id:
        .zero 1
    substring_du:
        .zero 1
    substring_dl:
        .zero 1
    substring_pr:
        .zero 1


# ############### SEZIONE TEXT ###############

.section .text
    .globl _start

_start:
    # Leggi il numero di argomenti passati
    movl %esp, %ebx
    movl (%ebx), %eax

    # Verifica il numero di argomenti
    cmpl $2, %eax
    je args_1
    cmpl $3, %eax
    je args_2

    jmp invalid_args_num

args_1:
    # Stampa il messaggio "(MSG) Output mode: Terminal only"
    movl $4, %eax
    movl $1, %ebx
    leal args_1_msg, %ecx
    movl args_1_msg_len, %edx
    int $0x80

    leal output_mode, %eax
    movb $1, (%eax)

    jmp open_file

args_2:
    # Stampa il messaggio "(MSG) Output mode: Terminal + File"
    movl $4, %eax
    movl $1, %ebx
    leal args_2_msg, %ecx
    movl args_2_msg_len, %edx
    int $0x80

    leal output_mode, %eax
    movb $2, (%eax)

    jmp open_file


open_file:
    # Apre il file 
    movl $5, %eax                       # SystemCall OPEN
    leal filename, %ebx                 # Nome del file
    movl $0, %ecx                       # Modalità di apertura (Read-Only)
    int $0x80                           # Interrupt del kernel

    cmpl $0, %eax                       # Se c'è un errore, esce
    jl file_open_error          

    movl %eax, fd                       # Salva il file descriptor in EBX


read_file:
    # Legge e salva il contenuto del file in "buffer" 
    movl $3, %eax                       # SystemCall READ
    movl fd, %ebx                       # File descriptor
    leal buffer, %ecx                   # Buffer di input
    movl $1024, %edx                    # Lunghezza buffer
    int $0x80                           # Interrupt del kernel


    # salva le sottostringhe
    leal substring_s, %edx              # salva l'indirizzo dell'allocazione della prima stringa nella variabile EDX
    leal buffer, %ebx                   # salva l'indirizzo dell'allocazione del buffer in EBX

    xorl %eax, %eax                     # pulisce EAX

save_loop:
    cmpb $0, (%ebx)                     # verifica se è stata raggiunta la fine del buffer
    je close_file_il

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
    je close_file_nil

    addl $17, %edx                      # incrementa EDX puntando alla prossima sottostringa nella quale salvare i dati
    jmp save_loop


close_file_il:                          # jump fatto da "save_loop" quindi InLoop (il)
    # Chiude il file            
    movl $6, %eax                       # SystemCall CLOSE
    movl %ebx, %ecx                     # File descriptor
    int $0x80                           # Interrupt del kernel

    incb product_n                      # incrementa il numero di prodotti che sono stati salvati per ignorare la presenza o no dello '\n' a fine file "Ordini.txt"

    call print_saved
    call print_product_n

    jmp substring_to_len


close_file_nil:                         # jump fatto da "next_substring" quindi NotInLoop (nil)
    # Chiude il file            
    movl $6, %eax                       # SystemCall CLOSE
    movl %ebx, %ecx                     # File descriptor
    int $0x80                           # Interrupt del kernel

    call print_saved
    call print_product_n

    jmp substring_to_len


substring_to_len:
    leal substring_s, %edx              # salva l'indirizzo dell'allocazione della prima stringa nella variabile EDX
    xorl %ecx, %ecx                     # pulisce ECX
    xorl %eax, %eax                     # pulisce EAX

substring_to_len_loop:
    # Substring to Substring_len
    cmpb $0, (%edx, %ecx)               # verifica se è stata raggiunta a fine della stringa
    je save_substring_len               
    incl %ecx                           # incrementa contatore lunghezza substring_s
    jmp substring_to_len_loop

save_substring_len:
    movb %cl, 12(%edx)                  # salva il valore nel corrispettivo substring_len
    xorl %ecx, %ecx                     # pulisce ECX
    incb %al                            # incrementa il contatore prodotti

    cmpb %al, product_n                 # verifica se sono stati elaborati tutti i prodotti
    je SStoDATA
    addl $17, %edx                      # incrementa il puntatore alla prossima substring_s
    jne substring_to_len_loop


SStoDATA:
    call print_saved
    # Substring to ID, DU, DL, PR
    xorl %eax, %eax
    xorl %ebx, %ebx                     # puntatore alla base della stringa
    xorl %ecx, %ecx                     # storage temporaneo del carattere da elaborare
    xorl %edx, %edx                     # offset al puntatore

    leal substring_s, %ebx              # carica l'indirizzo base di "substring_s" in EBX

SStoDATA_loop:
    cmpb $',', (%edx, %ebx)             # verifica se il carattere letto sia una virgola
    jne SStoDATA_loop_nc

    incb substring_s_comma_c            # incrementa il contatore delle virgole
    incl %edx                           # incrementa il puntatore per puntare al prossimo caratter

    jmp SStoDATA_loop


SStoDATA_loop_nc:
    cmpb $3, substring_s_comma_c        # verifica se il valore letto è la PR in base a quante virgole ha trovato
    je SStoDATA_loop_pr

    cmpb $',', 1(%edx, %ebx)            # verifico se il valore successivo è una virgola
    jne SStoDATA_loop_nc1

    movb (%edx, %ebx), %cl              # salva in CL il valore puntato dall'indirizzo EDX con offset EBX
    subb $'0', %cl                      # converte da ASCII a DECIMALE
    
    incl %edx                           # incrementa il puntatore per puntare alla prossima virgola
    
    cmpb $1, substring_s_comma_c
    jl SStoDATA_id
    je SStoDATA_du
    jg SStoDATA_dl

SStoDATA_loop_nc1:
    cmpb $',', 2(%edx, %ebx)            # verifico se il secondo valore successivo è una virgola
    jne SStoDATA_loop_nc2

    movb $10, %al                       # carica il moltiplicatore in AL
    movb (%edx, %ebx), %cl              # carica il valore da convertire in CL
    subb $'0', %cl                      # converte da ASCII a DECIMALE
    mulb %cl                            # moltiplica per 10 il valore convertito (salvato in AL)

    movb 1(%edx, %ebx), %cl             # carica il valore del digit meno significativo in CL
    subb $'0', %cl                      # converte da ASCII a DECIMALE
    addb %al, %cl                       # somma i due valori per ottenere il valore convertito

    addl $2, %edx                       # incrementa il puntatore per puntare alla prossima virgola

    cmpb $1, substring_s_comma_c
    jl SStoDATA_id
    je SStoDATA_du
    jg SStoDATA_dl

SStoDATA_loop_nc2:
    movb $100, %al                      # carica il moltiplicatore in AL
    movb (%edx, %ebx), %cl              # carica il valore da convertire in CL
    subb $'0', %cl                      # converte da ASCII a DECIMALE
    mulb %cl                            # moltiplica per 100 il valore convertito (salvato in AL)

    movb 2(%edx, %ebx), %cl             # carica il valore del digit meno significativo in CL
    subb $'0', %cl                      # converte da ASCII a DECIMALE
    addb %al, %cl                       # somma i due valori

    movb %cl, SStoDATA_loop_nc2_mul

    movb $10, %al                       # carica il moltiplicatore in AL
    movb 1(%edx, %ebx), %cl             # carica il valore da convertire in CL
    subb $'0', %cl                      # converte da ASCII a DECIMALE
    mulb %cl                            # moltiplica per 10 il valore convertito (salvato in AL)

    addb SStoDATA_loop_nc2_mul, %cl

    addl $3, %edx                       # incrementa il puntatore per puntare alla prossima virgola

    cmpb $1, substring_s_comma_c
    jl SStoDATA_id
    je SStoDATA_du
    jg SStoDATA_dl


SStoDATA_id:
    movb %cl, 13(%ebx)                  # salva il valore in ID della struttura
    jmp SStoDATA_loop
    
SStoDATA_du:
    movb %cl, 14(%ebx)                  # salva il valore in DU della struttura
    jmp SStoDATA_loop
    
SStoDATA_dl:
    movb %cl, 15(%ebx)                  # salva il valore in DL della struttura
    jmp SStoDATA_loop


SStoDATA_loop_pr:
    movb (%edx, %ebx), %cl              # salva in CL il valore puntato dall'indirizzo EDX con offset EBX
    subb $'0', %cl                      # converte da ASCII a DECIMALE
    movb %cl, 16(%ebx)                  # salva il valore in PR della struttura

    xorl %edx, %edx                     # azzera l'offset
    movb $0, substring_s_comma_c        # azzera il contatore di virgole

    addl $17, %ebx                      # punta alla prossima stringa
    incb substring_s_product_c          # incrementa il contatore di prodotti elaborati

    xorl %eax, %eax
    xorl %ecx, %ecx

    movb product_n, %al
    movb substring_s_product_c, %cl

    cmpl %ecx, %eax
    jne SStoDATA_loop

    jmp av_calc

av_calc:
    # Calcola il valore di av_offset e av_addr
    xorl %eax, %eax                     # pulisce EAX
    xorl %ebx, %ebx                     # pulisce EBX
    xorl %ecx, %ecx                     # pulisce ECX

    movb $17, %al                       # dimensione struttura dati da moltiplicare per il numero di prodotti
    movb product_n, %cl                 # carica il numero di prodotti in CL
    mulb %cl                            # salva il AX il valore di "product_n * 17"
    movl %eax, av_offset                # salva il valore ottenuto in "av_offset"
    addl $substring_s, %eax             # somma l'offset all'indirizzo della prima stringa per ottenere l'indirizzo della base del vettore d'indirizzi
    movl %eax, av_addr                  # salva il valore ottenuto in "av_addr"

    jmp save_unsorted_addr


save_unsorted_addr:
    # Salva gli indirizzi relativi alla base di ogni stringa nel vettore d'indirizzi nell'ordine che avevano nel file
    xorl %ecx, %ecx                     # pulisce ECX
    leal substring_s, %eax              # carica l'indirizzo della base della stringa in EAX
    movl av_addr, %ebx                  # carica l'indirizzo della base del vettore di indirizzi in EBX
    
save_unsorted_addr_loop:
    movl %eax, (%ebx)                   # salva l'indirizzo salvato in EAX nell'indirizzo puntato da EBX (vettore d'indirizzi)
    incb %cl                            # incrementa il contatore di indirizzi salvati
    
    cmpb %cl, product_n                 # verifica se sono stati salvati tutti gli indirizzi
    je ask_alg

    addl $17, %eax                      # punta alla base della prossima stringa
    addl $4, %ebx                       # punta al prossimo slot nel vettore d'indirizzi
    jmp save_unsorted_addr_loop


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
    call print_selected_alg

    xorl %ecx, %ecx                     # pulisce ECX
    xorl %edx, %edx                     # pulisce EDX
    movl av_addr, %eax                  # carica l'indirizzo della base del vettore d'indirizzi
    decb product_n                      # decrementa temporaneamente il numero di prodotti a fine dell'allgoritmo di ordinamento

EDF_loop:
    movl (%eax), %ebx                   # salva in EBX l'indirizzo del prodotto salvato nel vettore d'indirizzi puntato da EAX
    movb 15(%ebx), %dl                  # salva in DL il valore di Deadline del prodotto puntato da EBX

    movl 4(%eax), %ebx                  # salva in EBX l'indirizzo del prodotto successivo salvato nel vettore d'indirizzi puntato da EAX
    movb 15(%ebx), %dh                  # salva in DH il valore di Deadline del prodotto puntato da EBX

    cmpb %dl, %dh                       # verifica il valore attuale col successivo
    jg EDF_loop_swap
    je EDF_loop_pr
    jmp EDF_loop_ns

EDF_loop_pr:
    movl (%eax), %ebx                   # salva in EBX l'indirizzo del prodotto salvato nel vettore d'indirizzi puntato da EAX
    movb 16(%ebx), %dl                  # salva in DL il valore di Priority del prodotto puntato da EBX

    movl 4(%eax), %ebx                  # salva in EBX l'indirizzo del prodotto successivo salvato nel vettore d'indirizzi puntato da EAX
    movb 16(%ebx), %dh                  # salva in DH il valore di Priority del prodotto puntato da EBX
    
    cmpb %dl, %dh                       # verifica il valore attuale col successivo
    jge EDF_loop_ns
    jmp EDF_loop_swap

EDF_loop_swap:
    # SWAP
    movl 4(%eax), %edx                  # salvo in EDX l'indirizzo al prodotto successivo
    movl %edx, substring_tmp_addr       # salvo il valore di EDX in "substring_tmp_addr"

    movl (%eax), %edx                   # salvo in EDX l'indirizzo dell'attuale prodotto nel vettore indirizzi
    movl %edx, 4(%eax)                  # salvo nello slot indirizzo successivo l'attuale indirizzo

    movl substring_tmp_addr, %edx       # salvo in EDX "substring_tmp_addr"
    movl %edx, (%eax)                   # salvo nello slot indirizzo attuale "substring_tmp_addr"

    jmp EDF_loop_ns

EDF_loop_ns:                            # no swap + inc
    # Update slot temporali 
    xorl %edx, %edx                     # pulisce EDX
    movl (%eax), %ebx                   # salva in EBX l'indirizzo del prodotto salvato nel vettore d'indirizzi puntato da EAX
    movb 14(%ebx), %dl                  # salva in DL il valore di Priority del prodotto puntato da EBX
    addl %edx, time                     # somma la durata del prodotto attuale a "time" 

    # Incremento per il prossimo ciclo
    incb %cl                            # incrementa il contatore d'ordinamento
    cmpb %cl, product_n                 # verifica se ha finito l'ordinamento
    je print_res

    addl $4, %eax                       # punta al prossimo indirizzo nel vettore indirizzi
    jmp EDF_loop


HPF:
    call print_selected_alg

    xorl %ecx, %ecx                     # pulisce ECX
    xorl %edx, %edx                     # pulisce EDX
    movl av_addr, %eax                  # carica l'indirizzo della base del vettore d'indirizzi
    decb product_n                      # decrementa temporaneamente il numero di prodotti a fine dell'allgoritmo di ordinamento

HPF_loop:
    movl (%eax), %ebx                   # salva in EBX l'indirizzo del prodotto salvato nel vettore d'indirizzi puntato da EAX
    movb 16(%ebx), %dl                  # salva in DL il valore di Priority del prodotto puntato da EBX

    movl 4(%eax), %ebx                  # salva in EBX l'indirizzo del prodotto successivo salvato nel vettore d'indirizzi puntato da EAX
    movb 16(%ebx), %dh                  # salva in DH il valore di Priority del prodotto puntato da EBX

    cmpb %dl, %dh                       # verifica il valore attuale col successivo
    jg HPF_loop_ns
    je HPF_loop_dl
    jmp HPF_loop_swap

HPF_loop_dl:
    movl (%eax), %ebx                   # salva in EBX l'indirizzo del prodotto salvato nel vettore d'indirizzi puntato da EAX
    movb 15(%ebx), %dl                  # salva in DL il valore di Deadline del prodotto puntato da EBX

    movl 4(%eax), %ebx                  # salva in EBX l'indirizzo del prodotto successivo salvato nel vettore d'indirizzi puntato da EAX
    movb 15(%ebx), %dh                  # salva in DH il valore di Deadline del prodotto puntato da EBX
    
    cmpb %dl, %dh                       # verifica il valore attuale col successivo
    jl HPF_loop_swap
    jmp HPF_loop_ns

HPF_loop_swap:
    # SWAP
    movl 4(%eax), %edx                  # salvo in EDX l'indirizzo al prodotto successivo
    movl %edx, substring_tmp_addr       # salvo il valore di EDX in "substring_tmp_addr"

    movl (%eax), %edx                   # salvo in EDX l'indirizzo dell'attuale prodotto nel vettore indirizzi
    movl %edx, 4(%eax)                  # salvo nello slot indirizzo successivo l'attuale indirizzo

    movl substring_tmp_addr, %edx       # salvo in EDX "substring_tmp_addr"
    movl %edx, (%eax)                   # salvo nello slot indirizzo attuale "substring_tmp_addr"

    jmp HPF_loop_ns

HPF_loop_ns:                            # no swap + inc
    # Update slot temporali 
    xorl %edx, %edx                     # pulisce EDX
    movl (%eax), %ebx                   # salva in EBX l'indirizzo del prodotto salvato nel vettore d'indirizzi puntato da EAX
    movb 14(%ebx), %dl                  # salva in DL il valore di Priority del prodotto puntato da EBX
    addl %edx, time                     # somma la durata del prodotto attuale a "time" 

    # Incremento per il prossimo ciclo
    incb %cl                            # incrementa il contatore d'ordinamento
    cmpb %cl, product_n                 # verifica se ha finito l'ordinamento
    je print_res

    addl $4, %eax                       # punta al prossimo indirizzo nel vettore indirizzi
    jmp HPF_loop



print_res:
    incb product_n                      # incrementa il numero di prodotti decrementato in precedenza a fine dell'allgoritmo di ordinamento
    movl av_addr, %eax                  # carica l'indirizzo della base del vettore d'indirizzi in EAX
    movl %eax, substring_print_addr     # carica EAX in "substring_print_addr" 

print_res_loop:
    movl substring_print_addr, %eax
    movl (%eax), %ecx
    movl 12(%ecx), %edx

    movl $4, %eax
    movl $1, %ebx
    int $0x80
    
    movl $4, %eax
    movl $1, %ebx
    movl $newline, %ecx
    movl $1, %edx
    int $0x80
    
    addl $4, substring_print_addr
    incb printed_products               # incrementa il contatore di prodotti stampati
    movb printed_products, %cl          # carica il numero di prootti stampati in CL
    
    cmpb %cl, product_n                 # verifica se sono stati stampati tutti i prodotti
    jne print_res_loop

    movl $4, %eax
    movl $1, %ebx
    movl $newline, %ecx
    movl $1, %edx
    int $0x80

    # pulisce tutto
    xorl %eax, %eax
    xorl %ebx, %ebx
    xorl %ecx, %ecx
    xorl %edx, %edx
    movb $0, product_n
    movb $0, substring_s_comma_c
    movb $0, substring_s_product_c
    movb $0, SStoDATA_loop_nc2_mul
    movl $0, av_offset
    movl $0, av_addr
    movl $0, time
    movl $0, penality
    movb $0, printed_products
    movl $0, substring_print_addr
    movb $0, output_mode
    movb $0, alg

    movb $0, alg                        # azzera il valore di algoritmo scelto


    movl $3, %eax
    movl $0, %ebx
    leal alg, %ecx
    movl $1, %edx
    int $0x80


    je ask_alg









invalid_args_num:
    # Stampa il messaggio "Errore: Numero di argomenti inseriti non valido"
    movl $4, %eax
    movl $1, %ebx
    leal invalid_args_num_msg, %ecx
    movl invalid_args_num_msg_len, %edx
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


.type print_saved, @function
print_saved:
    movl $4, %eax
    movl $1, %ebx
    movl $newline, %ecx
    movl $1, %edx
    int $0x80

    movl $4, %eax
    movl $1, %ebx
    movl $substring_s, %ecx
    movl $20480, %edx       # 1024 * 17 = 20480
    int $0x80

    movl $4, %eax
    movl $1, %ebx
    movl $newline, %ecx
    movl $1, %edx
    int $0x80

    movl $4, %eax
    movl $1, %ebx
    movl $newline, %ecx
    movl $1, %edx
    int $0x80

    ret


.type print_product_n, @function
print_product_n:
    movl $4, %eax
    movl $1, %ebx
    leal print_product_n_msg, %ecx
    movl print_product_n_msg_len, %edx
    int $0x80

    movl $4, %eax
    movl $1, %ebx
    movl $product_n, %ecx
    addl $48, product_n
    movl $1, %edx
    int $0x80
    subl $48, product_n

    movl $4, %eax
    movl $1, %ebx
    movl $newline, %ecx
    movl $1, %edx
    int $0x80

    ret

    
.type print_selected_alg, @function
print_selected_alg:
    cmpb $'1', %al
    je selected_edf
    cmpb $'2', %al
    je selected_hpf

selected_edf:
    movl $4, %eax
    movl $1, %ebx
    leal selected_edf_msg, %ecx
    movl selected_edf_msg_len, %edx
    int $0x80
    ret

selected_hpf:
    movl $4, %eax
    movl $1, %ebx
    leal selected_hpf_msg, %ecx
    movl selected_hpf_msg_len, %edx
    int $0x80
    ret
