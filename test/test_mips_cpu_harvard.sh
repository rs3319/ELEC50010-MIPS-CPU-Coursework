#!/bin/bash

DIRECTORY="$1"
TestInstr="$2"
if [ ${TestInstr} != "" ]
	then
	TC="test/Assembly/${TestInstr}*.hex.txt"
else
	TC="test/Assembly/*.hex.txt"	
fi

for i in ${TC} ; do
#	echo "----------------------------------------------------------"
#	echo ${i}
#	echo "----------------------------------------------------------"
	test/test_mips_cpu_harvard_one.sh ${DIRECTORY} ${i} ${TestInstr}

done