.section .data
    time:
        .byte 0
    p_time:
        .byte 100
        
    product_num:
        .byte 1

    errore_same_id_msg:
        .ascii "Errore: Stessi dati prodotto trovati più volte\n"
    errore_same_id_msg_len:
        .long . - errore_same_id_msg
    

.section .bss
    data:
        .space 1500
        
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


.section .text
    .globl _start

_start:

    leal product_num, %eax      # salva l'indirizzo del numero di prodotti in EAX 
    movb (%eax), %bl            # carica il valore del numero di prodotti in BL
    movb $19, %al               # carica 19 (dimensione in byte della struttura dati) in AL
    incb %bl                    # incrementa BL per poter poi puntare all'indirizzo posto subito dopo all'ultima struttura relativa ai prodotti salvati
    mulb %bl                    # moltiplica BL per la dimensione di ogni struttura dati in modo a ottenere il corretto offset
    leal addr_v_distance, %ebx  # salva l'indirizzo della variabile di offset ottenuto in EBX 
    movw %ax, (%ebx)            # salva il valore della variabile di offset ottenuto in EBX 

after_save_addr:

    leal substring_id_tmp, %edi # salva l'indirizzo dell'ID temporaneo in EDI
    leal substring_id, %esi     # salva l'indirizzo dell'ID di verifica in ESI

check_loop:
    movb 2(%edi), %dh           # salva il valore puntato da EDI in DH     Indirizzo ID + 2 Byte = Indirizzo DL
    movb 2(%esi), %dl           # salva il valore puntato da ESI in DL     Indirizzo ID + 2 Byte = Indirizzo DL

    cmpb %dh, %dl               # compara i due valori di DL
    jl continua                 # se DH è minore di DL salta ad "continua" (va avanti ignorando il prodotto)
    jg superiore                # se DH è maggiore di DL salta a "superiore" (copia i dati del prodotto di verifica nello slot temporaneo)
    je uguale                   # se DH e DL sono uguali salta a "uguale" (verifica quale ha priorità maggiore)

superiore:
    movb (%esi), %al            # copia ID da Verifica a Temporaneo
    movb %al, (%edi)            # copia ID da Verifica a Temporaneo

    movb 1(%esi), %al           # copia DU da Verifica a Temporaneo     1dirizzo ID + 1 Byte = Indirizzo DU
    movb %al, 1(%edi)           # copia DU da Verifica a Temporaneo     Indirizzo ID + 1 Byte = Indirizzo DU

    movb 2(%esi), %al           # copia DL da Verifica a Temporaneo     Indirizzo ID + 2 Byte = Indirizzo DL
    movb %al, 2(%edi)           # copia DL da Verifica a Temporaneo     Indirizzo ID + 2 Byte = Indirizzo DL

    movb 3(%esi), %al           # copia PR da Verifica a Temporaneo     Indirizzo ID + 3 Byte = Indirizzo PR
    movb %al, 3(%edi)           # copia PR da Verifica a Temporaneo     Indirizzo ID + 3 Byte = Indirizzo PR

    jmp continua

uguale:
    movb 3(%edi), %dh           # salva il valore puntato da EDI in DH     Indirizzo ID + 3 Byte = Indirizzo PR
    movb 3(%esi), %dl           # salva il valore puntato da EDI in DL     Indirizzo ID + 3 Byte = Indirizzo PR
    cmpb %dh, %dl               # compara i due valori di PR
    jl  superiore
    jg  continua
    je same_id_check

same_id_check:
    cmpl %edi, %esi             # se sta verificando lo stesso prodotto passa al prossimo senza dare errore
    je continua

    movb (%edi), %dh            # salva il valore puntato da EDI in DH     Indirizzo ID
    movb (%esi), %dl            # salva il valore puntato da EDI in DL     Indirizzo ID
    cmpb %dh, %dl               # compara i due valori di ID
    je errore_same_id


continua:
    leal product_num, %ebx      # carica l'indirizzo del numero totale di prodotti in EBX
    movb (%ebx), %al            # carica il valore del numero totale di prodotti in AL
    cmpb %cl ,%al               # verifica se ci sono ancora prodotti da verificare
    jge save_addr

    incb %cl                    # incrementa il contatore di prodotti
    addl $19, %esi              # incrementa l'indirizzo da verificare di 19 byte (dimensione della struttura dati)

    jmp check_loop              # ricomincia
    
save_addr:
    
    leal time, %ebx             # carica l'indirizzo dello slot temporale in EBX
    movb (%ebx), %al            # carica il valore dello slot temporale in AL
    addb 1(%edi), %al           # somma la durata del valore salvato al valore di slot temporali utilizzati
    movb %al, (%ebx)            # carica il valore dello slot temporale all'indirizzo puntato da EBX (variabile "time")

    cmpb $100, %al              # verifica se è ancora nel limite di tempo imposto
    jge penality                # se fuori dal limite di tempo salta a "penality" (calcolo della spesa extra di penalità)
    
    leal addr_v_distance, %eax  # carica l'indirizzo della variabile contenente la distanza tra il primo prodotto salvato e il primo indirizzo salvato
    movl (%eax), %ebx           # carica il valore puntato da EAX in EBX
    addl %esi, %ebx             # somma il valore di ESI (indirizzo base del prodotto temporaneo) a EBX (tra il primo prodotto salvato e il primo indirizzo salvato)
    mov %edi, (%ebx)            # salva il valore di EDI nell'indirizzo calcolato in EBX
    
    movl (%eax), %ebx           # carica il valore puntato da EAX in EBX
    incl %ebx                   # incrementa il valore "addr_v_distance" così salva il prossimo indirizzo nella posizione successiva
    movl %ebx, (%eax)           # salva il valore incrementato nella variabile "addr_v_distance" puntata da EAX

    jmp after_save_addr


penality:
    leal p_time, %ebx           # salva l'indirizzo del tempo totale in caso di penalità
    subb (%ebx), %al            # ottiene gli slot temporali di ritardo
    addb  %al, (%ebx)           # incrementa il tempo totale in caso di penalità per rimanere corretti con i conti sui costi di penalità in base a priorità successive

    mulb 3(%edi)                # moltiplica il valore di priorità del prodotto temporaneo per AL (numero di slot temporali in ritardo) (risultato salvato in AX)
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
