#!/bin/bash

DIRECTORY="$1"
TC="$2"
TC_Dir=dirname "${TC}"
TC_Name="$3"
BN=$(basename ${TC_Directory})
#Compile Everything in directory

iverilog -g 2012  \ test/mips_cpu_harvard_tb.v ${DIRECTORY}/mips_cpu_harvard.v ${DIRECTORY}/mips_cpu/*.v \ -s mips_cpu_harvard_tb \ -P mips_cpu_harvard_tb.RAM_INIT_FILE = \"${TC}\" mips_cpu_harvard_tb.REF_FILE = \"${TC_Dir}/${BN}_ref.txt\"  \ -o test/Executables/mips_cpu_harvard_tb_${BN}
set +e
test/Executables/mips_cpu_harvard_tb_${BN}
RESULT=$?
set -e

if[["${RESULT}" -ne 0]]; then
	echo "${BN}, FAIL"
	exit
fi