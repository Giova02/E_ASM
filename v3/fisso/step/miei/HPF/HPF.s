.section .data
    time:
        .byte 0
    p_time:
        .byte 100

    same_p:
        .byte 0
        
    product_num:
        .byte 10
        
    av_saved_addr_num:
        .byte 0

    errore_same_id_msg:
        .ascii "Errore: Stessi dati prodotto trovati più volte\n"
    errore_same_id_msg_len:
        .long . - errore_same_id_msg
    

.section .bss

    av_distance:
        .int
        
    av_base_addr:
        .int
        
    penality_val:
        .word
        
    substring_s_tmp:
        .zero 11
    substring_len_tmp:
        .int
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
        .int
    substring_id:
        .byte
    substring_du:
        .byte
    substring_dl:
        .byte
    substring_pr:
        .byte


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


# calcola l'offset tra l'indirizzo del primo prodotto salvato l'indirizzo base del vettore di indirizzi

    leal product_num, %eax      # salva l'indirizzo del numero di prodotti in EAX 
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

    xorb %cl, %cl               # azzera il contatore dei prodotti verificati

after_save_addr:

    leal substring_id_tmp, %edi # salva l'indirizzo dell'ID temporaneo in EDI
    leal substring_id, %esi     # salva l'indirizzo dell'ID di verifica in ESI

check_loop:
    movb 3(%edi), %dh           # salva il valore puntato da EDI in DH     Indirizzo ID + 2 Byte = Indirizzo PR
    movb 3(%esi), %dl           # salva il valore puntato da ESI in DL     Indirizzo ID + 2 Byte = Indirizzo PR

    cmpb %dh, %dl               # compara i due valori di PR
    jg continua                 # se DH è maggiore di DL salta ad "continua" (va avanti ignorando il prodotto )
    jl minore                   # se DH è minore di DL salta a "minore" (copia i dati del prodotto  di verifica nello slot temporaneo)
    je uguale                   # se DH e DL sono uguali salta a "uguale" (verifica quale ha scadenza minore)

minore:
    leal time, %eax             # controlla se la DL del valore verificato è già stata superata ddal valore di slot temporale, se si ignora il valore da verificare, altrimenti swap
    movb (%eax), %bl
    cmpb %bl, 2(%esi)
    jle continua

    movb (%esi), %al            # copia ID da Verifica a Temporaneo
    movb %al, (%edi)            # copia ID da Verifica a Temporaneo

    movb 1(%esi), %al           # copia DU da Verifica a Temporaneo     Indirizzo ID + 1 Byte = Indirizzo DU
    movb %al, 1(%edi)           # copia DU da Verifica a Temporaneo     Indirizzo ID + 1 Byte = Indirizzo DU

    movb 2(%esi), %al           # copia DL da Verifica a Temporaneo     Indirizzo ID + 2 Byte = Indirizzo DL
    movb %al, 2(%edi)           # copia DL da Verifica a Temporaneo     Indirizzo ID + 2 Byte = Indirizzo DL

    movb 3(%esi), %al           # copia PR da Verifica a Temporaneo     Indirizzo ID + 3 Byte = Indirizzo PR
    movb %al, 3(%edi)           # copia PR da Verifica a Temporaneo     Indirizzo ID + 3 Byte = Indirizzo PR

    jmp continua

uguale:
    movb 2(%edi), %dh           # salva il valore puntato da EDI in DH     Indirizzo ID + 3 Byte = Indirizzo PR
    movb 2(%esi), %dl           # salva il valore puntato da EDI in DL     Indirizzo ID + 3 Byte = Indirizzo PR
    cmpb %dh, %dl               # compara i due valori di PR
    jg minore
    jl continua
    je same_id_check

same_id_check:

    movb (%edi), %dh            # salva il valore puntato da EDI in DH     Indirizzo ID
    movb (%esi), %dl            # salva il valore puntato da EDI in DL     Indirizzo ID
    cmpb %dh, %dl               # compara i due valori di ID
    je flag

flag:
    cmpb $0, same_p
    je inc_flag                 # se è la prima volta incrementa la flag e passa al prossimo prodotto
    jne errore_same_id          # se non è la prima volta allora ci sono almeno 2 prodotti identici e salta a "errore_same_id"

inc_flag:                       # incrementa la flag e passa al prossimo prodotto
    incb same_p
    jmp continua


continua:
    leal product_num, %ebx      # carica l'indirizzo del numero totale di prodotti in EBX
    movb (%ebx), %al            # carica il valore del numero totale di prodotti in AL
    cmpb %cl, %al               # verifica se ci sono ancora prodotti da verificare
    je save_addr

    incb %cl                    # incrementa il contatore di prodotti
    addl $19, %esi              # incrementa l'indirizzo da verificare di 19 byte (dimensione della struttura dati)

    jmp check_loop              # ricomincia
    
save_addr:
    movb $0, same_p
    incb av_saved_addr_num
    

    

    leal av_saved_addr_num, %eax
    leal av_base_addr, %ebx
    movb (%eax), %cl
    xorb %ch, %ch

    cmpb %ch, %cl               # verifica se è il primo indirizzo da salvare nel vettore
    jne av_check
    jmp no_av_check

av_check:    
    movb %ch, %al

    sall $24, %eax
    sarl $24, %eax

    cmpl %edi, (%eax, %ebx)
    

    incb %ch
    cmpb %ch ,%cl
    jl av_check


no_av_check:
    leal time, %ebx             # carica l'indirizzo dello slot temporale in EBX
    movb (%ebx), %al            # carica il valore dello slot temporale in AL
    addb 1(%edi), %al           # somma la durata del valore salvato al valore di slot temporali utilizzati
    movb %al, (%ebx)            # carica il valore dello slot temporale all'indirizzo puntato da EBX (variabile "time")

    cmpb $100, %al              # verifica se è ancora nel limite di tempo imposto
    jge penality                # se fuori dal limite di tempo salta a "penality" (calcolo della spesa extra di penalità)
    
    leal av_distance, %eax      # carica l'indirizzo della variabile contenente la distanza tra il primo prodotto salvato e il primo indirizzo salvato
    movl (%eax), %ebx           # carica il valore puntato da EAX in EBX
    addl %esi, %ebx             # somma il valore di ESI (indirizzo base del prodotto temporaneo) a EBX (tra il primo prodotto salvato e il primo indirizzo salvato)
    movl %edi, (%ebx)           # salva il valore di EDI nell'indirizzo calcolato in EBX
    
    movl (%eax), %ebx           # carica il valore puntato da EAX in EBX
    addl $4, %ebx               # incrementa di 4 byte (32 bit) il valore "av_distance" così salva il prossimo indirizzo nella posizione successiva
    movl %ebx, (%eax)           # salva il valore incrementato nella variabile "av_distance" puntata da EAX

    leal same_p, %eax           # azzera la flag nel caso verificasse con se stesso
    movb $0, (%eax)

    jmp after_save_addr


penality:
    leal p_time, %ebx           # salva l'indirizzo del tempo totale in caso di penalità
    subb (%ebx), %al            # ottiene gli slot temporali di ritardo
    addb  %al, (%ebx)           # incrementa il tempo totale in caso di penalità per rimanere corretti con i conti sui costi di penalità in base a priorità successive

    mulb 3(%edi)                # moltiplica il valore di priorità del prodotto  temporaneo per AL (numero di slot temporali in ritardo) (risultato salvato in AX)
    leal penality_val, %ebx     # salva l'indirizzo della variabile contenente la penalità
    addw %ax, (%ebx)            # aggiorna il valore della variabile contenente la penalità totale sommandoci quella trovata


errore_same_id:                 # messaggio d'errore prodotti clone
    movl $4, %eax
    movl $1, %ebx
    leal errore_same_id_msg, %ecx
    movl errore_same_id_msg_len, %edx
    int $0x80
    jmp exit
    

exit:
    movl $1, %eax               # Syestem Call EXIT
    xorl %ebx, %ebx             # codice di uscita 0
    int $0x80                   # chiamata di sistema
