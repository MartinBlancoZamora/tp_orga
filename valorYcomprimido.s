.section .text
    .global valorYcomprimido
    .extern pow

# Función: double valorYcomprimido(double y)
valorYcomprimido:
    # xmm0 = y
    movsd umbral(%rip), %xmm1
    comisd %xmm1, %xmm0 
    jb .menor # if y < 0.0031308, saltar a menor

    # sino: 1.055 * pow(y, 1/2.4) - 0.055
    movsd const_inv24(%rip), %xmm1 # xmm1 = 1/2.4
    call pow           # pow(y, 1/2.4), resultado en xmm0

    movsd const_1055(%rip), %xmm1
    mulsd %xmm1, %xmm0      # xmm0 = 1.055 * pow(y, 1/2.4)

    movsd const_0055(%rip), %xmm1
    subsd %xmm1, %xmm0      # xmm0 = resultado - 0.055
    ret

.menor:
    movsd const_1292(%rip), %xmm1
    mulsd %xmm1, %xmm0      # xmm0 = y * 12.92
    ret

.section .rodata
umbral:          .double 0.0031308
const_0055:      .double 0.055
const_1055:      .double 1.055
const_1292:      .double 12.92
const_inv24:     .double 0.4166666666666667 # (1 / 2.4)