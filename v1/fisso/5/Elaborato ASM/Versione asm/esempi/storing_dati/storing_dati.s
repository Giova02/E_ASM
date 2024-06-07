.section .data
    p0_addr:
        .int 0
    p0_dur_addr:
        .int 0
    next_p_offset:
        .byte 0

# Salvataggio indirizzi base di durata, deadline, priority e stringa primo prodotto
    leal p0_dur, %esi                                   # Salvo l indirizzo base del primo dato di durata in ESI
    leal p0_dur_addr, %edi                              # Salvo l indirizzo della variabile p0_addr in EDI
    movl %esi, (%edi)                                   # Muove il valore dell indirizzo base del primo dato di durata in p0_dur_addr
    
    leal p0, %esi                                       # Salvo l indirizzo base del primo prodotto in ESI
    leal p0_addr, %edi                                  # Salvo l indirizzo della variabile p0_addr in EDI
    movl %esi, (%edi)                                   # Muove il valore dell indirizzo base del primo prodotto in p0_addr

    xorl %edi, %edi                                     # svuoto EDI per pulizia

    movb $2, %bh                                        # imposta quante volte deve eseguire tutto il processo (2 perche durata e deadline hanno la stessa dimensione di 2 caratteri nella stringa)
    
    twotime_loop:

    movb pn, %bl                                        # salva il valore dei prodotti in BL per usarlo come contatore

    find_data:

    movb (%esi), %al                                    # Carica il byte dall'indirizzo puntato da ESI in AL 
    cmpb comma, %al                                     # Comma check
    xorb %al, %al                                       # svuoto AL per pulizia
    incl %esi                                           
    jne find_data


# Converte il valore del dato da carattere a valore numerico
    movb $10, %al                                       # moltiplicatore
    movb (%esi), %ah                                    # salvo in AH il valore in byte puntato dal contatore di stringa presente in ESI
    subb $'0', %ah                                      # converto il carattere presente in AH nel valore numerico corrispondente
    incl %esi
    movb (%esi), %cl                                    # Carica il byte dall'indirizzo puntato da ESI+1 in CL 
    decl %esi
    cmpb comma, %cl                                     # verifico se il prossimo valore e una virgola
    je data_comma_found                                 # se e una virgola salta a "comma_found"
    mul %ah                                             # moltiplico AH per 10 (risultato in AX (ma sta tutto in AL) )
    subb $'0', %cl                                      # converto il carattere presente in CH nel valore numerico corrispondente
    addb %cl, %al                                       # sommo al moltiplicato il valore del carattere successivo convertito in valore numerico
    xorb %cl, %cl                                       # svuoto CL per pulizia
    
    data_comma_found:

# trovo il valore di offset alla base del prossimo prodotto
    xorl %edi, %edi                                     # svuoto il registro che conterra il valore di offset
    next_p:
    cmpb $0, (%esi)                                     # verifico se il carattere letto dalla stringa sia il terminatore
    incb %esi                                           # incremento l indirizzo che punta alla stringa
    incb %edi                                           # incremento registro contentente il valore di offset
    jne next_p                                          # nel caso non sia stato trovato il terminatore reitera

    leal next_p_offset, %esi                            # salvo il valore di offset nella variabile "next_p_offset"
    movl %edi, (%esi)
    xorl %edi, %edi

# Salva il valore numerico del dato nella variabile corrispondente
    leal (%edi+p0_dur_addr), %esi                       # salva EDI (usato come contatore) sommato all'indirizzo della base della durata del primo prodotto, in ESI
    movb %al, (%esi)                                    # salva il valore di deadline precedentemente ottenuto nell indirizzo puntato da ESI
    xorb %al, %al                                       # svuoto AL per pulizia
    decb %bl                                            # decrementa il contatore dei prodotti rimanenti
    cmpb $0, %bl                                        # verifica se sono finiti i prodotti da analizzare
    jge find_data                                       # in caso contrario lo rifa per il prossimo prodotto
    
    decb %bh                                            # decrementa il contatore di ripetizioni
    cmpb $0, %bh                                        # verifica se sono finite le ripetizioni
    jne twotime_loop                                    # in caso contrario parte un altro ciclo





    find_priority:

    movb (%esi), %al                                    # Carica il byte dall'indirizzo puntato da ESI in AL 
    cmpb comma, %al                                     # Comma check
    xorb %al, %al                                       # svuoto AL per pulizia
    jne priority_comma_not_found        
    incb %dl                                            # Trovata una virgola incrementa il contatore DL (necessario per capire quando si stanno leggendo i dati voluti)
    
    priority_comma_not_found:                           # Altrimenti non incrementa il contatore della virgola e continua
    
    incl %esi                                           # incrementa il valore d'indirizzo del puntatore per passare al prossimo valore della stringa
    cmpb data_type, %dl                                 # se e stata trovata una virgola significa che il valore dopo e un dato da salvare
    jne find_data                                       # nel caso non si sia raggiunta la virgola torna su

# Converte il valore del dato da carattere a valore numerico
    movb (%esi), %ah                                    # salvo in AH il valore in byte puntato dal contatore di stringa presente in ESI
    subb $'0', %ah                                      # converto il carattere presente in AH nel valore numerico corrispondente

# Salva il valore numerico del dato nella variabile corrispondente
    leal (%edi+p0_dur_addr), %esi                       # salva EDI (usato come contatore) sommato all'indirizzo della base della durata del primo prodotto, in ESI
    movb %al, (%esi)                                    # salva il valore di deadline precedentemente ottenuto nell indirizzo puntato da ESI
    addl $8, %edi                                       # incrementa di un byte il valore di edi per puntare all indirizzo della prossima variabile
    xorb %al, %al                                       # svuoto AL per pulizia
    decb %bl                                            # decrementa il contatore dei prodotti rimanenti
    cmpb $0, %bl                                        # verifica se sono finiti i prodotti da analizzare
    jge find_data
    