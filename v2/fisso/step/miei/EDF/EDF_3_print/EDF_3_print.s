.section .data
    time:
        .byte 0
        
    product_n:
        .byte 10
    product_v:
        .int 0
    product_s:
        .int 0

    penality_val:
        .int 0

    saved_loop_couter:
        .byte 0

    errore_same_id_msg:
        .ascii "Errore: Stessi dati prodotto trovati più volte\n"
    errore_same_id_msg_len:
        .long . - errore_same_id_msg

    print_no_err_msg:
        .ascii "Algoritmo eseguito senza problemi\n"
    print_no_err_msg_len:
        .long . - print_no_err_msg

    print_penality_msg_1:
        .ascii "> Valore di penalità: "
    print_penality_msg_len_1:
        .long . - print_penality_msg_1
    print_penality_msg_2:
        .ascii " €\n"
    print_penality_msg_len_2:
        .long . - print_penality_msg_2
    

.section .bss
    av_distance:
        .zero 2
    av_base_addr:
        .zero 4
        
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


.section .text
    .globl _start

_start:

# ############################################################
# START DEBUG SECTION
# ############################################################

    # salvataggio prodotti

    leal substring_id, %eax

    # Prodotto 1
    movb $12, (%eax)
    movb $8, 1(%eax)
    movb $7, 2(%eax)
    movb $5, 3(%eax)

    addl $19, %eax

    # Prodotto 2
    movb $35, (%eax)
    movb $23, 1(%eax)
    movb $23, 2(%eax)
    movb $5, 3(%eax)

    addl $19, %eax

    # Prodotto 3
    movb $47, (%eax)
    movb $10, 1(%eax)
    movb $45, 2(%eax)
    movb $5, 3(%eax)

    addl $19, %eax

    # Prodotto 4
    movb $53, (%eax)
    movb $8, 1(%eax)
    movb $59, 2(%eax)
    movb $5, 3(%eax)

    addl $19, %eax

    # Prodotto 5
    movb $78, (%eax)
    movb $5, 1(%eax)
    movb $68, 2(%eax)
    movb $5, 3(%eax)

    addl $19, %eax

    # Prodotto 6
    movb $89, (%eax)
    movb $10, 1(%eax)
    movb $72, 2(%eax)
    movb $5, 3(%eax)

    addl $19, %eax

    # Prodotto 7
    movb $91, (%eax)
    movb $6, 1(%eax)
    movb $84, 2(%eax)
    movb $5, 3(%eax)

    addl $19, %eax

    # Prodotto 8
    movb $104, (%eax)
    movb $8, 1(%eax)
    movb $91, 2(%eax)
    movb $5, 3(%eax)

    addl $19, %eax

    # Prodotto 9
    movb $116, (%eax)
    movb $10, 1(%eax)
    movb $33, 2(%eax)
    movb $5, 3(%eax)

    addl $19, %eax

    # Prodotto 10
    movb $123, (%eax)
    movb $6, 1(%eax)
    movb $16, 2(%eax)
    movb $5, 3(%eax)

    # salvataggio prodotto tmp

    leal substring_id, %eax
    leal substring_id_tmp, %ebx
    movb (%eax), %cl
    movb %cl, (%ebx)

    movb 1(%eax), %cl
    movb %cl, 1(%ebx)

    movb 2(%eax), %cl
    movb %cl, 2(%ebx)

    movb 3(%eax), %cl
    movb %cl, 3(%ebx)

# ############################################################
# END DEBUG SECTION
# ############################################################

    # salva in TMP il primo valore da verificare
    leal substring_id, %eax
    leal substring_id_tmp, %ebx

    movb (%eax), %cl
    movb %cl, (%ebx)
    movb 1(%eax), %cl
    movb %cl, 1(%ebx)
    movb 2(%eax), %cl
    movb %cl, 2(%ebx)
    movb 3(%eax), %cl
    movb %cl, 3(%ebx)

    xorl %eax, %eax
    xorl %ebx, %ebx
    xorl %ecx, %ecx


    # calcola e salva indirizzo base Vettore Indirizzi
    leal product_n, %eax        # salva l'indirizzo del numero di prodotti in EAX 
    movb (%eax), %bl            # carica il valore del numero di prodotti in BL
    movb $19, %al               # carica 19 (dimensione in byte della struttura dati) in AL
    mulb %bl                    # moltiplica BL per la dimensione di ogni struttura dati in modo a ottenere il corretto offset
    
    leal av_distance, %ebx      # salva l'indirizzo della variabile di offset ottenuto in EBX 
    sall $16, %eax              # azzera i 16 bit più significativi di EAX per poter sommare il valore di AX (16 bit) con l'indirizzo da 32 bit di EDI
    sarl $16, %eax
    movl %eax, (%ebx)           # salva il valore della variabile di offset ottenuto in EBX 
    
    leal substring_id, %esi     # salva l'indirizzo dell'ID del primo prodotto letto in ESI
    addl %esi, %eax             # somma l'offset trovato in precedenza con l'indirizzo salvato in ESI per trovare l'indirizzo del primo puntatore a prodotto salvato (base del vettore indirizzi)
    leal av_base_addr, %ebx     # salva l'indirizzo della base del vettore indirizzi nella variabile "av_base_addr"
    movl %eax, (%ebx)

    leal substring_id_tmp, %esi # salva l'indirizzo dell'ID di TMP in ESI
    leal substring_id, %edi     # salva l'indirizzo dell'ID del primo prodotto da verificare in EDI

test_s:
    # Verifica se l'indirizzo è già stato salvato
    leal product_s, %eax        # salva l'indirizzo del numero di prodotti salvati in EAX
    cmpb $0, (%eax)             # verifica se sono stati salvati dei prodotti
    jne test_tmp_v
    
    movb (%eax), %bl            # carica il numero di prodotti in BL
    sall $24, %ebx              # azzera i 24 bit più significativi di EBX 
    sarl $24, %ebx

    cmpl %edi, av_base_addr(%ebx)             # verifica se l'indirizzo del valore ad verificare salvato in EDI è già salvato nel vettore
    je test_v_num
    jne test_tmp_v


test_tmp_v:
    # Verifica DL di TMP con DL del prodotto da verificare PV
    leal substring_id_tmp, %esi # salva in ESI l'indirizzo dell'ID di TMP
    movb 2(%esi), %cl           # mette in CL il valore DL di TMP
    leal substring_id, %edi     # salva in ESI l'indirizzo dell'ID di PV
    cmpl $0, product_v
    je no_offset

    movl product_v, %ebx        # calcolo e salvo in EBX l'offset da applicare
    movb $19, %al
    mull %ebx
    addl %eax, %edi             # aggiunge l'offset all'indirizzo di PV

no_offset:
    movb 2(%edi), %ch           # mette in CH il valore DL di PV

    cmpb %cl, %ch               # compara i due valori di DL
    jl test_v_num
    jg v_tmp_cpy
    je test_pr


v_tmp_cpy:
    # Copia PV in TMP
    movb (%edi), %cl
    movb %cl, (%esi)
    movb 1(%edi), %cl
    movb %cl, 1(%esi)
    movb 2(%edi), %cl
    movb %cl, 2(%esi)
    movb 3(%edi), %cl
    movb %cl, 3(%esi)

    jmp test_v_num


test_v_num:
    # Controlla quanti prodotti sono stati verificati
    leal product_v, %eax        # salva in EAX l'indirizzo del numero di prodotti verificati
    movb (%eax), %cl            # mette in CL il numero di prodotti verificati
    leal product_n, %eax        # salva in EAX l'indirizzo del numero di prodotti
    movb (%eax), %ch            # mette in CH il numero di prodotti

    cmpb %cl, %ch               # compara PV con P
    jl v_inc
    jge v_save


v_inc:
    # Incrementa il puntatore al prodotto da verificare
    incl product_v
    jmp test_s
    

v_save:
    # Salva il valore dell'indirizzo del prodotto salvato in TMP, nel Vettore Indirizzi
    leal av_base_addr, %eax     # salva in EAX l'indirizzo base del vettore d'indirizzi
    movl %esi, (%eax)           # mette l'indirizzo di TMP nel vettore d'indirizzi
    
    # Incrementa il puntatore al vettore dello slot indirizzo successivo
    addl $4, (%eax)             # incrementa di 4 byte il puntatore al vettore dello slot indirizzo successivo

    # Somma TMP.DL a time
    leal time, %eax             # salva in EAX l'indirizzo di time
    xorl %ecx, %ecx             # pulisce ECX
    movb 2(%esi), %cl           # salva in CL il valore DL di TMP
    addl %ecx, (%eax)           # incrementa time del valore DL di TMP

    # Resetta il puntatore al prodotto da verificare
    leal product_v, %eax        # salva in EAX l'indirizzo del numero di prodotti verificati
    movl $0, (%eax)             # azzera l'offset da aggiugere al puntatore al prodotto da verificare

    # Incrementa contatore indirizzi salvati
    incl product_s

    jmp test_r


test_r:
    # Verifica se ci sono ritardi
    leal time, %eax             # salva in EAX l'indirizzo di time
    movb (%eax), %bl            # carica l'attuale valore di slot temporale in BL
    cmpb %bl, 2(%esi)           # compara time con la DL
    jg r_inc
    jle test_s_num
    

r_inc:
    # Calcola e Incrementa penality
    xorl %eax, %eax             # pulisce EAX
    leal time, %ebx             # salva in EBX l'indirizzo di time
    movb (%ebx), %al            # salva l'attuale valore di slot temporale in AL
    subb 2(%esi), %al           # sottrae il valore DL dal valore di time
    mulb 3(%esi)                # moltiplica il valore ottenuto per PR

    leal penality_val, %ebx     # salva in EBX l'indirizzo della variabile contatore di penalità
    addl %eax, (%ebx)           # incrementa il valore di penalità

    jmp test_s_num


test_s_num:
    # Verifica se il numero di indirizzi salvati è minore de numero di prodotti
    leal product_s, %eax        # salva in EAX l'indirizzo del numero d'indirizzi salvati
    movl (%eax), %ecx           # mette in CL il numero d'indirizzi salvati
    leal product_n, %eax        # salva in EAX l'indirizzo del numero di prodotti
    movl (%eax), %edx           # mette in EDX il numero di prodotti

    cmpl %ecx, %edx             # compara ADDR_N con P
    jl test_s
    jge exit


test_pr:
    # Verifica PR di TMP con PR del prodotto da verificare PV
    movb 3(%esi), %cl           # mette in CL il valore PR di TMP
    movb 3(%edi), %ch           # mette in CH il valore PR di PV
    cmpb %cl, %ch               # compara TMP.PR con PV.PR
    jg test_v_num
    jl v_tmp_cpy
    je test_id


test_id:
    # Verifica ID
    movb (%esi), %cl            # mette in CL il valore ID di TMP
    movb (%edi), %ch            # mette in CH il valore ID di PV
    cmpb %cl, %ch               # compara TMP.ID con PV.ID
    jne test_du
    je same_id_error


same_id_error:
    # Errore prodotto clone
    movl $4, %eax
    movl $1, %ebx
    leal errore_same_id_msg, %ecx
    movl errore_same_id_msg_len, %edx
    int $0x80

    jmp exit


test_du:    
    # Verifica se la somma delle due DU con Time rimane minore di DL
    xorl %eax, %eax             # pulisce EAX
    movb 1(%esi), %al           # mette in CL il valore DU di TMP
    addb 1(%edi), %al           # somma TMP.DU e PV.DU
    addl time, %eax             # (TMP.DU + PV.DU) + time

    cmpl %eax, 2(%esi)          # compara ((TMP.DU + PV.DU) + time) con DL
    jle v_save_both
    jg test_du_min


v_save_both:
    # Salva il valore dell'indirizzo di TMP nel Vettore
    movl av_base_addr, %eax     # salva in EAX l'indirizzo base del vettore d'indirizzi
    movl %esi, (%eax)           # mette l'indirizzo di TMP nel vettore d'indirizzi
    
    # Incrementa il puntatore al vettore dello slot indirizzo successivo
    leal av_base_addr, %eax     # salva in EAX l'indirizzo della variabile "av_base_addr" contenente l'indirizzo base del vettore d'indirizzi
    addl $4, (%eax)             # incrementa di 4 byte il puntatore al vettore dello slot indirizzo successivo

    # Somma TMP.DU a time
    leal time, %eax             # salva in EAX l'indirizzo di time
    xorl %ecx, %ecx             # pulisce ECX
    movb 2(%esi), %cl           # salva in CL il valore DU di TMP
    addl %ecx, (%eax)           # incrementa time del valore DL di TMP

    # Resetta il puntatore al prodotto da verificare
    leal product_v, %eax        # salva in EAX l'indirizzo del numero di prodotti verificati
    movl $0, (%eax)             # azzera l'offset da aggiugere al puntatore al prodotto da verificare

    # Incrementa contatore indirizzi salvati
    incl product_s
    
    # Verifica se il numero di indirizzi salvati è minore del numero di prodotti
    xorl %edx, %edx             # pulisce EDX

    leal product_s, %eax        # salva in EAX l'indirizzo del numero d'indirizzi salvati
    movl (%eax), %ecx           # mette in CL il numero d'indirizzi salvati
    leal product_n, %eax        # salva in EAX l'indirizzo del numero di prodotti
    movb (%eax), %dl            # mette in EDX il numero di prodotti

    cmpl %ecx, %edx             # compara ADDR_N con P
    je exit

    # Salva il valore dell'indirizzo di PV nel Vettore
    leal av_base_addr, %eax     # salva in EAX l'indirizzo base del vettore d'indirizzi
    movl %edi, (%eax)           # mette l'indirizzo di PV nel vettore d'indirizzi
    
    # Incrementa il puntatore al vettore dello slot indirizzo successivo
    addl $4, (%eax)             # incrementa di 4 byte il puntatore al vettore dello slot indirizzo successivo

    # Somma PV.DL a time
    leal time, %eax             # salva in EAX l'indirizzo di time
    xorl %ecx, %ecx             # pulisce ECX
    movb 2(%edi), %cl           # salva in CL il valore DL di PV
    addl %ecx, (%eax)           # incrementa time del valore DL di PV

    # Resetta il puntatore al prodotto da verificare
    leal product_v, %eax        # salva in EAX l'indirizzo del numero di prodotti verificati
    movl $0, (%eax)             # azzera l'offset da aggiugere al puntatore al prodotto da verificare

    # Incrementa contatore indirizzi salvati
    incl product_s

    jmp test_s_num


test_du_min:
    movb 1(%esi), %cl           # mette in CL il valore DU di TMP
    movb 1(%edi), %ch           # mette in CH il valore DU di PV
    cmpb %cl, %ch               # compara TMP.DU e PV.DU
    jg test_du_min_g
    je test_du_min_e
    jl test_du_min_l


test_du_min_l:
    # Salva il valore dell'indirizzo di TMP nel Vettore
    leal av_base_addr, %eax     # salva in EAX l'indirizzo base del vettore d'indirizzi
    movl %esi, (%eax)           # mette l'indirizzo di TMP nel vettore d'indirizzi
    
    # Incrementa il puntatore al vettore dello slot indirizzo successivo
    addl $4, (%eax)             # incrementa di 4 byte il puntatore al vettore dello slot indirizzo successivo

    # Somma TMP.DL a time
    leal time, %eax             # salva in EAX l'indirizzo di time
    xorl %ecx, %ecx             # pulisce ECX
    movb 2(%esi), %cl           # salva in CL il valore DL di TMP
    addl %ecx, (%eax)           # incrementa time del valore DL di TMP

    # Resetta il puntatore al prodotto da verificare
    leal product_v, %eax        # salva in EAX l'indirizzo del numero di prodotti verificati
    movl $0, (%eax)             # azzera l'offset da aggiugere al puntatore al prodotto da verificare

    # Incrementa contatore indirizzi salvati
    incl product_s

    jmp test_s_num


test_du_min_g:
    # Salva il valore dell'indirizzo di PV nel Vettore
    leal av_base_addr, %eax     # salva in EAX l'indirizzo base del vettore d'indirizzi
    movl %edi, (%eax)           # mette l'indirizzo di PV nel vettore d'indirizzi
    
    # Incrementa il puntatore al vettore dello slot indirizzo successivo
    addl $4, (%eax)             # incrementa di 4 byte il puntatore al vettore dello slot indirizzo successivo

    # Somma PV.DL a time
    leal time, %eax             # salva in EAX l'indirizzo di time
    xorl %ecx, %ecx             # pulisce ECX
    movb 2(%edi), %cl           # salva in CL il valore DL di PV
    addl %ecx, (%eax)           # incrementa time del valore DL di PV

    # Resetta il puntatore al prodotto da verificare
    leal product_v, %eax        # salva in EAX l'indirizzo del numero di prodotti verificati
    movl $0, (%eax)             # azzera l'offset da aggiugere al puntatore al prodotto da verificare

    # Incrementa contatore indirizzi salvati
    incl product_s

    jmp test_s_num


test_du_min_e:
    # Salva il valore dell'indirizzo di TMP nel Vettore
    leal av_base_addr, %eax     # salva in EAX l'indirizzo base del vettore d'indirizzi
    movl %esi, (%eax)           # mette l'indirizzo di TMP nel vettore d'indirizzi
    
    # Incrementa il puntatore al vettore dello slot indirizzo successivo
    addl $4, (%eax)             # incrementa di 4 byte il puntatore al vettore dello slot indirizzo successivo

    # Somma TMP.DL a time
    leal time, %eax             # salva in EAX l'indirizzo di time
    xorl %ecx, %ecx             # pulisce ECX
    movb 2(%esi), %cl           # salva in CL il valore DL di TMP
    addl %ecx, (%eax)           # incrementa time del valore DL di TMP

    # Resetta il puntatore al prodotto da verificare
    leal product_v, %eax        # salva in EAX l'indirizzo del numero di prodotti verificati
    movl $0, (%eax)             # azzera l'offset da aggiugere al puntatore al prodotto da verificare

    # Incrementa contatore indirizzi salvati
    incl product_s
    
    # Verifica se il numero di indirizzi salvati è minore del numero di prodotti
    leal product_s, %eax        # salva in EAX l'indirizzo del numero d'indirizzi salvati
    xorl %ecx, %ecx             # pulisce ECX
    movb (%eax), %cl            # mette in CL il numero d'indirizzi salvati
    leal product_n, %eax        # salva in EAX l'indirizzo del numero di prodotti
    movl (%eax), %edx           # mette in EDX il numero di prodotti

    cmpl %ecx, %edx             # compara ADDR_N con P
    je exit

    # Salva il valore dell'indirizzo di PV nel Vettore
    leal av_base_addr, %eax     # salva in EAX l'indirizzo base del vettore d'indirizzi
    movl %edi, (%eax)           # mette l'indirizzo di PV nel vettore d'indirizzi
    
    # Incrementa il puntatore al vettore dello slot indirizzo successivo
    addl $4, (%eax)             # incrementa di 4 byte il puntatore al vettore dello slot indirizzo successivo

    # Somma PV.DL a time
    leal time, %eax             # salva in EAX l'indirizzo di time
    xorl %ecx, %ecx             # pulisce ECX
    movb 2(%edi), %cl           # salva in CL il valore DL di PV
    addl %ecx, (%eax)           # incrementa time del valore DL di PV

    # Resetta il puntatore al prodotto da verificare
    leal product_v, %eax        # salva in EAX l'indirizzo del numero di prodotti verificati
    movl $0, (%eax)             # azzera l'offset da aggiugere al puntatore al prodotto da verificare

    # Incrementa contatore indirizzi salvati
    incl product_s

    jmp r_inc


print:
    # Stampa l'output
    movl $4, %eax
    movl $1, %ebx
    leal print_no_err_msg, %ecx
    movl print_no_err_msg_len, %edx
    int $0x80

    movl $4, %eax
    movl $1, %ebx
    leal print_penality_msg_1, %ecx
    movl print_penality_msg_len_1, %edx
    int $0x80

    movl $4, %eax
    movl $1, %ebx
    leal penality_val, %ecx
    movl $4, %edx
    int $0x80

    movl $4, %eax
    movl $1, %ebx
    leal print_penality_msg_2, %ecx
    movl print_penality_msg_len_2, %edx
    int $0x80

    jmp exit


exit:
    movl $1, %eax               # Syestem Call EXIT
    xorl %ebx, %ebx             # codice di uscita 0
    int $0x80                   # chiamata di sistema





    
test_s_pr:
    