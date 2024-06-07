
# MARIANNA ---------------------------------

    movl $buffer, %eax   # sposto il puntatore del buffer in %eax

    movl $string1, %edx  # sposto il puntatore della stringa1 in %edx

    xorl %ebx, %ebx     # azzero ebx


lettura_stringa:

    movb (%eax), %cl   # sposto in %cl il registro %eax sommato al suo offset, inizializzato a zero
    cmpb $0, %cl    # altrimenti va avanti e confronta se %cl è NULL, quindi se il file è terminato
    #   !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    je exit     # jumpa al continuo, all'algoritmo, momentaneamente lho messo in exit. 

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
    je exit

    addl $11, %edx      # sommo 11 a edx per passare alla riga successiva
    jmp lettura_stringa     # ritorno all'etichetta sopra


exit:
    call print_saved # mi serve per printare i prodotti senza lo \n

    # exit MARIANNA---------------------------------------------

    # faccio un altra system call per pulire la memoria
    movl $1, %eax # metto in eax il codice della system call, 1 exit
    xorl %ebx, %ebx # metto a 0 il registro EBX, per settare il valore di uscita del programma (exception)

    int $0x80 #  ""

    # funzione per printare il buffer senza \n
.type print_saved, @function
print_saved:
    movl $4, %eax
    movl $1, %ebx
    leal string1, %ecx
    # subl $7, %ecx    # !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    movl $110, %edx

    int $0x80

    ret    

    # exit MARIANNA----------------------------


