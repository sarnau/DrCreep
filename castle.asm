// Basic code to load the actual loader

#import "basicmacro.asm"

.segment CASTLE [outPrg="Objects/castle.prg"]
{
    BasicProgram(List().add(
         "10 IF X=1 THEN 40",
         "20 X=1",
        @"30 LOAD \"CREEPLOAD\",8,1",
         "40 SYS "+toIntString(CREEPLOAD_START)
    ))
}
