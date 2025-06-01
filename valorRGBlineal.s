section .text
    global valorRGBlineal
    extern pow

; double valorRGBlineal(double RGBcomprimido)
valorRGBlineal:
    ; xmm0 = RGBcomprimido
    ; Comparar xmm0 < 0.04045
    movsd xmm1, qword [umbral]
    comisd xmm0, xmm1
    jb .menor ; si xmm0 < 0.04045, saltar a .menor

    ;else: (x + 0.055) / 1.055 → pow(resultado, 2.4)
    movsd xmm1, qword [const_0055]
    addsd xmm0, xmm1   ; xmm0 = x + 0.055
    movsd xmm1, qword [const_1055]
    divsd xmm0, xmm1  ; xmm0 = (x + 0.055) / 1.055

    movsd xmm1, qword [const_24] ; xmm1 = 2.4
    call pow           ; xmm0 = pow(xmm0, xmm1)
    ret

.menor:
    movsd xmm1, qword [const_1292]
    divsd xmm0, xmm1   ; xmm0 = x / 12.92
    ret

section .rodata
umbral: dq 0.04045
const_0055: dq 0.055
const_1055: dq 1.055
const_24: dq 2.4
const_1292: dq 12.92
