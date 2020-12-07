#!/bin/bash

DIRECTORY="$1"
TestInstr="$2"
if [${TestInstr} -n STRING] ]
	then
	TC="test/Assembly/${TestInstr}*.hex.txt"
else
	TC="test/Assembly/*.hex.txt"	
fi

for i in ${TC} ; do

	test/test_mips_cpu_harvard_one.sh ${DIRECTORY} ${TC} ${TestInstr}

done