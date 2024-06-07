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
        export_value:      
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
              .long . - ask_algorithm_mode_string                   # lunghezza della stringa in byte
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
        comma_c:                                                    # contatore virgole          
            .byte 0
        pt:                                                         # prodotto temporaneo per scambi di posizioni in base all algoritmo scelto
            .ascii "00,00,00,00"

        # prodotti letti    
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

        # prodotti ordinati
            p0_ord:
                .ascii "00,00,00,00"
            p1_ord:
                .ascii "00,00,00,00"
            p2_ord:
                .ascii "00,00,00,00"
            p3_ord:
                .ascii "00,00,00,00"
            p4_ord:
                .ascii "00,00,00,00"
            p5_ord:
                .ascii "00,00,00,00"
            p6_ord:
                .ascii "00,00,00,00"
            p7_ord:
                .ascii "00,00,00,00"
            p8_ord:
                .ascii "00,00,00,00"
            p9_ord:
                .ascii "00,00,00,00"

        # deadline prodotti
            p0_dl:
                .byte 100
            p1_dl:
                .byte 100
            p2_dl:
                .byte 100
            p3_dl:
                .byte 100
            p4_dl:
                .byte 100
            p5_dl:
                .byte 100
            p6_dl:
                .byte 100
            p7_dl:
                .byte 100
            p8_dl:
                .byte 100
            p9_dl:
                .byte 100

        # priority prodotti
            p0_pr:
                .byte 100
            p1_pr:
                .byte 100
            p2_pr:
                .byte 100
            p3_pr:
                .byte 100
            p4_pr:
                .byte 100
            p5_pr:
                .byte 100
            p6_pr:
                .byte 100
            p7_pr:
                .byte 100
            p8_pr:
                .byte 100
            p9_pr:
                .byte 100
            

    # variabili necessarie agli algoritmi
        time_c:                                                     # valore degli slot temporali
            .byte 0
        penality:                                                   # valore di penalita
            .byte 0
        extra_time:                                                 # tempo di eccesso che porta a penalita
            .byte 0


.section .bss                                                       # Variabili non inizializzate
    first_parameter_buffer:
        .skip 256                                                   # Define a buffer to store the parameter name
    second_parameter_buffer:                                        
        .skip 256                                                   # Define a buffer to store the parameter name

.section .text                                                      # Istruzioni
    .align 4                                                        # allinea l'indirizzo di memoria di una determinata istruzione o dato. Garantisce che i dati o le istruzioni siano posizionati su confini di memoria specifici (limiti di parole o di dword)
    .global _start

copy_string:                                                        # Copia la stringa nome di un parametro e la salva nel corrispettivo buffer
    movl $0, %ecx                                                   # Svuota il registro ECX
    loop_start:                                 
        movb (%esi,%ecx), %al                                       # Carica un byte dal nome del parametro in AL (ESI + offset da ECX in AL)
        cmp $0, %al                                                 # Verifica se il byte e \0
        je loop_end                                                 # se e \0 termina il loop
        movb %al, (%edi,%ecx)                                       # copia il byte da AL al buffer
        incl %ecx                                                   # incrementa il registro contatore ECX
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
    movl $1, %ecx                                                   # Modalità di apertura (O_WDONLY)
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
        
        movb $'2', %al                                              # Carica il carattere '2' in AL
        movl $export_value, %ebx                                    # Carica l'indirizzo di "export_value" in EBX
        movb %al, (%ebx)                                            # Salva il nuovo carattere nell'indirizzo di "export_value" puntato da EBX

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
            movl $3, %eax                                           # syscall READ
            movl fd, %ebx                                           # File descriptor
            movl $file_read_buffer, %ecx                            # Buffer di input
            movl $1, %edx                                           # Lunghezza massima
            int $0x80                                               # Interruzione del kernel
            cmp $0, %eax                                            # Controllo se ci sono errori o EOF
            jl file_read_error                                      # Se minore di 0 ci sono errori
            je storing_EOF                                          # Se uguale a 0 allora EOF
        
        # Controllo se ho una newline
            movb file_read_buffer, %al                              # copio il carattere dal buffer ad AL
            cmpb newline, %al                                       # confronto AL con il carattere \n
            je newline_found                                        # se sono uguali salto a "newline_found"
   
            movl char_c, %ecx                                       # salvo il valore di offset in ECX
            leal p0, %edi                                           # salvo il valore dell indirizzo base del primo prodotto al quale applicare un offset
            addl %ecx, %edi                                         # sommo l offset all indirizzo base del primo prodotto
            movb %al, (%edi)                                        # salvo il contenuto di %AL nell indirizzo ottentuto
            incw char_c                                             # incremento il contatore di offset (char_c)     
            jmp storing_loop                                        # salto all inizio del loop (storing_loop) per gestire il prossimo carattere

            newline_found:
                incw pn                                             # incremento il contatore dei prodotti    
                movl char_c, %ecx                                   # salvo il valore di offset in ECX
                leal p0, %edi                                       # salvo il valore dell indirizzo base del primo prodotto al quale applicare un offset
                addl %ecx, %edi                                     # sommo l offset all indirizzo base del primo prodotto
                movl $0, (%edi)                                     # salvo il null operator nell indirizzo ottentuto (per chiudere in anticipo la stringa in caso fosse piu corta)

                # Aggiunta offset per mantenere il corretto valore di offset alla base del prossimo prodotto
                    movl char_c+1, %eax                             # salvo il valore della variabile di offset incrementata di 1 in EAX
                    movl $12, %ebx                                  # salvo il valore del divisore necessario in EBX
                    xorl %edx, %edx                                 # azzero EDX per non avere risultati sfalsati
                    offset_loop:
                        divl %ebx                                   # divido EBX per EAX e salvo il valore del resto in EDX
                        cmp $0, %edx                                # verifico se è un multiplo nel caso il resto fosse ZERO
                        jz no_offset                                # nel caso fosse ZERO non sara necessario aggiungere offset (salto a no_offset)
                        incw char_c                                 # nel caso fosse diverso da ZERO incremento la variabile di offset e ricomincio saltando a "offset_loop"
                        jmp offset_loop
                    no_offset:
                
                addl $2, char_c                                     # incremento di 2 il contatore di offset (char_c) (+1 per newline +1 per nuovo char)            
                jmp storing_loop                                    # salto all'inizio del loop (storing_loop) per gestire il prossimo carattere

    storing_EOF:
        # Operazione necessaria per chiudere l'ultima stringa prodotto
            movl char_c, %ecx                                       # salvo il valore di offset in ECX
            leal p0, %edi                                           # salvo il valore dell indirizzo base del primo prodotto al quale applicare un offset
            addl %ecx, %edi                                         # sommo l offset all indirizzo base del primo prodotto
            movl $0, (%edi)                                         # salvo il null operator nell indirizzo ottentuto (per chiudere in anticipo la stringa in caso fosse piu corta)
            call file_close

        # verifica di correttezza dell algoritmo di salvataggio dei dati
            movl [char_c+1], %eax                                   # salvo il valore della variabile di offset incrementata di 1 in EAX
            movl pn, %ebx                                           # salvo il valore del divisore necessario (numero di prodotti nella lista Ordini) in EBX
            xorl %edx, %edx                                         # azzero EDX per non avere risultati sfalsati
            divl %ebx                                               # divido EBX per EAX e salvo il valore del resto in EDX
            cmp $0, %edx                                            # verifico se è un multiplo nel caso il resto fosse ZERO
            jz no_errors                                            
                call exit                                           # nel caso non fosse ZERO significa che ci sono errori nell algoritmo quindi esce dal programma
            no_errors:                                              # nel caso fosse ZERO significa che non ci sono errori nell algoritmo


    # Salvataggio durata, deadline e priority
        leal p0, %ebx                                               # Salvo l indirizzo base del primo prodotto in EBX (char_c)
        xorb %dl, %dl                                               # Azzera il registro che conta le virgole trovate (comma_c)
        xorb %dh, %dh                                               # Azzera il registro che conta i prodotti elaborati (p)

        find_duration_time:
            movb (%ebx), %al                                        # Carica il byte dall'indirizzo puntato da EBX in AL 
            cmpb comma, %al                                         # Comma check
            xorb %al, %al                                           # svuoto AL per pulizia
            jne comma_not_found1    
            incb %dl                                                # Trovata una virgola incrementa il contatore DL (necessario per capire quando si stanno leggendo i dati voluti)
            comma_not_found1:                                       # Altrimenti non incrementa il contatore della virgola e continua
                incl %ebx                                           # incrementa il valore d'indirizzo del puntatore per passare al prossimo valore della stringa
            cmpb $1, %dl                                            # se e stata trovata una virgola significa che il valore dopo la prima virgola e il primo valore della durata
            jne find_duration_time                                  # nel caso non si siano raggiunte le 2 virgole torna su

            # Converte il valore di durata da carattere a valore numerico
                movb $10, %al                                       # moltiplicatore
                movb (%ebx), %ah                                    # salvo in AH il valore in byte puntato dal contatore di stringa presente in EBX
                subb $'0', %ah                                      # converto il carattere presente in AH nel valore numerico corrispondente
                incl %ebx
                movb (%ebx), %cl                                    # Carica il byte dall'indirizzo puntato da EBX+1 in CL 
                decl %ebx
                cmpb comma, %cl                                     # verifico se il prossimo valore e una virgola
                je comma_found                                      # se e una virgola salta a "comma_found"
                mul %ah                                             # moltiplico AH per 10 (risultato in AX (ma sta tutto in AL) )
                subb $'0', %cl                                      # converto il carattere presente in CH nel valore numerico corrispondente
                addb %cl, %al                                       # sommo al moltiplicato il valore del carattere successivo convertito in valore numerico

                xorb %ch, %ch                                       # svuoto CH per pulizia
                xorb %cl, %cl                                       # svuoto CL per pulizia
                comma_found:

            # Salva il valore numerico della durata nella variabile corrispondente
                leal p0_dl, %esi                                    # salva l'indirizzo della base della deadline del primo prodotto in esi
                movb %al, (%esi)                                    # salva il valore di deadline precedentemente ottenuto nell indirizzo puntato da ESI
                addl $8, %esi                                       # sommo 8 alla base della deadline in modo da passare alla seconda variabile di deadline
                xorb %al, %al                                       # svuoto AL per pulizia

        

        find_deadline_value:  
            movb (%ebx), %al                                        # Carica il byte dall'indirizzo puntato da EBX in AL 
            cmpb comma, %al                                         # Comma check
            xorb %al, %al                                           # svuoto AL per pulizia
            jne comma_not_found2    
            incb %dl                                                # Trovata una virgola incrementa il contatore DL (necessario per capire quando si stanno leggendo i dati voluti)
            comma_not_found2:                                       # Altrimenti non incrementa il contatore della virgola e continua
                incl %ebx                                           # incrementa il valore d'indirizzo del puntatore per passare al prossimo valore della stringa
            cmpb $2, %dl                                            # se sono state trovate 2 virgole significa che il valore dopo la seconda virgola e il primo valore della deadline
            jne find_deadline_value                                 # nel caso non si siano raggiunte le 2 virgole torna su

            # Converte il valore di deadline da carattere a valore numerico
                movb $10, %al                                       # moltiplicatore
                movb (%ebx), %ah                                    # salvo in AH il valore in byte puntato dal contatore di stringa presente in EBX
                subb $'0', %ah                                      # converto il carattere presente in AH nel valore numerico corrispondente
                incl %ebx
                movb (%ebx), %cl                                    # Carica il byte dall'indirizzo puntato da EBX+1 in CL 
                decl %ebx
                cmpb comma, %cl                                     # verifico se il prossimo valore e una virgola
                je comma_found                                      # se e una virgola salta a "comma_found"
                mul %ah                                             # moltiplico AH per 10 (risultato in AX (ma sta tutto in AL) )
                subb $'0', %cl                                      # converto il carattere presente in CH nel valore numerico corrispondente
                addb %cl, %al                                       # sommo al moltiplicato il valore del carattere successivo convertito in valore numerico

                xorb %ch, %ch                                       # svuoto CH per pulizia
                xorb %cl, %cl                                       # svuoto CL per pulizia
                comma_found:

            # Salva il valore numerico della deadline nella variabile corrispondente
                leal p0_dl, %esi                                    # salva l'indirizzo della base della deadline del primo prodotto in esi
                movb %al, (%esi)                                    # salva il valore di deadline precedentemente ottenuto nell indirizzo puntato da ESI
                addl $8, %esi                                       # sommo 8 alla base della deadline in modo da passare alla seconda variabile di deadline
                xorb %al, %al                                       # svuoto AL per pulizia

        find_priority_value:
            movb (%ebx), %al                                        # Carica il byte dall'indirizzo puntato da EBX in AL
            cmpb comma, %al                                         # Comma check
            xorb %al, %al                                           # svuoto AL per pulizia
            jne comma_not_found3            
            incb %dl                                                # Trovata una virgola incrementa il contatore DL (necessario per capire quando si stanno leggendo i dati voluti)
            comma_not_found3:                                       # Altrimenti non incrementa il contatore della virgola e continua
                incl %ebx                                           # incrementa il valore d'indirizzo del puntatore per passare al prossimo valore della stringa
            cmpb $3, %dl                                            # se sono state trovate 3 virgole significa che il valore dopo la terza virgola e il valore della priority
            jne find_priority_value                                 # nel caso non si siano raggiunte le 3 virgole torna su

            # Converte il valore della priority da carattere a valore numerico
                movb (%ebx), %ah                                    # salvo in AH il valore in byte puntato dal contatore di stringa presente in EBX
                subb $'0', %ah                                      # converto il carattere presente in AH nel valore numerico corrispondente

            # Salva il valore numerico della priority nella variabile corrispondente
                leal p0_pr, %edi                                    # salva l'indirizzo della base della priority del primo prodotto in EDI
                movb %ah, (%edi)                                    # salva il valore di priority precedentemente ottenuto nell indirizzo puntato da EDI
                addl $8, %esi                                       # sommo 8 alla base della priority in modo da passare alla seconda variabile di priority
                xorb %ah, %ah                                       # svuoto AH per pulizia

            # Gestione flag loop    
                addl $2, %ebx                                       # imposta l indirizzo puntatore sulla base del prodotto successivo (+1 salta il carattere priority +1 salta il carattere '\0')
                xorb %dl, %dl                                       # svuoto DL per azzerare il contatore virgole per il prossimo ciclo
                incb %dh                                            # incrementa il registro che conta i prodotti gestiti
                cmpb pn, %dh                                        # verifica se sono stati gestiti tutti i prodotti
                jle find_deadline_value                             # in caso contrario torna su

            # Pulizia registri
                xorl %ebx, %ebx
                xorl %edx, %edx
                xorl %esi, %esi
                xorl %edi, %edi




    repeat:
        # Chiede che tipo di algoritmo utillizzare tra EDF e HPF
            movl $4, %eax                                           # carica 4 in EAX (4 = codice system call WRITE)
            movl $1, %ebx                                           # carica 1 in EBX (indica la scrittura nello Standard Output)
            leal ask_algorithm_mode_string, %ecx                    # carica in ECX l'indirizzo al nome della stringa da stampare
            leal ask_algorithm_mode_string_len, %edx                # carica in EDX la lunghezza della stringa da stampare
            int $0x80                                               # esegue la system call WRITE

        # Legge la scelta inserita dall utente   
            movl $0, %ebx                                           # File descriptor 0 corrisponde all'input standard (stdin)
            leal ask_algorithm_mode_buffer, %ecx                    # Indirizzo del buffer
            movl $1, %edx                                           # Numero massimo di byte da leggere (1 byte)
    
            movl $3, %eax                                           # Chiamata di sistema per leggere input (syscall number 3 per x86)
            int $0x80                                               # Interruzione del kernel per eseguire la chiamata di sistema

        # Verifica se il carattere letto e '1' o '2'
            cmpb $'1', (%ecx)                                       # Confronta il byte letto con '1'
            je EDF                                                  # Se e '1' salta ad EDF
            cmpb $'2', (%ecx)                                       # Confronta il byte letto con '2'
            je HPF                                                  # Se e '2' salta ad HPF

            cmpb $'1', output_export
            jne open_output_file
            jmp no_output_file
            open_output_file:
                call file_open_output
            no_output_file:


        EDF:


        HPF:



        # Dopo aver dato i risultati dell algoritmo selezionato ritorna alla scelta dell algoritmo
            jmp repeat

exit:
    movl $1, %eax                                                   # Syscall EXIT
    xorl %ebx, %ebx                                                 # Exit status code 0
    int $0x80                                                       # Chiama la syscall  