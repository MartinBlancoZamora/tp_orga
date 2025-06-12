section . text
    global procesarImagen
    extern valorRGBlineal
    extern valorYcomprimido

;int procesarImagen(uchar* p, int nRows, int nCols, int nChannels)
procesarImagen:
    push rbp
    mov rbp, rsp

    mov r8, rdi  ; p
    mov r9d, esi  ; nRows
    mov r10d, edx  ; nCols
    mov r11d, ecx  ; nChannels

    ;constantes
    movsd xmm15, qword [rel d_255]  ; xmm15 = 255.0

    xor r12d, r12d  ; i = 0

.fila_loop:
    cmp r12d, r9d
    jge .fin

    xor r13d, r13d  ; j = 0

.col_loop:
    cmp r13d, r10d
    jge .sig_fila

    ; offset = (i * nCols + j) * channels

    mov rax, r12d  ; eax = i
    imul rax, r10d  ; eax = i * nCols
    add rax, r13d  ; eax = i * nCols + j
    imul rax, r11d  ; eax = (i * nCols + j) * nChannels

    ;Leer valores uchar B,G,R (orden para OpenCV)

    ;B
    movzx edi, byte [r8 + rax]  ; edi = uchar B
    cvtsi2sd xmm0, edi  ; xmm0 = double(B)
    divsd xmm0, xmm15   ; xmm0 /= 255.0
    call valorRGBlineal  ; Blinear en xmm0
    movsd xmm1, xmm0    ; xmm1 = Blinear

    ; G
    movzx edi, byte [r8 + rax + 1] ; edi = uchar G
    cvtsi2sd xmm0, edi  ; xmm0 = double(G)
    divsd xmm0, xmm15    ; xmm0 /= 255.0
    call valorRGBlineal ; Glinear en xmm0
    movsd xmm2, xmm0    ; xmm2 = G linear

    ; R
    movzx edi, byte [r8 + rax + 2] ; edi = uchar R
    cvtsi2sd xmm0, edi  ; xmm0 = double(R)
    divsd xmm0, xmm15   ; xmm0 /= 255.0
    call valorRGBlineal ; Rlinear en xmm0
    movsd xmm3, xmm0   ; xmm3 = Rlinear

    ; Calculo de Ylineal
    ; Y = 0.2126 * R + 0.7152 * G + 0.0722 * B
    movsd xmm4, qword [rel cR]
    mulsd xmm4, xmm3    ; xmm4 = 0.2126 * R

    movsd xmm5, qword [rel cG]
    mulsd xmm5, xmm2    ; xmm5 = 0.7152 * G

    movsd xmm6, qword [rel cB]
    mulsd xmm6, xmm1    ; xmm6 = 0.0722 * B

    addsd xmm4, xmm5
    addsd xmm4, xmm6    ; xmm4 = Ylineal

    ; Comprimir Ylineal
    movsd xmn0, xmn4
    call valorYcomprimido; 

    ; Convertir a uchar y escribir en B, G, R
    mulsd xmm0, xmm15
    cvtsd2si edi, xmm0              ; convertir double a entero
    mov byte [r8 + rax], dil        ; B
    mov byte [r8 + rax + 1], dil    ; G
    mov byte [r8 + rax + 2], dil    ; R

    ; j += 1
    inc r13d
    jmp .col_loop

.sig_fila:
    inc r12d
    jmp .fila_loop


.fin:
    mov eax, 0
    pop rbp
    ret

section .rodata
d_255: dq 255.0
cR: dq 0.2126
cG: dq 0.7152
cB: dq 0.0722