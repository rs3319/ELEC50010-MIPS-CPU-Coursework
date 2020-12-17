#!/bin/bash

DIRECTORY="$1"
TC="$2"
TC_Dir=$(dirname "${TC}")

BN=$(basename "${TC}" .hex.txt)
TC_Name=${BN%-*}
REFS_OUT=$(cat "test/Outputs/${BN}.txt")
#Compile Everything in directory
iverilog -g 2012 -s mips_cpu_harvard_tb  \ test/mips_cpu_harvard_tb.v test/mips_cpu_dMemory.v test/mips_cpu_iMemory.v ${DIRECTORY}/mips_cpu_harvard.v ${DIRECTORY}/mips_cpu/*.v \  -Pmips_cpu_harvard_tb.RAM_INIT_FILE=\"${TC}\" -Pmips_cpu_harvard_tb.REF_OUT=${REFS_OUT} \  -o test/Executables/mips_cpu_harvard_tb_${BN} 
set +e
test/Executables/mips_cpu_harvard_tb_${BN} > warning.log
RESULT=$?
set -e

if [ ${RESULT} != 0 ]; then
	echo "${BN} ${TC_Name} Fail"
else 
	echo "${BN} ${TC_Name} Pass"
fi