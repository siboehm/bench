
fma:     file format elf64-x86-64


Disassembly of section .init:

Disassembly of section .plt:

Disassembly of section .plt.got:

Disassembly of section .text:

0000000000001390 <with_fma(float)>:
    1390:	c4 e2 79 a9 05 6b 0c 	vfmadd213ss 0xc6b(%rip),%xmm0,%xmm0        # 2004 <_IO_stdin_used+0x4>
    1397:	00 00 
    1399:	c3                   	ret

Disassembly of section .fini:
