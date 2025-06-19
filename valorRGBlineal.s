.section .text
    .global valorRGBlineal
    .extern pow


valorRGBlineal:
   
    movsd umbral(%rip), %xmm1     
    comisd %xmm1, %xmm0           
    jb menor                      

    movsd const_0055(%rip), %xmm1 
    addsd %xmm1, %xmm0           
    movsd const_1055(%rip), %xmm1 
    divsd %xmm1, %xmm0            

    movsd const_24(%rip), %xmm1   
    call pow                      
    ret

menor:
    movsd const_1292(%rip), %xmm1 
    divsd %xmm1, %xmm0            
    ret

.section .rodata
umbral: .double 0.04045
const_0055: .double 0.055
const_1055: .double 1.055
const_24: .double 2.4
const_1292: .double 12.92

