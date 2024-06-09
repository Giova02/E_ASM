# Progetto ASM 2024  x/20s &buffer,,,, syscall per aprire file se ce se no crea, 5 - 65


# COSE DA DEBUGGARE:
#   marianna: counter_prodotti
#   riccardo: algoritmo in input, cancella ultima ordine e non stampa
#

.section .data  # dichiarazione variabili globali ------------------------------------------------------------|

menu: .ascii "Selezionare l algoritmo:\n1(EDF) , 2(HPF)\n" # stringa costante
menu_len: .long . - menu # numero a 32 bit la lunghezza della str hello, da questa posizione in mem(.) tolgo (-) fino a hello

errore_argomenti: .ascii "ERRORE NUMERO ARGOMENTI" 
errori_argomenti_len: .long . - errore_argomenti

errore_file: .ascii "ERRORE NELL APERTURA DEL FILE"
errore_file_len: .long . - errore_file

errore_algoritmo: .ascii "ERRORE INSERIMENTO ALGORITMO - INSERISCI 1 O 2\n"
errore_algoritmo_len: .long . - errore_algoritmo


file_lettura: .int 0 # file "Ordini.txt" dove leggere gli ordini
file_scrittura: .int 0 # file in cui scrivere l output

fd_lettura: .int 0
newline: .byte 10 # valore ascii nuova riga

n_scambi: .int 0
n_compare: .int 0

flag: .byte 0
counter: .byte 0

algoritmo: .int 0
counter_prodotti: .int 0

.section .bss  # heap
buffer: .zero 1024  # su 10 ordini il caso peggiore occupa 210 bit, circa 26 byte, per ora metto un buffer di 1K
data_address: .zero 4
data: .zero 1


.section .text      # sezione delle istruzioni (codice) -----------------------------------------------------|
    .global _start  # punto di inizoo del programma

_start: # PRENDO ARGOMENTI E NUMERO ARGOMENTI ---------------------------------------------------------------|

    popl %ecx  #  salvo il valore puntato del numero di argomenti

    subl $1, %ecx #  sottraggo 1 a il nomero puntato in ecx (numero argomenti)

    cmp $0, %ecx
    je error

    cmp $1, %ecx
    je uno_argomenti

    cmp $2, %ecx
    je due_argomenti

    jg error

uno_argomenti: # 1 ARGOMENTO --------------------------------------------------------------------------------|
    popl %ecx
    popl file_lettura

    movl $5, %eax        #  syscall open
    movl file_lettura, %ebx #  Nome del file
    movl $0, %ecx        #  Modalità di apertura (O_RDONLY)
    int $0x80           #  Interruzione del kernel

    #  Se c è un errore, esce
    cmp $0, %eax
    jl error_file

    movl %eax, fd_lettura

    jmp main_menu

due_argomenti: # 2 ARGOMENTI --------------------------------------------------------------------------------|
    popl %ecx
    popl file_lettura
    popl file_scrittura

    movl $5, %eax        #  syscall open
    movl file_lettura, %ebx #  Nome del file
    movl $0, %ecx        #  Modalità di apertura (O_RDONLY)
    int $0x80           #  Interruzione del kernel

    #  Se c è un errore, esce
    cmp $0, %eax
    jl error_file

    movl %eax, fd_lettura

    jmp main_menu


main_menu: # MENU PRINCIPALE DOVE STAMPA "SCEGLIERE UN ALGORITMO" -------------------------------------------|
    movl $4, %eax  # metto in eax il codice della system call write, 4
    movl $1, %ebx  # metto in ebx il file descriptor di stdout (standard out)
    leal menu, %ecx  # metto in ecx l indirizzo di menu
    movl menu_len, %edx # dico quanti byte stampare, la lunghezza di menu

    int $0x80 # interrupt generico 0x80

    # CHIEDO UN IMPUT ALL UTENTE -------------------------------------------|
    movl $3, %eax
    movl $0, %ebx
    movl algoritmo, %ecx
    movl $2, %edx  

    int $0x80 # int


lettura_file: # LEGGO FILE --------------------------------------------------------------------------------|

    # inizia da qui
    movl $3, %eax
    movl fd_lettura, %ebx
    movl $buffer, %ecx   # avro le cose lette in $(non so dove mettere quello che leggo)
    movl $1024, %edx

    int $0x80

    # ora che ho tutto nel buffer posso chiudere il file

    mov $6, %eax # syscall close
    mov fd_lettura, %ecx # File descriptor

    int $0x80 # Interruzione del kernel

    movl $buffer, %eax   # sposto il puntatore del buffer in %eax
    xorl %ebx, %ebx     # azzero ebx
    jmp lettura_stringa

lettura_stringa: # COUNTER PRODOTTI --------------------------------------------------|

    movb (%eax), %cl  # sposto il char %cl
    cmpb $0, %cl    #  comparo il char in cl per vedere se il file è finito
    je add_final_product     # jumpa alla fine. 

    cmpb newline, %cl   # confronto %cl con \n per vedere se è lo stesso carattere
    je next_string      # jumpa alla etichetta successiva

    incl %eax   # incremento il registro che contiene l indirizzo del char a cui sono arrivata
    jmp lettura_stringa     # ritorno all inizio dell etichetta


next_string: # INCREMENTO -----------------------------------------------------------------------------------|

    incl %eax       # incremento %eax perchè non è stato incrementato nell etichetta sopra
    incl counter_prodotti
    cmpb $0, (%eax)     # vedo se il file è finito
    je atoi

    jmp lettura_stringa     # ritorno all etichetta sopra


add_final_product: # CONTROLLO ------------------------------------------------------------------------------|
    # aumenta di 1 il counter prodotto se l ultimo carattere non è \n
    subb $1, %cl
    cmpb newline, %cl
    je atoi
    
    incl counter_prodotti
    jmp atoi

atoi: # CONVERSIONE DAL BUFFER A INT IN SEQUENZA ------------------------------------------------------------|

    movl $data, data_address        # sposto indirizzo di data in vatiabile
    movl $buffer, %ecx      # sposto in %ecx indirizzo della mia stringa/buffer
    xorl %ebx, %ebx     # azzero
    xorl %eax, %eax

conversione:

    movb (%ecx), %bl     # %ecx fa da offset a %bl
    cmpb $',', %bl       # vedo se è ","
    je salvataggio_con_incremento    # jump al salvataggio con incremento offset

    cmpb $10, %bl       # guardo se è \n
    je salvataggio_con_incremento   # jump al salvataggio con incremento

    cmpb $0, %bl    # guardo se il file è finito
    je salvataggio_per_comparare

    subb $48, %bl       # converto
    movl $10, %edx
    mulb %dl        # %ebx = %ebx * 10
    addl %ebx, %eax     # salva numero convertito in %eax

    incl %ecx       # incremento
    jmp conversione     # ripeto

salvataggio_con_incremento:
    incl %ecx       # passo al valore successivo 
    jmp salvataggio

salvataggio_per_comparare:  
    subl $1, %ecx       #   non incremento ecx per non andare in segmentation
    cmpl $10, (%ecx)    #   guardo se il carattere prima di \0 è \n
    je select_sort    # jump
    movb $1, flag       # se carattere prima non è \n imposto flag
    jmp salvataggio   # jump a etichetta per salvare carattere precedente


salvataggio:

    movl data_address, %ebx     # sposto l indirizzo nel registro
    movl %eax, (%ebx)       #   sposto la varibile ocnvertita nella cella puntata
    xorl %eax, %eax     # azzero 
    incl data_address       # mi sposto di uno nell indirizzo

    cmpb $1, flag   # guardo se la flag è stata impostata
    je select_sort

    jmp conversione     # ritorno alla conversione

# SORT ------------------------------------------------------------------------------------------------------|
select_sort: # FACCIO IL SORT EDF O HPF -----------------------------------|
    # cmpb $1, algoritmo # algoritmo = 1, EDF
    # je edf

    # cmpb $2, algoritmo # algoritmo = 1, EDF
    # je hpf

    # non prende il valore di algoritmo ------------------------ !!!!!!!!!!!!! DEBUG

    jmp edf # error_algoritmo 

edf: # ----------------------------- ALGORITMO EDF ----------------------------------------------------------|

    leal data, %eax #metto il puntatore allinizio della stringa, in esi.
    # qui sommo per arrivare a priorità o scadenza (nel caso di edf scadenza, 2)
    addl $2 , %eax
    movl $3, counter_prodotti
    decl counter_prodotti

    compare_edf:
    
        incl n_compare
        movb (%eax), %cl
        cmpb %cl, 4(%eax)
    
        jl scambio_edf
    
    back_edf:
        movl n_compare, %ecx
        cmpl %ecx, counter_prodotti
        je controllo_scambi_edf
    
        addl $4, %eax
        jmp compare_edf
    
    scambio_edf:
        movl -2(%eax), %ecx # salvo i primi 4 byte in ecx
        movl 2(%eax), %edx # salvo i secondi 4 byte in edx
    
        movl %ecx, 2(%eax) # scambio
        movl %edx, -2(%eax)
    
        incl n_scambi
        jmp back_edf
    
    controllo_scambi_edf:
        cmpl $0, n_scambi
        je exit_edf
    
        movl $0, n_scambi
        movl $0, n_compare
    
        leal data, %eax
        addl $2, %eax
    
        jmp compare_edf
    
    exit_edf:
        subl $2, %eax
        movl $4, %eax
        movl $1, %ebx
        leal data, %ecx
        # addb $ 0 , counter_prodotti
        
        movl $24, %edx
    
        int $0x80
    
        movl $1, %eax # metto in eax il codice della system call, 1 exit
        xorl %ebx, %ebx # metto a 0 il registro EBX, per settare il valore di uscita del programma (exception)
    
        int $0x80


hpf: # ----------------------------- ALGORITMO HPF ----------------------------------------------------------|
    leal data, %eax #metto il puntatore allinizio della stringa, in esi.
    # qui sommo per arrivare a priorità o scadenza (nel caso di edf scadenza)
    addl $1 , %eax # hpf
    decl counter_prodotti

    compare_hpf:

        incl n_compare
        movb (%eax), %cl
        cmpb %cl, 4(%eax)

        jg scambio_hpf

    back_hpf:
        movl n_compare, %ecx
        cmpl %ecx, counter_prodotti
        je controllo_scambi_hpf

        addl $4, %eax
        jmp compare_hpf

    scambio_hpf:
        movl -1(%eax), %ecx # salvo i primi 4 byte in ecx
        movl 3(%eax), %edx # salvo i secondi 4 byte in edx

        movl %ecx, 3(%eax) # scambio
        movl %edx, -1(%eax)

        incl n_scambi
        jmp back_hpf

    controllo_scambi_hpf:
        cmpl $0, n_scambi
        je exit_hpf

        movl $0, n_scambi
        movl $0, n_compare

        leal data, %eax
        addl $1, %eax

        jmp compare_hpf

    exit_hpf:
        subl $2, %eax
        movl $4, %eax
        movl $1, %ebx
        leal data, %ecx
        # addb $ 0 , counter_prodotti

        movl $16, %edx

        int $0x80

        movl $1, %eax # metto in eax il codice della system call, 1 exit
        xorl %ebx, %ebx # metto a 0 il registro EBX, per settare il valore di uscita del programma (exception)

        int $0x80

# ERRORI ----------------------------------------------------------------------------------------------------|

error_file: # ERRORE APERTURA FILE --------------------------------------------------------------------------|
    #  stampo errore apertura file
    movl $4, %eax  # metto in eax il codice della system call write, 4
    movl $1, %ebx  # metto in ebx il file descriptor di stdout (standard out)
    leal errore_file, %ecx  # metto in ecx l indirizzo di hello
    movl errore_file_len, %edx # dico quanti byte stampare, la lunghezza di hello

    int $0x80

    movl $1, %eax
    xorl %ebx, %ebx

    int $0x80

error: # ERRORE NUMERO ARGOMENTI ----------------------------------------------------------------------------|
    #  stampo errore nel numero di argomenti
    movl $4, %eax  # metto in eax il codice della system call write, 4
    movl $1, %ebx  # metto in ebx il file descriptor di stdout (standard out)
    leal errore_argomenti, %ecx  # metto in ecx l indirizzo di hello
    movl errori_argomenti_len, %edx # dico quanti byte stampare, la lunghezza di hello

    int $0x80

    movl $1, %eax
    xorl %ebx, %ebx

    int $0x80

error_algoritmo: # ERRORE NUMERO ARGOMENTI ----------------------------------------------------------------------------|
    #  stampo errore nel numero di argomenti
    movl $4, %eax  # metto in eax il codice della system call write, 4
    movl $1, %ebx  # metto in ebx il file descriptor di stdout (standard out)
    leal errore_algoritmo, %ecx  # metto in ecx l indirizzo di hello
    movl errore_algoritmo_len, %edx # dico quanti byte stampare, la lunghezza di hello

    int $0x80

    movl $1, %eax
    xorl %ebx, %ebx

    int $0x80


# FUNZIONI --------------------------------------------------------------------------------------------------|

.type print_string, @function # STAMPA DATA -----------------------------------------------------------------|
print_string:
    movl $4, %eax
    movl $1, %ebx
    leal data, %ecx
    
    movl $16, %edx

    int $0x80

    ret
