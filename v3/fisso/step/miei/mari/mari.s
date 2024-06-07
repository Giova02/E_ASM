
# ############### SEZIONE DATA ################

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
    substring_s_addr:
        .int 0
    SUBtoDAT_nc3_mul:
        .byte 0

# ASK ALG
    ask_alg_msg:
        .ascii "(?): Quale algoritmo di pianificazione dovrà usare il programma?\n\t1) Earliest Deadline First (EDF)\n\t2) Highest Priority First (HPF)\n\nPremi CTRL + C per uscire\n\n> "
    ask_alg_msg_len:
        .long . - ask_alg_msg
    invalid_alg_error_msg:
        .ascii "(!) Errore: Inserimento scelta algoritmo invalido\n"
    invalid_alg_error_msg_len:
        .long . - invalid_alg_error_msg

# Print
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


    movl $buffer, %eax   # sposto il puntatore del buffer in %eax

    movl $substring_s, %edx  # sposto il puntatore della stringa1 in %edx

    xorl %ebx, %ebx     # azzero ebx


lettura_stringa:

    movb (%eax), %cl   # sposto in %cl il registro %eax sommato al suo offset, inizializzato a zero
    cmpb $0, %cl    # altrimenti va avanti e confronta se %cl è NULL, quindi se il file è terminato
    #   !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    je close_file_il     # jumpa al continuo, all'algoritmo, momentaneamente lho messo in exit. 

    cmpb newline, %cl   # confronto %cl con \n per vedere se è lo stesso carattere
    je next_string      # jumpa alla etichetta successiva

    
    movb %cl, (%edx, %ebx)

    incl %ebx
    incl %eax   # incremento il registro che contiene l'indirizzo del char a cui sono arrivata
    jmp lettura_stringa     # ritorno all'inizio dell'etichetta

next_string:

    incl %eax       # incremento %eax perchè non è stato incrementato nell'etichetta sopra
    xorl %ebx, %ebx     # azzero %ebx per poterlo incrementare di nuovo

    cmpb $0, (%eax)
    je close_file_nil

    addl $11, %edx      # sommo 11 a edx per passare alla riga successiva
    jmp lettura_stringa     # ritorno all'etichetta sopra





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
    movl %ecx, 11(%edx)                 # salva il valore nel corrispettivo substring_len
    xorl %ecx, %ecx                     # pulisce ECX
    incb %al                            # incrementa il contatore prodotti

    cmpb %al, product_n                 # verifica se sono stati elaborati tutti i prodotti
    je SStoDAT
    addl $19, %edx                      # incrementa il puntatore alla prossima substring_s
    jne substring_to_len_loop


SStoDAT:
    call print_saved
    # Substring to ID, DU, DL, PR
    movl $substring_s, substring_s_addr # salva l'indirizzo dell'allocazione della prima stringa nella variabile EDX
    xorl %eax, %eax                     # pulisce EAX
    xorl %ebx, %ebx                     # pulisce EBX
    xorl %edx, %edx                     # pulisce EDX

SUBtoDAT_loop:
    cmpb $',', substring_s_addr(%ebx)   # verifica che dato stiamo convertendo
    jne SUBtoDAT_nc
    
    cmpl $3, %edx                       # verifica se è stata trovata l'ultima virgola
    je SUBtoDAT_pr                      # se è stata trovata l'ulltima virgola salva PR
    
    incl %edx                           # incrementa il contatore di virgole trovate
    incl %ebx                           # punta al prossimo carattere da verificare
    
    jmp SUBtoDAT_loop


SUBtoDAT_nc:
    # check ID, DU, DL
    incl substring_s_addr
    cmpb $',', substring_s_addr(%ebx)  # se ID è formato da 1 cifra
    je SUBtoDAT_nc1

    incl substring_s_addr
    cmpb $',', substring_s_addr(%ebx)   # se ID è formato da 2 cifra
    je SUBtoDAT_nc2
    jmp SUBtoDAT_nc3                    # se ID è formato da 3 cifra

SUBtoDAT_nc1:
    decl substring_s_addr
    movb substring_s_addr(%ebx), %cl    # copia il valore da salvare in CL
    subb $'0', %cl                      # converte il valore in CL da ascii a dec

    addl $15, substring_s_addr
    movb %cl, substring_s_addr(%edx)    # salva il valore nell'allocazione corrispettiva
    subl $15, substring_s_addr
    incl %ebx                           # incrementa di 1 l'offset per puntare al prossimo carattere non elaborato

    jmp SUBtoDAT_loop

SUBtoDAT_nc2:
    subl $2, substring_s_addr
    
    xorl %eax, %eax                     # pulisce EAX
    movb $10, %al                       # salva il moltiplicatore in AL
    movb substring_s_addr(%ebx), %cl    # copia il valore da salvare in CL
    mulb %cl

    incl substring_s_addr               # punta al prossimo carattere
    addb substring_s_addr(%ebx), %al    # somma il valore successivo col risultato della moltiplicazione
    decl substring_s_addr               # sistema il puntatore per tornare a puntare il carattere attuale
    
    addl $15, substring_s_addr
    movb %cl, substring_s_addr(%edx)    # salva il valore nell'allocazione corrispettiva
    subl $15, substring_s_addr
    
    addl $2, %ebx                       # incrementa di 2 l'offset per puntare al prossimo carattere non elaborato

    jmp SUBtoDAT_loop

SUBtoDAT_nc3:
    subl $2, substring_s_addr

    xorl %eax, %eax                     # pulisce EAX
    movb $10, %al                       # salva il moltiplicatore in AL
    incl substring_s_addr               # punta al prossimo carattere
    movb substring_s_addr(%ebx), %cl    # copia il valore da salvare in CL
    mulb %cl

    incl substring_s_addr               # punta al prossimo carattere
    addb substring_s_addr(%ebx), %al    # somma il valore successivo col risultato della moltiplicazione
    subl $2, substring_s_addr           # sistema il puntatore per tornare a puntare il carattere attuale
    
    movb %al, SUBtoDAT_nc3_mul

    xorl %eax, %eax                     # pulisce EAX
    movb $100, %al                      # salva il moltiplicatore in AL
    movb substring_s_addr(%ebx), %cl    # copia il valore da salvare in CL
    mulb %cl

    addb SUBtoDAT_nc3_mul, %al          # somma i risultati
    
    addl $15, substring_s_addr
    movb %cl, substring_s_addr(%edx)    # salva il valore nell'allocazione corrispettiva
    subl $15, substring_s_addr

    addl $3, %ebx                       # incrementa di 3 l'offset per puntare al prossimo carattere non elaborato

    jmp SUBtoDAT_loop


SUBtoDAT_pr:
    movb substring_s_addr(%ebx), %cl    # copia il valore da salvare in CL
    subb $'0', %cl                      # converte il valore in CL da ascii a dec

    addl $15, substring_s_addr
    movb %cl, substring_s_addr(%edx)    # salva il valore nell'allocazione corrispettiva
    subl $15, substring_s_addr

    incl %ebx                           # incrementa di 1 l'offset per puntare al prossimo carattere non elaborato

    jmp SUBtoDAT_loop


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
    jmp exit


HPF:
    call print_selected_alg
    jmp exit













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
    movl $19456, %edx       # 1024 * 19 = 19456
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
