
fma:     file format elf64-x86-64


Disassembly of section .init:

Disassembly of section .plt:

Disassembly of section .plt.got:

Disassembly of section .text:

00000000000013a0 <no_fma(float)>:
    13a0:	c5 fa 59 c0          	vmulss %xmm0,%xmm0,%xmm0
    13a4:	c5 fa 58 05 58 0c 00 	vaddss 0xc58(%rip),%xmm0,%xmm0        # 2004 <_IO_stdin_used+0x4>
    13ab:	00 
    13ac:	c3                   	ret

Disassembly of section .fini:
