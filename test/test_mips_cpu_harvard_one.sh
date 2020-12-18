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

if [ ${RESULT} == 0 ]; then
	echo "${BN} ${TC_Name} Pass"
elif [ ${RESULT} == 1 ]; then
	echo "${BN} ${TC_Name} Fail   Reference Outputs do not match testbench Outputs"
elif [ ${RESULT} == 2 ]; then
	echo "${BN} ${TC_Name} Fail   CPU Timed Out: Infinite Loop"
elif [ ${RESULT} == 3 ]; then
	echo "${BN} ${TC_Name} Fail   CPU signal active != 1 after reset"
elif [ ${RESULT} == 4 ]; then
	echo "${BN} ${TC_Name} Fail   Trying to read/write while being reset"
elif [ ${RESULT} == 5 ]; then
	echo "${BN} ${TC_Name} Fail   Data_read and data_write both high at same time"
elif [ ${RESULT} == 6 ]; then
	echo "${BN} ${TC_Name} Fail   Instr_address == Data_Address Conflict"
else
	echo "${BN} ${TC_Name} Fail"
fi