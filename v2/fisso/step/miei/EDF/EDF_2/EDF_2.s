.section .data
    time:
        .byte 0
        
    product_n:
        .byte 1
    product_v:
        .int 0
    product_s:
        .int 0

    errore_same_id_msg:
        .ascii "Errore: Stessi dati prodotto trovati più volte\n"
    errore_same_id_msg_len:
        .long . - errore_same_id_msg
    

.section .bss
    av_distance:
        .word
    av_base_addr:
        .long
        
    penality_val:
        .word
        
    substring_id_tmp:
        .byte
    substring_du_tmp:
        .byte
    substring_dl_tmp:
        .byte
    substring_pr_tmp:
        .byte

    substring_s:
        .zero 11
    substring_len:
        .long
    substring_id:
        .byte

    data:                       # memoria riservata ai prossimi dati da inserire
        .space 15000

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

    addl $15, %eax

    # Prodotto 2
    movb $35, (%eax)
    movb $9, 1(%eax)
    movb $23, 2(%eax)
    movb $5, 3(%eax)

    addl $15, %eax

    # Prodotto 3
    movb $47, (%eax)
    movb $10, 1(%eax)
    movb $45, 2(%eax)
    movb $5, 3(%eax)

    addl $15, %eax

    # Prodotto 4
    movb $53, (%eax)
    movb $8, 1(%eax)
    movb $59, 2(%eax)
    movb $5, 3(%eax)

    addl $15, %eax

    # Prodotto 5
    movb $78, (%eax)
    movb $5, 1(%eax)
    movb $68, 2(%eax)
    movb $5, 3(%eax)

    addl $15, %eax

    # Prodotto 6
    movb $89, (%eax)
    movb $10, 1(%eax)
    movb $72, 2(%eax)
    movb $5, 3(%eax)

    addl $15, %eax

    # Prodotto 7
    movb $91, (%eax)
    movb $6, 1(%eax)
    movb $84, 2(%eax)
    movb $5, 3(%eax)

    addl $15, %eax

    # Prodotto 8
    movb $104, (%eax)
    movb $8, 1(%eax)
    movb $91, 2(%eax)
    movb $5, 3(%eax)

    addl $15, %eax

    # Prodotto 9
    movb $116, (%eax)
    movb $10, 1(%eax)
    movb $33, 2(%eax)
    movb $5, 3(%eax)

    addl $15, %eax

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





    # salva in TMP il primo valore a verificare
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


test_tmp_v:
    # Verifica DL di TMP con DL del prodotto da verificare PV
    leal substring_id_tmp, %esi # salva in ESI l'indirizzo dell'ID di TMP
    movb 2(%esi), %cl           # mette in CL il valore DL di TMP
    leal substring_id, %edi     # salva in ESI l'indirizzo dell'ID di PV
    cmpl $0, product_v
    je no_offset
    addl product_v, %edi        # aggiunge l'offset all'indirizzo di PV
no_offset:
    movb 2(%edi), %ch           # mette in CH il valore DL di PV

    cmpb %cl, %ch               # compara i due valori di DL
    jl v_inc
    jg test_time
    je test_pr


test_time:
    # Verifica se DL del prodotto verificato è maggiore di time
    leal time, %eax             # salva in EAX l'indirizzo dello slot temporale attuale
    movb (%eax), %cl            # mette in CL il valore dello slot temporale attuale
    
    cmpb %ch, %cl               # compara DL di PV con time
    jle test_v_num
    jg v_tmp_cpy


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

    jmp test_tmp_v
    

v_save:
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

    jmp test_r


test_r:
    # Verifica se ci sono ritardi
    leal time, %eax             # salva in EAX l'indirizzo di time
    movb (%eax), %bl            # carica l'attuale valore di slot temporale in BL
    cmpb %bl, 2(%esi)           # compara time con la DL
    jg r_inc
    jle test_s_num
    

r_inc:
    # Incrementa penality
    leal time, %ebx             # salva in EBX l'indirizzo di time
    movb (%ebx), %al            # salva l'attuale valore di slot temporale in AL
    subb 2(%esi), %al           # sottrae il valore DL dal valore di time
    mulb 3(%esi)                # moltiplica il valore ottenuto per PR

    leal penality_val, %ebx     # salva in EBX l'indirizzo della variabile contatore di penalità
    addw %ax, (%ebx)            # incrementa il valore di penalità


test_s_num:
    leal product_s, %eax        # salva in EAX l'indirizzo del numero d'indirizzi salvati
    xorl %ecx, %ecx             # pulisce ECX
    movb (%eax), %cl            # mette in CL il numero d'indirizzi salvati
    leal product_n, %eax        # salva in EAX l'indirizzo del numero di prodotti
    movl (%eax), %edx           # mette in EDX il numero di prodotti

    cmpl %ecx, %edx             # compara ADDR_N con P
    jl test_tmp_v
    je exit


test_pr:
    # Verifica DL di TMP con DL del prodotto da verificare PV
    movb 3(%esi), %cl           # mette in CL il valore PR di TMP
    movb 3(%edi), %ch           # mette in CH il valore PR di PV
    cmpb %cl, %ch               # compara TMP.PR con PV.PR
    jg test_time
    jl test_v_num
    je test_id


test_id:
    movb (%esi), %cl            # mette in CL il valore ID di TMP
    movb (%edi), %ch            # mette in CH il valore ID di PV
    cmpb %cl, %ch               # compara TMP.ID con PV.ID
    jne test_du
    je same_id_error


test_du:
    xorl %eax, %eax             # pulisce EAX
    movb 1(%esi), %cl           # mette in CL il valore DU di TMP
    movb 1(%edi), %al           # mette in AL il valore DU di PV
    addb %cl, %al               # somma TMP.DU e PV.DU
    addl time, %eax             # (TMP.DU + PV.DU) + time

    cmpl %eax, 2(%esi)          # compara ((TMP.DU + PV.DU) + time) con DL
    jle v_save_both
    jg test_du_min


same_id_error:
    # Errore prodotto clone
    movl $4, %eax
    movl $1, %ebx
    leal errore_same_id_msg, %ecx
    movl errore_same_id_msg_len, %edx
    int $0x80

    jmp exit


v_save_both:
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


exit:
    movl $1, %eax               # Syestem Call EXIT
    xorl %ebx, %ebx             # codice di uscita 0
    int $0x80                   # chiamata di sistema
