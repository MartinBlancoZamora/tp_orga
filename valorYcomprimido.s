.section .text
    .global valorYcomprimido
    .extern pow


valorYcomprimido:
 
    movsd umbral(%rip), %xmm1
    comisd %xmm1, %xmm0 
    jb .menor 

    
    movsd const_inv24(%rip), %xmm1 
    call pow           

    movsd const_1055(%rip), %xmm1
    mulsd %xmm1, %xmm0      

    movsd const_0055(%rip), %xmm1
    subsd %xmm1, %xmm0      
    ret

.menor:
    movsd const_1292(%rip), %xmm1
    mulsd %xmm1, %xmm0      
    ret

.section .rodata
umbral:          .double 0.0031308
const_0055:      .double 0.055
const_1055:      .double 1.055
const_1292:      .double 12.92
const_inv24:     .double 0.4166666666666667 
