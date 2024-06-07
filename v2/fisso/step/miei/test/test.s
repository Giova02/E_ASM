.section .data
buffer:
    .space 12  # Allocate 12 bytes for buffer (enough for 32-bit integer and null terminator)
newline:
    .asciz "\n"

.section .text
.globl _start
_start:
    movl $12345, %eax  # The number to be converted

    # Clear the buffer and set buffer length to 0
    xorl %ebx, %ebx  # EBX will be the buffer index
    movl $buffer, %ecx  # ECX points to the start of the buffer

    # Set up division by 10 without using ESI, EDI, ESP, or EBP
    movl $10, %edx   # Divisor 10

convert_loop:
    movl %eax, %edi  # Copy the number to EDI for division
    xorl %eax, %eax  # Clear EAX to prepare for division
    divl %edx        # Divide EDI by 10; quotient in EAX, remainder in EDX
    addb $'0', %dl   # Convert remainder to ASCII
    movb %dl, buffer(%ebx)  # Store ASCII character in buffer at position EBX
    incl %ebx        # Increment buffer index
    testl %edi, %edi # Check if quotient is zero
    jnz convert_loop # If not, continue loop

    # Null-terminate the string
    movb $0, buffer(%ebx)

    # Reverse the string
    xorl %edx, %edx  # EDX is the start index (0)
    decl %ebx        # EBX is the last index (length - 1)

reverse_loop:
    cmpl %edx, %ebx  # Compare start and end indices
    jle print_string # If start >= end, done reversing

    # Swap characters at start and end indices
    movb buffer(%edx), %al
    movb buffer(%ebx), %ah
    movb %ah, buffer(%edx)
    movb %al, buffer(%ebx)

    incl %edx        # Move start index forward
    decl %ebx        # Move end index backward
    jmp reverse_loop

print_string:
    # Calculate length of string
    subl %edx, %ebx  # Length of the string in EBX (original EBX value - start index)
    incl %ebx        # Correct length by adding 1

    # Print the string
    movl $4, %eax         # Syscall number for sys_write
    movl $1, %ecx         # File descriptor 1 (stdout)
    movl $buffer, %edx    # Pointer to buffer
    int $0x80             # Interrupt to invoke syscall

    # Print newline
    movl $4, %eax         # Syscall number for sys_write
    movl $1, %ecx         # File descriptor 1 (stdout)
    movl $newline, %edx   # Pointer to newline
    movl $1, %ebx         # Length of newline
    int $0x80             # Interrupt to invoke syscall

    # Exit program
    movl $1, %eax         # Syscall number for sys_exit
    xorl %ebx, %ebx       # Exit code 0
    int $0x80             # Interrupt to invoke syscall
