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
    output_mode:                        # 1 = Terminal only   |   2 = Terminal + File
        .byte 0

# FILE LETTURA
    product_n:
        .byte 0
    filename_input:
        .int 0
    fd_input:
        .int 0
    filename_output:
        .int 0
    fd_output:
        .int 0
    file_open_error_msg:
        .ascii "(!) Errore: Impossibile aprire il file\n"
    file_open_error_msg_len:
        .long . - file_open_error_msg

# BUFFERtoDATA  
    buffer_data_addr:
      .int 0

# ASK ALG
    alg:
        .byte 0
    ask_alg_msg:
        .ascii "(?): Quale algoritmo di pianificazione dovrà usare il programma?\n\t1) Earliest Deadline First (EDF)\n\t2) Highest Priority First (HPF)\n\nPremi CTRL + C per uscire\n\n> "
    ask_alg_msg_len:
        .long . - ask_alg_msg
    invalid_alg_error_msg:
        .ascii "(!) Errore: Inserimento scelta algoritmo invalido\n"
    invalid_alg_error_msg_len:
        .long . - invalid_alg_error_msg

# EDF & HPF
    edf_print_msg:
        .ascii "Pianificazione EDF:\n"
    edf_print_msg_len:
        .long . - edf_print_msg
    hpf_print_msg:
        .ascii "Pianificazione HPF:\n"
    hpf_print_msg_len:
        .long . - hpf_print_msg
    alg_end_print_msg:
        .ascii "Conclusione: "
    alg_end_print_msg_len:
        .long . - alg_end_print_msg
    penalty_print_msg:
        .ascii "Penalty: "
    penalty_print_msg_len:
        .long . - penalty_print_msg
    time:
        .int 0
    penalty:
        .int 0
    swap_c:
        .byte 0

# ITOA
    itoa_digit:
        .byte 1
    itoa_digit_tmp:
        .byte 1

# PRINT RES
    res_string_addr_tmp:
        .int 0
    res_string_addr:
        .int 0
    res_string_len:
        .int 0
    newline:
        .ascii "\n"

# ############### SEZIONE BSS ################

.section .bss

# FILE LETTURA
    buffer: 
        .zero 1024                      # spazio per il buffer di input

# ITOA
    buffer_itoa:
        .zero 3                         # spazio per 3 caratteri da convertiti
    buffer_itoa_addr:
        .zero 4                         # indirizzo del buffer_itoa
    buffer_itoa_inv:
        .zero 1                         # byte temporeaneo per scambiare il primo carattere con l'ultimo

# EDF & HPF
    buffer_tmp:
        .zero 4
    buffer_data:
        .zero 1


# ############### SEZIONE TEXT ###############

.section .text
    .globl _start

_start:

    # Legge il numero di argomenti passati
    popl %ecx
    subl $1, %ecx                       # decrementa per ottenere il numero di argomenti

    # Verifica il numero di argomenti
    cmpl $1, %ecx
    jl invalid_args_num
    je args_1

    cmpl $2, %ecx
    je args_2

    jmp invalid_args_num


args_1:
    popl %ecx
    popl filename_input

    # Stampa il messaggio "(MSG) Output mode: Terminal only"
    movl $4, %eax
    movl $1, %ebx
    leal args_1_msg, %ecx
    movl args_1_msg_len, %edx
    int $0x80

    movb $1, output_mode

    jmp open_file

args_2:
    popl %ecx
    popl filename_input
    popl filename_output

    # Stampa il messaggio "(MSG) Output mode: Terminal + File"
    movl $4, %eax
    movl $1, %ebx
    leal args_2_msg, %ecx
    movl args_2_msg_len, %edx
    int $0x80

    movb $2, output_mode

    jmp open_file


open_file:
    # Apre il file 
    movl $5, %eax                       # SystemCall OPEN
    movl filename_input, %ebx           # Nome del file di input
    movl $0, %ecx                       # Modalità di apertura (Read-Only)
    int $0x80                           # Interrupt del kernel

    cmpl $0, %eax                       # Se c'è un errore, esce
    jl file_open_error          

    movl %eax, fd_input                 # Salva il file descriptor in EBX


read_file:
    # Legge e salva il contenuto del file in "buffer" 
    movl $3, %eax                       # SystemCall READ
    movl fd_input, %ebx                       # File descriptor
    leal buffer, %ecx                   # buffer di input
    movl $1024, %edx                    # Lunghezza buffer
    int $0x80                           # Interrupt del kernel

    jmp close_file


close_file:
    # Chiude il file            
    movl $6, %eax                       # SystemCall CLOSE
    movl %ebx, %ecx                     # File descriptor
    int $0x80                           # Interrupt del kernel

    jmp BUFFERtoDATA


BUFFERtoDATA:
    movl $buffer_data, buffer_data_addr
    leal buffer, %ecx

BUFFERtoDATA_loop:
    xorl %ebx, %ebx
    movb (%ecx), %bl

    cmpb $',', %bl                      # vedo se e' stato letto il carattere ','
    je BUFFERtoDATA_comma           

    cmpb $10, %bl                       # vedo se e' stato letto il carattere '\n'
    je BUFFERtoDATA_nl          

    cmpb $0, %bl                        # vedo se e' stato letto il carattere '\0'
    je BUFFERtoDATA_end         

    subb $48, %bl                       # converte il codice ASCII della cifra nel numero corrisponente
    movl $10, %edx
    mulb %dl
    addb %bl, %al

    inc %ecx
    jmp BUFFERtoDATA_loop

BUFFERtoDATA_comma:
    movl buffer_data_addr, %ebx
    movb %al, (%ebx)
    incl buffer_data_addr
    jmp BUFFERtoDATA_inc

BUFFERtoDATA_nl:
    movl buffer_data_addr, %ebx
    movb %al, (%ebx)
    incl buffer_data_addr
    incb product_n
    jmp BUFFERtoDATA_inc

BUFFERtoDATA_inc:
    xorl %eax, %eax
    inc %ecx
    jmp BUFFERtoDATA_loop

BUFFERtoDATA_end:
    movl buffer_data_addr, %ebx
    movb %al, (%ebx)

    movb -1(%ecx), %bl
    cmpb $10, %bl
    je ask_alg

    incb product_n

    jmp ask_alg


ask_alg:
    movl $4, %eax                       # stampa il prompt di richiesta della scelta algoritmo
    movl $1, %ebx
    leal ask_alg_msg, %ecx
    movl ask_alg_msg_len, %edx
    int $0x80
    
    movl $3, %eax                       # attende l'input di un valore da 1 byte ('1' o '2') 
    movl $0, %ebx
    leal alg, %ecx
    movl $2, %edx
    int $0x80

    movb alg, %al                       # verifica che valore è stato inserito
    cmpb $'1', %al
    je EDF_start
    cmpb $'2', %al
    je HPF_start
    jmp invalid_alg_error               # in caso di valore indesiderato lo comunica uscendo poi con codice di errore


EDF_start:
    movl $4, %eax
    movl $1, %ebx
    leal newline, %ecx
    movl $1, %edx
    int $0x80

    # stampa l'algoritmo selezionato
    movl $4, %eax
    movl $1, %ebx
    leal edf_print_msg, %ecx
    movl edf_print_msg_len, %edx
    int $0x80

EDF:

    xorl %ecx, %ecx                     # azzera il registro che verrà usato come contatore di prodotti elaborati
    movl $buffer_data, %eax             # carica l'indirizzo del buffer convertito in EAX
    decb product_n                      # decrementa temporaneamente il numero di prodotti a fine dell'algoritmo di ordinamento

EDF_loop:
    movb 2(%eax), %bl                   # salva in BL il valore Deadline del primo prodotto
    movb 6(%eax), %bh                   # salva in BL il valore Deadline del secondo prodotto

    cmpb %bl, %bh                       # verifica il valore attuale col successivo
    jl EDF_loop_swap
    je EDF_loop_pr
    jmp EDF_loop_ns

EDF_loop_pr:
    movb 3(%eax), %bl                   # salva in BL il valore Priority del primo prodotto
    movb 7(%eax), %bh                   # salva in BL il valore Priority del secondo prodotto

    cmpb %bl, %bh                       # verifica il valore attuale col successivo
    jl EDF_loop_ns
    jmp EDF_loop_swap

EDF_loop_swap:
    # SWAP
    movl (%eax), %edx                   # salvo in EDX il primo prodotto
    movl %edx, buffer_tmp               # salva in "buffer_tmp" il primo prodotto
    movl 4(%eax), %edx                  # salvo in EDX il secondo prodotto
    movl %edx, (%eax)                   # salvo EDX nel posto del primo prodotto
    movl buffer_tmp, %edx               # salvo in EDX "buffer_tmp"
    movl %edx, 4(%eax)                  # salvo EDX nel posto del secondo prodotto

    incb swap_c                         # incrementa il contatore di swap

    jmp EDF_loop_ns

EDF_loop_ns:                            # no swap + inc
    # Incremento per il prossimo ciclo
    incb %cl                            # incrementa il contatore d'ordinamento
    cmpb %cl, product_n                 # verifica se ha finito il ciclo
    je EDF_swap_check

    addl $4, %eax                       # punta al prossimo prodotto
    jmp EDF_loop

EDF_swap_check:
    cmpb $0, swap_c                     # verifica se è completamente ordinato
    je calc_penalty
    incb product_n                      # incrementa il numero di prodotti decrementato in precedenza a fine dell'algoritmo di ordinamento
    movb $0, swap_c                     # azzera il contatore di swap in vista al prossimo loop
    jmp EDF


HPF_start:
    movl $4, %eax
    movl $1, %ebx
    leal newline, %ecx
    movl $1, %edx
    int $0x80


    # stampa l'algoritmo selezionato
    movl $4, %eax
    movl $1, %ebx
    leal hpf_print_msg, %ecx
    movl hpf_print_msg_len, %edx
    int $0x80

HPF:

    xorl %ecx, %ecx                     # azzera il registro che verrà usato come contatore di prodotti elaborati
    movl $buffer_data, %eax             # carica l'indirizzo del buffer convertito in EAX
    decb product_n                      # decrementa temporaneamente il numero di prodotti a fine dell'algoritmo di ordinamento

HPF_loop:
    movb 3(%eax), %bl                   # salva in BL il valore Priority del primo prodotto
    movb 7(%eax), %bh                   # salva in BL il valore Priority del secondo prodotto

    cmpb %bl, %bh                       # verifica il valore attuale col successivo
    jg HPF_loop_swap
    je HPF_loop_dl
    jmp HPF_loop_ns

HPF_loop_dl:
    movb 2(%eax), %bl                   # salva in BL il valore Deadline del primo prodotto
    movb 6(%eax), %bh                   # salva in BL il valore Deadline del secondo prodotto

    cmpb %bl, %bh                       # verifica il valore attuale col successivo
    jg HPF_loop_ns
    jmp HPF_loop_swap

HPF_loop_swap:
    # SWAP
    movl (%eax), %edx                   # salvo in EDX il primo prodotto
    movl %edx, buffer_tmp               # salva in "buffer_tmp" il primo prodotto
    movl 4(%eax), %edx                  # salvo in EDX il secondo prodotto
    movl %edx, (%eax)                   # salvo EDX nel posto del primo prodotto
    movl buffer_tmp, %edx               # salvo in EDX "buffer_tmp"
    movl %edx, 4(%eax)                  # salvo EDX nel posto del secondo prodotto

    incb swap_c                         # incrementa il contatore di swap
    jmp HPF_loop_ns

HPF_loop_ns:                            # no swap + inc
    # Incremento per il prossimo ciclo
    incb %cl                            # incrementa il contatore d'ordinamento
    cmpb %cl, product_n                 # verifica se ha finito il ciclo
    je HPF_swap_check

    addl $4, %eax                       # punta al prossimo prodotto
    jmp HPF_loop

HPF_swap_check:
    cmpb $0, swap_c                     # verifica se è completamente ordinato
    je calc_penalty
    incb product_n                      # incrementa il numero di prodotti decrementato in precedenza a fine dell'algoritmo di ordinamento
    movb $0, swap_c                     # azzera il contatore di swap in vista al prossimo loop
    jmp HPF


calc_penalty:
    xorl %ecx, %ecx                     # azzera il contatore di prodotti elaborati
    incb product_n                      # incrementa il numero di prodotti decrementato in precedenza a fine dell'algoritmo di ordinamento
    movl $buffer_data, %edx             # carica l'indirizzo del "buffer_data" EDX

calc_penalty_loop:
    xorl %ebx, %ebx                     # azzera EBX
    movb 1(%edx), %bl                   # carica il valore di Duration in EBX
    addl %ebx, time                     # aggiorna il contatore di slot temporali

    movl time, %ebx                     # carica in EBX il valore aggiornato del contatore di slot temporali
    cmpb 2(%edx), %bl                   # confronta il contatore di slot temporali con la Deadline del prodotto
    jl calc_penalty_np

    xorl %eax, %eax                     # azzera EAX
    subb 2(%edx), %bl                   # sottrae il valore di Deadline al valore del contatore di slot temporali
    mulb 3(%edx)                        # moltiplica il valore di Priority per il risultato della sottrazione
    addl %eax, penalty                  # somma il valore ottenuto a "penalty"
    jmp calc_penalty_np

calc_penalty_np:
    addl $4, %edx                       # incrementa l'indirizzo al "buffer_data" per puntare al prossimo prodotto
    incb %cl                            # incrementa il contatore di prodotti verificati
    cmpb %cl, product_n                 # verifica quanti prodotti sono stati elaborati
    je calc_res_string_addr
    jmp calc_penalty_loop


calc_res_string_addr:
    movl $4, %eax                       # byte occupati per singolo prodotto
    mulb product_n                      # moltiplica il numero di prodotti per il numero di byte che ogni singolo prodotto occupa
    addl $buffer_data, %eax             # somma l'indirizzo del buffer convertito con l'offset calcolato
    
    movl %eax, res_string_addr_tmp      # salva in "res_string_addr_tmp" l'indirizzo nel quale salvare la stringa che conterrà la stampa da fare a terminale / terminale + file
    addl $1, res_string_addr_tmp
    movl %eax, res_string_addr          # salva in "res_string_addr" l'indirizzo base che punta alla stringa da stampare
    addl $1, res_string_addr

build_res_string:
    movl $0, time                       # azzera il contatore di slot temporali
    xorl %ecx, %ecx                     # azzera il contatore di prodotti utilizzati
    movl $buffer_data, buffer_data_addr # carica l'indirizzo del buffer convertito in "buffer_data_addr"

build_res_string_loop:
    movl buffer_data_addr, %edx         # carica l'indirizzo di "buffer_data" salvato in "buffer_data_addr", dentro ad EDX
    xorl %eax, %eax                     # pulisce EAX
    movb (%edx), %al                    # carica il AL il valore di ID
    movl $buffer_itoa, buffer_itoa_addr # reset dell'indirizzo dell buffer_itoa dopo l'elaborazione
    movl buffer_itoa_addr, %ebx         # carica in EBX l'indirizzo del "buffer_itoa"

    call itoa

    movb $':', (%edx)                   # simbolo d'intermezzo tra i due valori

    incl res_string_addr_tmp
    movl res_string_addr_tmp, %edx
    
    cmpl $0, time
    jne build_res_string_loop_nti       # Not Time Init (quando il valore temporale non è 0)

    movb $'0', (%edx)
    incl res_string_addr_tmp

    movl buffer_data_addr, %ebx         # carica l'indirizzo di "buffer_data" salvato in "buffer_data_addr", dentro ad EDX
    xorl %edx, %edx                     # pulisce EDX
    movb 1(%ebx), %dl                   # carica il BL il valore di Duration
    addl %edx, time                     # aggiorna il contatore di slot temporali

    movl buffer_itoa_addr, %ebx
    movl res_string_addr_tmp, %edx
    jmp build_res_string_loop_end

build_res_string_loop_nti:
    movl time, %eax                     # carica il valore del contatore di slot temporali in EAX
    movl $buffer_itoa, buffer_itoa_addr # reset dell'indirizzo dell buffer_itoa dopo l'elaborazione
    movl buffer_itoa_addr, %ebx         # carica in EBX l'indirizzo del "buffer_itoa"

    call itoa

    movl $buffer_itoa, buffer_itoa_addr # reset dell'indirizzo dell buffer_itoa dopo l'elaborazione
    movl buffer_data_addr, %ebx         # carica l'indirizzo di "buffer_data" salvato in "buffer_data_addr", dentro ad EBX
    xorl %edx, %edx                     # pulisce EDX
    movb 1(%ebx), %dl                   # carica il BL il valore di Duration
    addl %edx, time                     # aggiorna il contatore di slot temporali

    movl buffer_itoa_addr, %ebx
    movl res_string_addr_tmp, %edx

build_res_string_loop_end:
    movb $10, (%edx)                    # simbolo d'intermezzo tra i due valori

    incl res_string_addr_tmp
    movl res_string_addr_tmp, %edx

    addl $4, buffer_data_addr
    movl buffer_data_addr, %ebx         # carica l'indirizzo di "buffer_data" salvato in "buffer_data_addr", dentro ad EBX

    movb (%ebx), %al
    cmpb $0, %al
    jne build_res_string_loop
    jmp print_res


print_res:

    movl res_string_addr_tmp, %eax
    subl res_string_addr, %eax
    movl %eax, res_string_len

    movl $4, %eax
    movl $1, %ebx
    movl res_string_addr, %ecx
    movl res_string_len, %edx
    int $0x80
    
    movl $4, %eax
    movl $1, %ebx
    leal alg_end_print_msg, %ecx
    movl alg_end_print_msg_len, %edx
    int $0x80
    
    movl time, %eax
    movl $buffer_itoa, %ebx             # carica l'indirizzo di "buffer_itoa" in EBX

    # pulisce il buffer_itoa
    movb $0, (%ebx)
    movb $0, 1(%ebx)
    movb $0, 2(%ebx)

    call itoa

    movl $4, %eax
    movl $1, %ebx
    leal buffer_itoa, %ecx
    movl itoa_digit, %edx
    int $0x80

    movl $4, %eax
    movl $1, %ebx
    movl $newline, %ecx
    movl $1, %edx
    int $0x80

    movl $4, %eax
    movl $1, %ebx
    leal penalty_print_msg, %ecx
    movl penalty_print_msg_len, %edx
    int $0x80

    movl penalty, %eax
    movl $buffer_itoa, %ebx             # carica l'indirizzo di "buffer_itoa" in EBX

    # pulisce il buffer_itoa
    movb $0, (%ebx)
    movb $0, 1(%ebx)
    movb $0, 2(%ebx)

    call itoa

    movl $4, %eax
    movl $1, %ebx
    movl $buffer_itoa, %ecx
    movl $3, %edx
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

    cmpb $2, output_mode
    jne ask_alg


    movb alg, %al                       # verifica che valore è stato inserito
    cmpb $'1', %al
    je output_EDF_print
    jmp output_HPF_print

output_EDF_print:
    # stampa l'algoritmo selezionato EDF
    movl $4, %eax
    movl fd_output, %ebx
    leal edf_print_msg, %ecx
    movl edf_print_msg_len, %edx
    int $0x80

    jmp output_print

output_HPF_print:
    # stampa l'algoritmo selezionato HPF
    movl $4, %eax
    movl fd_output, %ebx
    leal hpf_print_msg, %ecx
    movl hpf_print_msg_len, %edx
    int $0x80

    jmp output_print

output_print:
    # Apre il file di output 
    movl $5, %eax                       # Chiamata di sistema open
    movl filename_output, %ebx          # Percorso del file
    movl $0101, %ecx                    # Modalità di apertura (O_CREAT | O_WRONLY)
    movl $0644, %edx                    # Permessi del file (0644) (Permesso di lettura e scrittura per il proprietario, solo lettura per il gruppo e per gli altri utenti)
    int $0x80                           # Interruzione software per invocare la chiamata di sistema

    cmpl $0, %eax
    jl file_open_error

    # Salva il file descriptor restituito
    movl %eax, fd_output                # File descriptor in "fd_output"


    movl res_string_addr_tmp, %eax
    subl res_string_addr, %eax
    movl %eax, res_string_len

    movl $4, %eax                       # Chiamata di sistema write
    movl fd_output, %ebx                # File descriptor
    movl res_string_addr, %ecx          # Buffer contenente il messaggio 1
    movl res_string_len, %edx           # Lunghezza del messaggio 1 
    int $0x80                           # Interruzione software per invocare la chiamata di sistema
    
    movl $4, %eax
    movl fd_output, %ebx
    leal alg_end_print_msg, %ecx
    movl alg_end_print_msg_len, %edx
    int $0x80
    
    movl time, %eax
    movl $buffer_itoa, %ebx             # carica l'indirizzo di "buffer_itoa" in EBX

    # pulisce il buffer_itoa
    movb $0, (%ebx)
    movb $0, 1(%ebx)
    movb $0, 2(%ebx)

    call itoa

    movl $4, %eax
    movl fd_output, %ebx
    leal buffer_itoa, %ecx
    movl $3, %edx
    int $0x80

    movl $4, %eax
    movl fd_output, %ebx
    movl $newline, %ecx
    movl $1, %edx
    int $0x80

    movl $4, %eax
    movl fd_output, %ebx
    leal penalty_print_msg, %ecx
    movl penalty_print_msg_len, %edx
    int $0x80

    movl penalty, %eax
    movl $buffer_itoa, %ebx             # carica l'indirizzo di "buffer_itoa" in EBX

    # pulisce il buffer_itoa
    movb $0, (%ebx)
    movb $0, 1(%ebx)
    movb $0, 2(%ebx)

    call itoa

    movl $4, %eax
    movl fd_output, %ebx
    movl $buffer_itoa, %ecx
    movl $3, %edx
    int $0x80

    movl $4, %eax
    movl fd_output, %ebx
    movl $newline, %ecx
    movl $1, %edx
    int $0x80

    movl $4, %eax
    movl fd_output, %ebx
    movl $newline, %ecx
    movl $1, %edx
    int $0x80

    # Chiude il file
    movl $6, %eax                       # Chiamata di sistema close
    movl fd_output, %ebx                # File descriptor
    int $0x80                           # Interruzione software per invocare la chiamata di sistema

    jmp ask_alg



# GESTIONE ERRORI, USCITE E FUNZIONI

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
    movl $1, %eax                       # SystemCall EXIT
    movl $1, %ebx                       # EXIT code 1 (Errore)
    int $0x80


exit:
    movb $0, alg

    movl $3, %eax
    movl $0, %ebx
    leal alg, %ecx
    movl $2, %edx
    int $0x80

    # Esci dal programma
    movl $1, %eax                       # SystemCall EXIT
    movl $0, %ebx                       # EXIT code 0 (Nessun errore)
    int $0x80


.type itoa, @function
itoa:
    movb $1, itoa_digit

itoa_loop_a:
    # Parametri: %eax = valore, %ebx = puntatore al buffer_itoa
    xorl %edx, %edx                     # pulisce EDX prima della divisione
    movl $10, %ecx                      # salva il divisore (10) in ECX
    divl %ecx                           # salva in EAX il risultato della divisione e il resto in EDX

    addb $'0', %dl                      # convertire resto in ASCII

    movb %dl, (%ebx)                    # scrive il carattere nel buffer_itoa
    incl %ebx                           # incrementa il puntatore al buffer_itoa

    cmpl $0, %eax                       # controllo se EAX è vuoto (funzione conclusa)
    je itoa_end         
    
    incb itoa_digit                     # incrementa il contatore di cifre
    jmp itoa_loop_a                     # Richiama ricorsivamente itoa_loop_a

itoa_end:
    cmpb $1, itoa_digit
    je itoa_end_no_inv

    leal buffer_itoa, %ebx
    movb (%ebx), %al
    movb %al, buffer_itoa_inv

    movb 2(%ebx), %al
    movb %al, (%ebx)
    
    movb buffer_itoa_inv, %al
    movb %al, 2(%ebx)
    
    cmpb $3, itoa_digit
    je itoa_end_no_inv

itoa_end_lshift:
    leal buffer_itoa, %ebx
    movb 1(%ebx), %al
    movb %al, (%ebx)
    movb 2(%ebx), %al
    movb %al, 1(%ebx)
    movb $0, 2(%ebx)

itoa_end_no_inv:    
    movl buffer_itoa_addr, %ebx         # carica l'indirizzo di "buffer_itoa" salvato in "buffer_itoa_addr", dentro ad EBX
    movl res_string_addr_tmp, %edx      # carica l'indirizzo dove verrà salvata la stringa da stampare, dentro ad EDX
    cmpl $0, res_string_len
    je itoa_loop_b
    ret

itoa_loop_b:
    movb (%ebx), %al
    movb %al, (%edx)

    incl buffer_itoa_addr
    incl res_string_addr_tmp

    movl buffer_itoa_addr, %ebx
    movl res_string_addr_tmp, %edx

    decb itoa_digit

    cmpb $0, itoa_digit
    jne itoa_loop_b

    ret
