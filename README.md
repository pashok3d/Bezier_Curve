# Bezier curve
Assembler MIPS-32
# How to run
- Download MARS MIPS simulator 
  - http://courses.missouristate.edu/KenVollmar/mars/
- Download Bezier_Curve.asm
- Place (Create) image_in.bmp in the MARS MIPS simulator directory 
- Using MARS MIPS simulator, run Bezier_Curve.asm
- As a result image_out.bmp will be created
# Problems faced during project development
- How to make fractional arithmetics in MIPS?
  - Bad solution: Use MIPS Floating Point Instructions
  - Good solution: Use Q number format
  - Best solution: Avoid using fractional arithmetics. Obviously, the smallest
  unit we operate on is pixel. Defining pixel's position by two integers, we
  actually don't have to deal with fractional numbers, because Bx and By will be rounded anyway.
- To take care about proper rounding? (2.8 -> 3, not 2)
  - That is not true.
- Runtime exception at "adress": fetch address not aligned on word boundary "adress". 
Program doesn't want to read FileSize (or DataOffset, itc.) from header (which was copied in ram "buffer") using lw. 
  - Solution: copied FileSize located in "buffer" is probably at the adress which is not divisible by 4 bytes, so we need to add .align 2 in .data section before "buffer" declaration.
