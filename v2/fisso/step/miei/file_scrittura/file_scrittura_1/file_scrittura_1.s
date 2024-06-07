.section .data
filename:
    .asciz "Pianificazione.txt"

message1:
    .ascii "Attività 1: Fare la spesa\n"
message1_len:
    .long . - message1
    
message2:
    .ascii "Attività 2: Pulire la casa\n"
message2_len:
    .long . - message2

message3:
    .ascii "Attività 3: Studiare per l esame\n"
message3_len:
    .long . - message3
    
message4:
    .ascii "Attività 4: Fare una passeggiata\n"
message4_len:
    .long . - message4
    
message5:
    .ascii "Attività 5: Preparare la cena\n"
message5_len:
    .long . - message5
    
message6:
    .ascii "Attività 6: Guardare un film\n"
message6_len:
    .long . - message6
    
message7:
    .ascii "Attività 7: Allenarsi in palestra\n"
message7_len:
    .long . - message7
    
message8:
    .ascii "Attività 8: Leggere un libro\n"
message8_len:
    .long . - message8
    
message9:
    .ascii "Attività 9: Scrivere codice\n"
message9_len:
    .long . - message9
    
message10:
    .ascii "Attività 10: Fare una telefonata\n"
message10_len:
    .long . - message10
    

.section .text
    .globl _start

_start:
    # Apre o crea il file
    movl $5, %eax                           # Chiamata di sistema open
    movl $filename, %ebx                    # Percorso del file
    movl $0x42, %ecx                        # Modalità di apertura (O_CREAT | O_WRONLY)
    movl $0644, %edx                        # Permessi del file (0644)
    int $0x80                               # Interruzione software per invocare la chiamata di sistema

    # Salva il file descriptor restituito
    movl %eax, %edi                         # File descriptor restituito

    # Scrive nel file le 10 stringhe
    movl $4, %eax                           # Chiamata di sistema write
    movl %edi, %ebx                         # File descriptor
    movl $message1, %ecx                    # Buffer contenente il messaggio 1
    movl message1_len, %edx                 # Lunghezza del messaggio 1
    int $0x80                               # Interruzione software per invocare la chiamata di sistema

    movl $4, %eax                           # Chiamata di sistema write
    movl %edi, %ebx                         # File descriptor
    movl $message2, %ecx                    # Buffer contenente il messaggio 2
    movl message2_len, %edx                 # Lunghezza del messaggio 2
    int $0x80                               # Interruzione software per invocare la chiamata di sistema

    movl $4, %eax                           # Chiamata di sistema write
    movl %edi, %ebx                         # File descriptor
    movl $message3, %ecx                    # Buffer contenente il messaggio 1
    movl message3_len, %edx                 # Lunghezza del messaggio 1
    int $0x80                               # Interruzione software per invocare la chiamata di sistema

    movl $4, %eax                           # Chiamata di sistema write
    movl %edi, %ebx                         # File descriptor
    movl $message4, %ecx                    # Buffer contenente il messaggio 2
    movl message4_len, %edx                 # Lunghezza del messaggio 2
    int $0x80                               # Interruzione software per invocare la chiamata di sistema

    movl $4, %eax                           # Chiamata di sistema write
    movl %edi, %ebx                         # File descriptor
    movl $message5, %ecx                    # Buffer contenente il messaggio 2
    movl message5_len, %edx                 # Lunghezza del messaggio 2
    int $0x80                               # Interruzione software per invocare la chiamata di sistema

    movl $4, %eax                           # Chiamata di sistema write
    movl %edi, %ebx                         # File descriptor
    movl $message6, %ecx                    # Buffer contenente il messaggio 2
    movl message6_len, %edx                 # Lunghezza del messaggio 2
    int $0x80                               # Interruzione software per invocare la chiamata di sistema

    movl $4, %eax                           # Chiamata di sistema write
    movl %edi, %ebx                         # File descriptor
    movl $message7, %ecx                    # Buffer contenente il messaggio 2
    movl message7_len, %edx                 # Lunghezza del messaggio 2
    int $0x80                               # Interruzione software per invocare la chiamata di sistema

    movl $4, %eax                           # Chiamata di sistema write
    movl %edi, %ebx                         # File descriptor
    movl $message8, %ecx                    # Buffer contenente il messaggio 2
    movl message8_len, %edx                 # Lunghezza del messaggio 2
    int $0x80                               # Interruzione software per invocare la chiamata di sistema

    movl $4, %eax                           # Chiamata di sistema write
    movl %edi, %ebx                         # File descriptor
    movl $message9, %ecx                    # Buffer contenente il messaggio 2
    movl message9_len, %edx                 # Lunghezza del messaggio 2
    int $0x80                               # Interruzione software per invocare la chiamata di sistema

    movl $4, %eax                           # Chiamata di sistema write
    movl %edi, %ebx                         # File descriptor
    movl $message10, %ecx                   # Buffer contenente il messaggio 2
    movl message10_len, %edx                # Lunghezza del messaggio 2
    int $0x80                               # Interruzione software per invocare la chiamata di sistema


    # Chiude il file
    movl $6, %eax                           # Chiamata di sistema close
    movl %edi, %ebx                         # File descriptor
    int $0x80                               # Interruzione software per invocare la chiamata di sistema

    # Termina il programma              
    movl $1, %eax                           # Numero della chiamata di sistema exit
    xorl %ebx, %ebx                         # Codice di uscita (0)
    int $0x80                               # Interruzione software per invocare la chiamata di sistema
