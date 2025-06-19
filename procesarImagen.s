
.section .text
    .global procesarImagen
    .extern valorRGBlineal
    .extern valorYcomprimido


procesarImagen:
    pushq   %rbp
    movq    %rsp, %rbp

    
    pushq   %r12
    pushq   %r13

    movq    %rdi, %r8       
    movl    %esi, %r9d      
    movl    %edx, %r10d     
    movl    %ecx, %r11d     

    movsd   d_255(%rip), %xmm15

    xorl    %r12d, %r12d    

.fila_loop:
    cmpl    %r9d, %r12d     
    jge     .fin            

    xorl    %r13d, %r13d    

.col_loop:
    cmpl    %r10d, %r13d    
    jge     .sig_fila       

    movl    %r12d, %eax     
    imull   %r10d, %eax     
    addl    %r13d, %eax     
    imull   %r11d, %eax     
    movslq  %eax, %rax      

    movzbl  (%r8, %rax, 1), %ebx  
    cvtsi2sd %ebx, %xmm0           
    divsd   %xmm15, %xmm0         
    call    valorRGBlineal        
    movsd   %xmm0, %xmm1          

    movzbl  1(%r8, %rax, 1), %ebx 
    cvtsi2sd %ebx, %xmm0          
    divsd   %xmm15, %xmm0        
    call    valorRGBlineal
    movsd   %xmm0, %xmm2          

    movzbl  2(%r8, %rax, 1), %ebx 
    cvtsi2sd %ebx, %xmm0          
    divsd   %xmm15, %xmm0        
    call    valorRGBlineal
    movsd   %xmm0, %xmm3          

    movsd   cR(%rip), %xmm4
    mulsd   %xmm3, %xmm4          
    movsd   cG(%rip), %xmm5
    mulsd   %xmm2, %xmm5         
    movsd   cB(%rip), %xmm6
    mulsd   %xmm1, %xmm6         

    addsd   %xmm5, %xmm4
    addsd   %xmm6, %xmm4         
    
    
    movsd   %xmm4, %xmm0          
    call    valorYcomprimido      

    mulsd   %xmm15, %xmm0         
    cvtsd2si %xmm0, %ebx         

    
    movb    %bl, (%r8, %rax, 1)    
    movb    %bl, 1(%r8, %rax, 1)   
    movb    %bl, 2(%r8, %rax, 1)   

    incl    %r13d                 
    jmp     .col_loop

.sig_fila:
    incl    %r12d                 
    jmp     .fila_loop

.fin:
    movl    $0, %eax              

    
    popq    %r13
    popq    %r12

    popq    %rbp
    ret


.section .rodata
.align 8
d_255: .double 255.0
cR:    .double 0.2126
cG:    .double 0.7152
cB:    .double 0.0722
