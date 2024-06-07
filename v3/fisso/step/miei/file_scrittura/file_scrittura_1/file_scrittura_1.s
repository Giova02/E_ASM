.section .data
    filename_output:
        .ascii "Pianificazione.txt"
    fd_output:
        .int 0

message1:
    .ascii "Attività 1: Fare la spesa\n"
message1_len:
    .long . - message1


.section .text
    .globl _start

_start:
    # Apre o crea il file
    movl $5, %eax                           # Chiamata di sistema open
    movl $filename_output, %ebx             # Percorso del file
    movl $65, %ecx                          # Modalità di apertura (O_CREAT | O_WRONLY)
    movl $0644, %edx                        # Permessi del file (0644) (Permesso di lettura e scrittura per il proprietario, solo lettura per il gruppo e per gli altri utenti)
    int $0x80                               # Interruzione software per invocare la chiamata di sistema

    # Salva il file descriptor restituito
    movl %eax, fd_output                    # File descriptor in "fd_output"

    # Scrive nel file le 10 stringhe
    movl $4, %eax                           # Chiamata di sistema write
    movl fd_output, %ebx                    # File descriptor
    leal message1, %ecx                     # Buffer contenente il messaggio 1
    movl message1_len, %edx                 # Lunghezza del messaggio 1
    int $0x80                               # Interruzione software per invocare la chiamata di sistema

    # Chiude il file
    movl $6, %eax                           # Chiamata di sistema close
    movl fd_output, %ebx                    # File descriptor
    int $0x80                               # Interruzione software per invocare la chiamata di sistema

    # Termina il programma              
    movl $1, %eax                           # Numero della chiamata di sistema exit
    xorl %ebx, %ebx                         # Codice di uscita (0)
    int $0x80                               # Interruzione software per invocare la chiamata di sistema
