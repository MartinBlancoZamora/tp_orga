
.section .text
    .global procesarImagen
    .extern valorRGBlineal
    .extern valorYcomprimido

/*
 * int procesarImagen(uchar* p, int nRows, int nCols, int nChannels)
 * Argumentos (x86-64 System V ABI):
 * %rdi: p (uchar*)
 * %esi: nRows (int32)
 * %edx: nCols (int32)
 * %ecx: nChannels (int32)
 */
procesarImagen:
    pushq   %rbp
    movq    %rsp, %rbp

    /* Guardar registros no volátiles que usaremos */
    pushq   %r12
    pushq   %r13

    /* Mover argumentos a registros de trabajo para preservarlos */
    movq    %rdi, %r8       /* %r8 = puntero base a la imagen (p) */
    movl    %esi, %r9d      /* %r9d = nRows */
    movl    %edx, %r10d     /* %r10d = nCols */
    movl    %ecx, %r11d     /* %r11d = nChannels */

    /* Cargar constantes de punto flotante */
    movsd   d_255(%rip), %xmm15

    xorl    %r12d, %r12d    /* i = 0 (contador de filas) */

.fila_loop:
    cmpl    %r9d, %r12d     /* Compara i con nRows */
    jge     .fin            /* si i >= nRows, salir */

    xorl    %r13d, %r13d    /* j = 0 (contador de columnas) */

.col_loop:
    cmpl    %r10d, %r13d    /* Compara j con nCols */
    jge     .sig_fila       /* si j >= nCols, siguiente fila */

    /* Calcular offset = (i * nCols + j) * nChannels */
    movl    %r12d, %eax     /* %eax = i */
    imull   %r10d, %eax     /* %eax = i * nCols */
    addl    %r13d, %eax     /* %eax = i * nCols + j */
    imull   %r11d, %eax     /* %eax = (i * nCols + j) * nChannels */
    movslq  %eax, %rax      /* Extender offset a 64 bits */

    /* Leer componentes B, G, R del píxel */
    /* B */
    movzbl  (%r8, %rax, 1), %ebx  /* Carga B en ebx (byte a long con extensión de cero) */
    cvtsi2sd %ebx, %xmm0           /* Convierte int a double */
    divsd   %xmm15, %xmm0         /* Normaliza: B / 255.0 */
    call    valorRGBlineal        /* Llama a la función. Resultado en %xmm0 */
    movsd   %xmm0, %xmm1          /* Guarda B_lineal en %xmm1 */

    /* G */
    movzbl  1(%r8, %rax, 1), %ebx /* Carga G en ebx */
    cvtsi2sd %ebx, %xmm0          /* Convierte int a double */
    divsd   %xmm15, %xmm0        /* Normaliza: G / 255.0 */
    call    valorRGBlineal
    movsd   %xmm0, %xmm2          /* Guarda G_lineal en %xmm2 */

    /* R */
    movzbl  2(%r8, %rax, 1), %ebx /* Carga R en ebx */
    cvtsi2sd %ebx, %xmm0          /* Convierte int a double */
    divsd   %xmm15, %xmm0        /* Normaliza: R / 255.0 */
    call    valorRGBlineal
    movsd   %xmm0, %xmm3          /* Guarda R_lineal en %xmm3 */

    /* Calcular Ylineal = 0.2126*R + 0.7152*G + 0.0722*B */
    movsd   cR(%rip), %xmm4
    mulsd   %xmm3, %xmm4          /* 0.2126 * R */
    movsd   cG(%rip), %xmm5
    mulsd   %xmm2, %xmm5          /* 0.7152 * G */
    movsd   cB(%rip), %xmm6
    mulsd   %xmm1, %xmm6          /* 0.0722 * B */

    addsd   %xmm5, %xmm4
    addsd   %xmm6, %xmm4          /* %xmm4 ahora contiene Y_lineal */

    /* Comprimir Ylineal y escribir en memoria */
    movsd   %xmm4, %xmm0          /* Mover Y_lineal a %xmm0 para la llamada */
    call    valorYcomprimido      /* Resultado (Y_comprimido) en %xmm0 */

    mulsd   %xmm15, %xmm0         /* Escalar de nuevo a 0-255 */
    cvtsd2si %xmm0, %ebx          /* Convertir double a int (%ebx) */

    /* Escribir el mismo valor en los 3 canales */
    movb    %bl, (%r8, %rax, 1)    /* Escribir byte en canal B */
    movb    %bl, 1(%r8, %rax, 1)   /* Escribir byte en canal G */
    movb    %bl, 2(%r8, %rax, 1)   /* Escribir byte en canal R */

    incl    %r13d                 /* j++ */
    jmp     .col_loop

.sig_fila:
    incl    %r12d                 /* i++ */
    jmp     .fila_loop

.fin:
    movl    $0, %eax              /* Valor de retorno 0 (éxito) */

    /* Restaurar registros no volátiles */
    popq    %r13
    popq    %r12

    popq    %rbp
    ret

/* Sección de datos de solo lectura para las constantes */
.section .rodata
.align 8
d_255: .double 255.0
cR:    .double 0.2126
cG:    .double 0.7152
cB:    .double 0.0722
