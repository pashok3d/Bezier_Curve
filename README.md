# Bezier curve
Assembler MIPS-32
# To do 
- Loading BMP and P0,P1,P2
- Bezier arithmetics
  - Bx(t) = P0x*(1-t)^2 + P1x*2t(1-t) + P2x*t^2, t=[0,1]
  - By(t) = P0y*(1-t)^2 + P1y*2t(1-t) + P2y*t^2, t=[0,1]
- Drawing
- Saving BMP
# Problems
- How to make fractional arithmetics in MIPS?
  - Bad solution: Use MIPS Floating Point Instructions
  - Good solution: Use Q number format
  - Best solution: Avoid using fractional arithmetics. Obviously, the smallest
  unit we operate on is pixel. Defining pixel's position by two integers, we
  actually don't have to deal with fractional numbers, because Bx and By will be rounded anyway.
- To take care about proper rounding. (2.8 -> 3, not 2)
  - Decent solution: Additional check of remainder after division.
- Runtime exception at "adress": fetch address not aligned on word boundary "adress". 
Program doesn't want to read FileSize (or DataOffset, itc.) from header (which was copied in ram "buffer") using lw. 
  - Solution: copied FileSize located in "buffer" is probably at the adress which is not divisible by 4 bytes, so we need to add .align 2 in .data section before "buffer" declaration.
# Dead line
13.11.2018
