#!/bin/bash

DIRECTORY = "$1"
TestInstr = "$2"
if [$2 -n STRING]
	then
	TC = "testCases/assembly/${TestInstr}_*_i.asm.txt"
	else
	TC = "testCases/assembly/*_i.asm.txt"	
fi

for i in ${TC} ; do

	./test_mips_cpu_harvard_one ${DIRECTORY} ${TC} 

done