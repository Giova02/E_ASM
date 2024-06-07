.section .data
    itoa_digit:
        .byte 1

.section .bss
    buffer_itoa:
        .zero 3                         # Spazio per 3 caratteri da convertiti
    buffer_itoa_inv:
        .zero 1                         # byte temporeaneo per scambiare il primo carattere con l'ultimo

.section .text
.globl _start

_start:
    mov $135, %eax                      # Esempio di valore
    mov $buffer_itoa, %ebx              # Buffer per la conversione

    call itoa                           # Chiamata della funzione itoa ricorsiva
      
    movl $3, %eax
    movl $0, %ebx
    leal buffer_itoa_inv, %ecx
    movl $1, %edx
    int $0x80                           # Chiamata di sistema


    # Esempio di codice per uscita
    mov $1, %eax                        # Numero della syscall (sys_exit)
    mov $0, %ebx                        # Stato di uscita
    int $0x80                           # Chiamata di sistema


.type itoa, @function
itoa:
    movb $1, itoa_digit

itoa_loop:
    # Parametri: %eax = valore, %ebx = puntatore al buffer_itoa
    xorl %edx, %edx                     # pulisce EDX prima della divisione
    movl $10, %ecx                      # salva il divisore (10) in ECX
    divl %ecx                           # salva in EAX il risultato della divisione e il resto in EDX

    addb $'0', %dl                      # convertire resto in ASCII

    movb %dl, (%ebx)                    # scrive il carattere nel buffer_itoa
    incl %ebx                           # incrementa il puntatore al buffer_itoa

    cmpl $0, %eax                       # controllo se EAX è vuoto (funzione conclusa)
    je itoa_end         
    
    incb itoa_digit                     # incrementa il contatore di cifre
    jmp itoa_loop                       # Richiama ricorsivamente itoa_loop

itoa_end:
    cmpb $1, itoa_digit
    je itoa_end_no_inv

    leal buffer_itoa, %ebx
    movb (%ebx), %al
    movb %al, buffer_itoa_inv

    movb 2(%ebx), %al
    movb %al, (%ebx)
    
    movb buffer_itoa_inv, %al
    movb %al, 2(%ebx)
    
    cmpb $3, itoa_digit
    je itoa_end_no_inv

itoa_end_lshift:
    leal buffer_itoa, %ebx
    movb 1(%ebx), %al
    movb %al, (%ebx)
    movb 2(%ebx), %al
    movb %al, 1(%ebx)
    movb $0, 2(%ebx)

itoa_end_no_inv:
    ret

