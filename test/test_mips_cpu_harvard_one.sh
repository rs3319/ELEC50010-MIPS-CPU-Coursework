#!/bin/bash

DIRECTORY = "$1"
TC_Directory = "$2"
TC_Name = "$3"

#Compile Everything in directory

iverilog -g 2012 \ ${DIRECTORY}/*.v