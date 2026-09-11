#!/bin/bash
#.vsc -> .bin (binary)

#16 bits long instructions (2 bytes)
    #6 bits opcode, 2 bits register info, 8 bits memory address
#256 bytes (2048 bits) of memory
#4 registers

#INITIAL STATE
#256-long array all 0s
#4-long registers array all 0s
#program counter counts by byte, 
    #e.g. first instruction is at memory address 0 and 1. Address (N, N+1)

#VSC LAYOUT
#1 byte, a number (n) saying how many values will be provided
#n static values which will initialise memory from address 0 to (n-1)
#instructions per 2 bytes, loaded into memory starting with address n.

#ASSEMBLER:
#take 1 argument only
#should be a pre-existing .vsc file

if [ "$#" -ne "1" ] #not 1 arg
then
    echo -e "usage: can only accept 1 argument.\n"
    exit 0
fi

if ! [[ $1 =~ .vsc ]]
then
    echo -e "usage: must be a .vsc file.\n"
    exit 0
fi

if [ !  -f "$1" ]
then
    echo -e "usage: can only accept a pre-existing file.\n"
    exit 0
fi
