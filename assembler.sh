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

#INITIAL FILE CHECKS
if [ "$#" -eq "0" ] #0 args
then
    echo -e "usage: no argument is provided"
    exit 1
fi

if [ "$#" -gt "1" ] # >1 args
then
    echo -e "usage: more than one arguments are provided"
    exit 1
fi

if ! [[ $1 =~ .vsc ]]
then
    echo -e "usage: input does not have the extension .vsc"
    exit 1
fi

if [ !  -f "$1" ]
then
    echo -e "usage: input is not a file or it does not exist"
    exit 1
fi

file_path=$1
if [ `wc -l < $file_path` -eq "0" ]
then
    echo -e "usage: the file is empty - no .bin file is produced"
    exit 1
fi

#NOW LOOK AT THE VALID FILE AND VALIDATE/CONVERT COMMANDS

function run_quit_program() {
    file_path=$1
    if [ `head -2 $file_path | tail -1` == "QUIT,0,0" ]
    then
        rm program.bin
        touch program.bin
        printf '\x20' >> program.bin 
        printf '\x00' >> program.bin
        printf '\x00' >> program.bin

        echo "It is a QUIT program"
        echo "***********"
        echo "the content of the .bin file is:"
        echo `xxd program.bin`
        exit 0
    else
        echo -e "file: incorrect file layout"
        exit 1
    fi
}
function run_add-sub_program() {
    file_path=$1
    echo "add-sub pro"
}

#check n
n=`head -1 $file_path`
if [[ n -eq "0" ]]
then
    run_quit_program $file_path
else
    if [[ n -eq "2" ]]
    then
        run_add-sub_program $file_path
    else
        echo -e "file: file is invalid - no .bin file is produced"
        exit 1
    fi
fi

stret='''
i=0 #iterator
#one extra check for if the last line has a nonzero length
while IFS= read -r line || [ -n "$line" ]
do
    if [ $i -eq "0"  ]
    then
        if [[ $line =~ "0" ]]
        then
            run_quit_program $line
        fi
    else 
        if [ $i -le "2" ]
        then
            if [[ $line =~ QUIT* ]]
        fi
    fi

    #debug stuff
    echo "$line"
    ((i++))
done < $file_path
echo $i
'''
