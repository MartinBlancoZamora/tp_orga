section .text
    global valorYcomprimido
    extern pow

; double valorYcomprimido(double y)
valorYcomprimido:
    ; xmm0 = y
    movsd xmm1, qword [umbral]
    comisd xmm0, xmm1
    jb .menor ; if y < 0.0031308, saltar a menor

    ; else: 1.055 * pow(y, 1/2.4) - 0.055
    movsd xmm1, qword [const_inv24] ; xmm1 = 1/2.4
    call pow           ; pow(y, 1/2.4), resultado en xmm0

    movsd xmm1, qword [const_1055]
    mulsd xmm0, xmm1      ; xmm0 = 1.055 * pow(y, 1/2.4)

    movsd xmm1, qword [const_0055]
    subsd xmm0, xmm1      ; xmm0 = resultado - 0.055
    ret

.menor:
    movsd xmm1, qword [const_1292]
    mulsd xmm0, xmm1      ; xmm0 = y * 12.92
    ret

section .rodata
umbral:       dq 0.0031308
const_0055:   dq 0.055
const_1055:   dq 1.055
const_1292:   dq 12.92
const_inv24:  dq 0.4166666666666667 ; (1 / 2.4)