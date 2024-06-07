.section .data      # sezione variabili globali
inizio:                 # etichetta
        .ascii "Inserisci algoritmo di ordinammento: \n1 EDF\n2HPF\n"
    
inizio_len:
        .long . - inizio

.section .bss
buffer: 
        .byte

.section .text
      .global _start  
    
_start:
    movl $4, %eax
    movl $1, %ebx
    leal inizio, %ecx
    movl inizio_len, %edx
    
    int $0x80

    movl $3, %eax
    movl $0, %ebx
    leal buffer, %ecx
    movl $1, %edx
    
    int $0x80  
    
    movl $4, %eax
    movl $1, %ebx
    leal buffer, %ecx
    movl $1, %edx
    
    int $0x80


    movl $1,%eax       # exit
    xorl %ebx,%ebx  # mettere a 0 il registro

    int $0x80