.section .text
    .global valorRGBlineal
    .extern pow

# Función: double valorRGBlineal(double RGBcomprimido)
valorRGBlineal:
    # xmm0 = RGBcomprimido
    # Comparar xmm0 < 0.04045
    movsd umbral(%rip), %xmm1     # Cargar el umbral (0.04045) en xmm1
    comisd %xmm1, %xmm0           # Comparar xmm0 con xmm1 (xmm0 < xmm1)
    jb menor                      # Si xmm0 < umbral, saltar a menor

    # sino (x + 0.055) / 1.055 → pow(resultado, 2.4)
    movsd const_0055(%rip), %xmm1 # xmm1 = 0.055
    addsd %xmm1, %xmm0            # xmm0 = xmm0 (RGBcomprimido) + 0.055
    movsd const_1055(%rip), %xmm1 # xmm1 = 1.055
    divsd %xmm1, %xmm0            # xmm0 = xmm0 / 1.055

    # Preparar argumentos para pow(xmm0, 2.4)
    # Ya tenemos el primer argumento en %xmm0
    movsd const_24(%rip), %xmm1   # Cargar 2.4 en xmm1 para el segundo argumento de pow
    
    # La pila no necesita ser alineada o modificada para pow aquí,
    # ya que los argumentos se pasan por registros XMM.
    call pow                      # xmm0 = pow(xmm0, xmm1)
    
    ret

menor:
    movsd const_1292(%rip), %xmm1 # xmm1 = 12.92
    divsd %xmm1, %xmm0            # xmm0 = xmm0 / 12.92
    ret

.section .rodata
umbral: .double 0.04045
const_0055: .double 0.055
const_1055: .double 1.055
const_24: .double 2.4
const_1292: .double 12.92

