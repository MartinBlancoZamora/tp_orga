.section .text
    .global valorRGBlineal
    .extern pow


valorRGBlineal:
    push %rbp
    mov %rsp, %rbp

    movsd umbral(%rip), %xmm1     
    ucomisd %xmm1, %xmm0           
    jbe menor                      

    movsd const_0055(%rip), %xmm1 
    addsd %xmm1, %xmm0           
    movsd const_1055(%rip), %xmm1 
    divsd %xmm1, %xmm0            

    movsd const_24(%rip), %xmm1   
    sub $8, %rsp
    call pow
    add $8, %rsp
    jmp .fin

menor:
    movsd const_1292(%rip), %xmm1 
    divsd %xmm1, %xmm0            
    jmp .fin


.fin:
    leave
    ret
    
.section .rodata
umbral: .double 0.04045
const_0055: .double 0.055
const_1055: .double 1.055
const_24: .double 2.4
const_1292: .double 12.92
