.section .data                                                      # Variabili inizializzate
    # General Porposes
        newline:
            .byte 10                                                # valore corrispettivo allo \n
        comma:          
            .byte 44                                                # valore corrispettivo alla virgola

    # parametri 
        first_parameter_name:   
            .ascii "Ordini.txt"                                     # Stringa contenente il nome di default del primo parametro
        second_parameter_name:          
            .ascii "Pianificazione.txt"                             # Stringa contenente il nome di default del secondo parametro
        output_export:      
            .byte '1'                                               # Variabile usata per salvare la scelta di output

    # stampa errore apertura file        
        file_open_error_string:     
                .ascii "Errore durante l apertura del file\n"       # Stringa contenente la stringa da stampare in caso di errore durante la lettura del file
        file_open_error_string_len:     
              .long . - file_open_error_string                      # lunghezza della stringa in byte

    # stampa errore lettura file        
        file_read_error_string:     
                .ascii "Errore durante la lettura del file\n"       # Stringa contenente la stringa da stampare in caso di errore durante la lettura del file
        file_read_error_string_len:     
              .long . - file_read_error_string                      # lunghezza della stringa in byte


    # stampa / lettura scelta algoritmo
        ask_algorithm_mode_string:                                  # Stringa contenente la stringa da stampare per chiedere l'algoritmo da utilizzare
                .ascii "Quale algoritmo di pianificazione dovrà usare il programma?\n\t1) Earliest Deadline First (EDF)\n\t2) Highest Priority First (HPF)\n\nPremi CTRL + C per uscire\n\n"
        ask_algorithm_mode_string_len:
              .long . - file_open_error_string                      # lunghezza della stringa in byte
        ask_algorithm_mode_buffer:                                  
            .skip 1                                                 # buffer lungo 1 (dimensione del valore da leggere)

    # lettura file      
        fd:     
            .int 0                                                  # File descriptor
        file_read_buffer: .string ""                                # Spazio per il buffer di input
        lines: .int 0                                               # Numero di linee
    
    # Gestione dati
        pn:                                                         # numero di prodotti
            .byte 0
        char_c:                                                     # contatore caratteri
            .byte 0
        pt:                                                         # prodotto temporaneo per scambi di posizioni in base all algoritmo scelto
            .ascii "00,00,00,00"
        p0:
            .ascii "00,00,00,00"
        p1:
            .ascii "00,00,00,00"
        p2:
            .ascii "00,00,00,00"
        p3:
            .ascii "00,00,00,00"
        p4:
            .ascii "00,00,00,00"
        p5:
            .ascii "00,00,00,00"
        p6:
            .ascii "00,00,00,00"
        p7:
            .ascii "00,00,00,00"
        p8:
            .ascii "00,00,00,00"
        p9:
            .ascii "00,00,00,00"


.section .bss                                                       # Variabili non inizializzate
    first_parameter_buffer:
        .skip 256                                                   # Define a buffer to store the parameter name
    second_parameter_buffer:                                        
        .skip 256                                                   # Define a buffer to store the parameter name

.section .text                                                      # Istruzioni
    .align 4                                                        # allinea l'indirizzo di memoria di una determinata istruzione o dato. Questa direttiva e utile per garantire che i dati o le istruzioni siano posizionati su confini di memoria specifici, ad esempio su limiti di parole o di dword.
    .global _start

copy_string:                                                        # Copia la stringa nome di un parametro e la salva nel corrispettivo buffer
    movl $0, %ecx                                                   # Svuota il registro ECX
    loop_start:                                 
        movb (%esi,%ecx), %al                                       # Carica un byte dal nome del parametro in AL (ESI + offset da ECX in AL)
        cmp $0, %al                                                 # Verifica se il byte e \0
        je loop_end                                                 # se e \0 termina il loop
        movb %al, (%edi,%ecx)                                       # copia il byte da AL al buffer
        inc %ecx                                                    # incrementa il registro contatore ECX
        jmp loop_start                                              # ripete il loop
    loop_end:
        ret

file_open_input:                                                    # Tenta di aprire il file, in caso di errore lo comunica a video e termina il programma
    movl $5, %eax                                                   # Syscall OPEN
    movl $first_parameter_name, %ebx                                # Nome del file di input
    movl $0, %ecx                                                   # Modalità di apertura (O_RDONLY)
    int $0x80                                                       # Interruzione del kernel
    cmp $0, %eax                                                    # In caso di errore nel file
    jl file_open_error                                              # salta all etichetta di errore
    movl %eax, fd                                                   # Salva il file descriptor in EBX
    ret


file_open_output:                                                   # Tenta di aprire il file, in caso di errore lo comunica a video e termina il programma
    movl $5, %eax                                                   # Syscall OPEN
    movl $second_parameter_name, %ebx                               # Nome del file di output
    movl $2, %ecx                                                   # Modalità di apertura (O_RDONLY)
    int $0x80                                                       # Interruzione del kernel
    cmp $0, %eax                                                    # In caso di errore nel file
    jl file_open_error                                              # salta all etichetta di errore
    movl %eax, fd                                                   # Salva il file descriptor in EBX

    # Chiude il file per poterlo svuotare (in caso contenesse qualcosa)
        movl $6, %eax                                               # Numero di chiamata di sistema per CLOSE 
        movl %eax, %ebx                                             # File descriptor del file aperto
        int $0x80                                                   # Invia la chiamata di sistema

    # Svuota il file utilizzando la chiamata di sistema "TRUNCATE"
        movl $92, %eax                                              # Numero di chiamata di sistema per TRUNCATE 
        movl second_parameter_name, %ebx                            # Indirizzo della stringa del nome del file
        xorl %ecx, %ecx                                             # Imposta la dimensione del file a zero
        int $0x80                                                   # Invia la chiamata di sistema
    
    ret


file_open_error:                                                    # Feedback e breakpoint in caso di errore apertura file    
    movl $4, %eax                                                   # carica 4 in EAX (4 = codice system call WRITE)
    movl $1, %ebx                                                   # carica 1 in EBX (indica la scrittura nello Standard Output)
    leal file_open_error_string, %ecx                               # carica in ECX l'indirizzo al nome della stringa da stampare
    leal file_open_error_string_len, %edx                           # carica in EDX la lunghezza della stringa da stampare
    int $0x80                                                       # esegue la system call WRITE
    movl $1, %eax                                                   # Mette a 1 il registro EAX (codice della system call exit)
    xorl %ebx, %ebx                                                 # azzera EBX (codice di ritorno della exit)
    int $0x80                                                       # esegue la system call exit


file_read_error:                                                    # Feedback e breakpoint in caso di errore lettura file    
    movl $4, %eax                                                   # carica 4 in EAX (4 = codice system call WRITE)
    movl $1, %ebx                                                   # carica 1 in EBX (indica la scrittura nello Standard Output)
    leal file_read_error_string, %ecx                               # carica in ECX l'indirizzo al nome della stringa da stampare
    leal file_read_error_string_len, %edx                           # carica in EDX la lunghezza della stringa da stampare
    int $0x80                                                       # esegue la system call WRITE
    movl $1, %eax                                                   # Mette a 1 il registro EAX (codice della system call exit)
    xorl %ebx, %ebx                                                 # azzera EBX (codice di ritorno della exit)
    int $0x80                                                       # esegue la system call exit


file_close:                                                         # Chiude il file senza chiudere il programma
        movl $6, %eax                                               # Syscall CLOSE
        movl %ebx, %ecx                                             # File descriptor
        int $0x80                                                   # Interruzione del kernel
        ret


_start:
    # legge il numero di parametri (Parte facoltativa)
        movl %esp, %ebp                                             # Salva una copia di ESP in EBP per poter modificare ESP.
                                                                    # ESP contiene l'indirizzo della locazione dove si trova il numero di argomenti passati
        cmp %esp, 2                                                 # Verifica se e stato inserito un solo parametro
        je no_output_export                                         # Nel caso venga inserito un solo parametro (oltre al nome del programma) salta alla etichetta corrispondente
        
        movl $'2', %al                                              # Carica il carattere '2' in AL
        movl $output_export, %ebx                                   # Carica l'indirizzo di "output_export" in EBX
        movb %al, (%ebx)                                            # Salva il nuovo carattere nell'indirizzo di "output_export" puntato da EBX

    # Copia il nome del primo parametro nel primo buffer        
        movl $first_parameter_name, %esi                            # Carica l'indirizzo del nome del primo parametro nel registro ESI
        movl $first_parameter_buffer, %edi                          # Carica l'indirizzo del primo buffer in EDI
        call copy_string                                            # Chiama la funzione per copiare la stringa

    # Copia il nome del secondo parametro nel secondo buffer
        movl $second_parameter_name, %esi                           # Carica l'indirizzo del nome del secondo parametro nel registro ESI
        movl $second_parameter_buffer, %edi                         # Carica l'indirizzo del secondo buffer in EDI
        call copy_string                                            # Chiama la funzione per copiare la stringa
        jmp output_export                                           # Salta la parte relativa all opzione a 2 parametri

        no_output_export:                                           # Copia il nome del parametro nel primo buffer
            movl $first_parameter_name, %esi                        # Carica l'indirizzo del nome del parametro nel registro ESI
            movl $first_parameter_buffer, %edi                      # Carica l'indirizzo del suo buffer in EDI
            call copy_string                                        # Chiama la funzione per copiare la stringa

        output_export:
            call file_open_input                                    # Chiama la funzione per aprire il file


    # Salva l'ordine presente nel file nelle corrispettive variabili (p0 - p9)
        storing_loop:
             movl $3, %eax                                          # syscall READ
             movl fd, %ebx                                          # File descriptor
             movl $file_read_buffer, %ecx                           # Buffer di input
             movl $1, %edx                                          # Lunghezza massima
            int $0x80                                               # Interruzione del kernel
            cmp $0, %eax                                            # Controllo se ci sono errori o EOF
            jl file_read_error                                      # Se minore di 0 ci sono errori
            je storing_EOF                                          # Se uguale a 0 allora EOF
        
        # Controllo se ho una newline
            movb file_read_buffer, %al                              # copio il carattere dal buffer ad AL
            cmpb newline, %al                                       # confronto AL con il carattere \n
            je newline_found                                        # se sono uguali salto a "newline_found"
            incw char_c                                             # incremento il contatore di offset (char_c)        
            jmp storing_loop                                        # salto all'inizio del loop (storing_loop) per gestire il prossimo carattere

            newline_found:
                incw pn                                             # incremento il contatore dei prodotti
                movb $0, char_c                                     # azzero il contatore di offset
                jmp storing_loop                                    # salto all'inizio del loop (storing_loop) per gestire il prossimo carattere

    storing_EOF:
        call file_close

    repeat:
    # Chiede che tipo di algoritmo utillizzare tra EDF e HPF
        movl $4, %eax                                               # carica 4 in EAX (4 = codice system call WRITE)
        movl $1, %ebx                                               # carica 1 in EBX (indica la scrittura nello Standard Output)
        leal ask_algorithm_mode_string, %ecx                        # carica in ECX l'indirizzo al nome della stringa da stampare
        leal ask_algorithm_mode_string_len, %edx                    # carica in EDX la lunghezza della stringa da stampare
        int $0x80                                                   # esegue la system call WRITE

    # Legge la scelta inserita dall utente   
         movl $0, %ebx                                              # File descriptor 0 corrisponde all'input standard (stdin)
        lea ask_algorithm_mode_buffer, %ecx                                          # Indirizzo del buffer
         movl $1, %edx                                              # Numero massimo di byte da leggere (1 byte)

         movl $3, %eax                                              # Chiamata di sistema per leggere input (syscall number 3 per x86)
        int $0x80                                                   # Interruzione del kernel per eseguire la chiamata di sistema

    # Verifica se il carattere letto e '1' o '2'
        cmpb $'1', (%ecx)                                           # Confronta il byte letto con '1'
        je EDF                                                      # Se e '1' salta ad EDF
        cmpb $'2', (%ecx)                                           # Confronta il byte letto con '2'
        je HPF                                                      # Se e '2' salta ad HPF

        cmpb $'1', output_export
        jne open_output_file
        jmp no_output_file
        open_output_file:
            call file_open_output
        no_output_file:

    EDF:
        EDF_product_read_loop:                                      # Legge il file riga per riga
            movl $3, %eax                                           # Syscall READ
            movl fd, %ebx                                           # File descriptor
            movl $file_read_buffer, %ecx                            # Buffer di input
            movl $1, %edx                                           # Lunghezza massima
            int $0x80                                               # Interruzione del kernel
            cmp $0, %eax                                            # Controllo se ci sono errori o EOF
            jl file_read_error                                      # Se minore di 0 ci sono errori
            je storing_EOF                                          # Se uguale a 0 allora EOF

        EDF_newline_check:                      
            movb file_read_buffer, %al                              # copio il carattere dal buffer ad AL
            cmpb newline, %al                                       # confronto AL con il carattere \n
            jne comma_check                                         # se sono diversi salto al controllo della virgola
            incw lines                                              # altrimenti incremento il contatore

        EDF_comma_check:                        
            cmpb comma, %al                                         # confronto AL con il carattere della virgola
            incw lines                                              # altrimenti incremento il contatore

        call file_close                                             # finite le operazioni dell algoritmo chiama "file_close" per chiudere il file     
        

    HPF:
        HPF_product_read_loop:                                      # Legge il file riga per riga
            movl $3, %eax                                           # Syscall READ
            movl fd, %ebx                                           # File descriptor
            movl $file_read_buffer, %ecx                            # Buffer di input
            movl $1, %edx                                           # Lunghezza massima
            int $0x80                                               # Interruzione del kernel
            cmp $0, %eax                                            # Controllo se ci sono errori o EOF
            jl file_read_error                                      # Se minore di 0 ci sono errori
            je storing_EOF                                          # Se uguale a 0 allora EOF

        HPF_newline_check:                      
            movb file_read_buffer, %al                              # copio il carattere dal buffer ad AL
            cmpb newline, %al                                       # confronto AL con il carattere \n
            jne comma_check                                         # se sono diversi salto al controllo della virgola
            incw lines                                              # altrimenti incremento il contatore

        HPF_comma_check:                        
            cmpb comma, %al                                         # confronto AL con il carattere della virgola
            incw lines                                              # altrimenti incremento il contatore








    # Dopo aver dato i risultati dell algoritmo selezionato ritorna alla scelta dell algoritmo
        jmp repeat