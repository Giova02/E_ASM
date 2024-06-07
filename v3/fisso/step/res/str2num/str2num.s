# per convertire i caratteri in numero si utilizza la formula ricorsiva
#
# 10*( 10*( 10*d + d ) + d ) + d
#             N-1 N-2   N-3   N-4
#


.section .data

product_n:
  .byte 0

buffer:
  .ascii "27,9,40,3\n103,7,20,2\n3,4,12,3\n12,2,3,1\0"

saved_addr:
  .int 0

.section .bss
  gdb:
    .zero 1

  saved:
    .zero 4
  

.section .text
  .global _start

_start:

BUFFERtoDATA:

  movl $saved, saved_addr
  leal buffer, %ecx

BUFFERtoDATA_loop:
  xorl %ebx, %ebx
  movb (%ecx), %bl

  cmpb $',', %bl            # vedo se e' stato letto il carattere ','
  je BUFFERtoDATA_comma

  cmpb $10, %bl             # vedo se e' stato letto il carattere '\n'
  je BUFFERtoDATA_nl

  cmpb $0, %bl              # vedo se e' stato letto il carattere '\0'
  je BUFFERtoDATA_end

  subb $48, %bl             # converte il codice ASCII della cifra nel numero corrisponente
  movl $10, %edx
  mulb %dl
  addb %bl, %al

  inc %ecx
  jmp BUFFERtoDATA_loop

BUFFERtoDATA_comma:
  movl saved_addr, %ebx
  movb %al, (%ebx)
  incl saved_addr
  jmp BUFFERtoDATA_inc

BUFFERtoDATA_nl:
  movl saved_addr, %ebx
  movb %al, (%ebx)
  incl saved_addr
  incb product_n
  jmp BUFFERtoDATA_inc

BUFFERtoDATA_inc:
  xorl %eax, %eax
  inc %ecx
  jmp BUFFERtoDATA_loop

BUFFERtoDATA_end:

  movl saved_addr, %ebx
  movb %al, (%ebx)

  movb -1(%ecx), %bl
  cmpb $10, %bl
  je BUFFERtoDATA_pni

  incb product_n

  jmp BUFFERtoDATA_pni
BUFFERtoDATA_pni:

exit:
  movl $3, %eax
  movl $0, %ebx
  leal gdb, %ecx
  movl $1, %edx
  int $0x80

  movl $1, %eax
  movl $0, %ebx
  int $0x80
