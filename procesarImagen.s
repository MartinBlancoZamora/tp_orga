.section .text
    .global procesarImagen
    .extern valorRGBlineal
    .extern valorYcomprimido

procesarImagen:
    pushq   %rbp
    movq    %rsp, %rbp
    pushq   %rbx
    pushq   %r12
    subq    $48, %rsp 

    movq    %rdi, %rbx
    movq    %rsi, %r12
    movl    %edx, -8(%rbp)
    movl    %ecx, -12(%rbp)
    movl    %r8d, -16(%rbp)

    movsd   d_255(%rip), %xmm15
    movl    $0, -20(%rbp)

.fila_loop:
    movl    -20(%rbp), %eax
    cmpl    -8(%rbp), %eax
    jge     .fin_de_todo

    movl    $0, -24(%rbp)

.col_loop:
    movl    -24(%rbp), %eax
    cmpl    -12(%rbp), %eax
    jge     .sig_fila

    movl    -20(%rbp), %eax
    imull   -12(%rbp), %eax
    addl    -24(%rbp), %eax
    imull   -16(%rbp), %eax
    movslq  %eax, %r9

    movzbl  (%rbx, %r9, 1), %edi
    cvtsi2sd %edi, %xmm0; divsd %xmm15, %xmm0
    #call valorRGBlineal
    movsd   %xmm0, -32(%rbp)

    movzbl  1(%rbx, %r9, 1), %edi
    cvtsi2sd %edi, %xmm0; divsd %xmm15, %xmm0
    #call valorRGBlineal
    movsd   %xmm0, -40(%rbp)

    movzbl  2(%rbx, %r9, 1), %edi
    cvtsi2sd %edi, %xmm0; divsd %xmm15, %xmm0
    #call valorRGBlineal
    movsd   %xmm0, -48(%rbp)

    movsd   cR(%rip), %xmm1
    mulsd   -48(%rbp), %xmm1
    movsd   cG(%rip), %xmm2
    mulsd   -40(%rbp), %xmm2
    movsd   cB(%rip), %xmm3
    mulsd   -32(%rbp), %xmm3
    addsd   %xmm2, %xmm1
    addsd   %xmm3, %xmm1
    
    movsd   %xmm1, %xmm0
    #call valorYcomprimido

    movsd   d_255(%rip), %xmm1
    mulsd   %xmm1, %xmm0
    cvtsd2si %xmm0, %r8d
    movb    %r8b, (%r12, %r9, 1)
    movb    %r8b, 1(%r12, %r9, 1)
    movb    %r8b, 2(%r12, %r9, 1)

    addl    $1, -24(%rbp)
    jmp     .col_loop

.sig_fila:
    addl    $1, -20(%rbp)
    jmp     .fila_loop

.fin_de_todo:
    addq    $48, %rsp
    popq    %r12
    popq    %rbx
    popq    %rbp
    ret

.section .rodata
.align 8
d_255: .double 255.0
cR:    .double 0.2126
cG:    .double 0.7152
cB:    .double 0.0722