#Joshua Ottaviano
#jott0514
#560603222
# USYD CODE CITATION ACKNOWLEDGEMENT
# This file contains acknowledgements for ideas and/or code


#!/bin/bash
#.vsc -> .bin (binary)

#instructions
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

#
#INITIAL FILE CHECKS
if [ "$#" -eq "0" ] #0 args
then
    echo -e "usage: no arg is provided."
    exit 1
fi

if [ "$#" -gt "1" ] # >1 args
then
    echo -e "usage: more than one arguments are provided."
    exit 1
fi

if ! [[ $1 =~ .vsc ]]
then
    echo -e "usage: input does not have the extension .vsc."
    exit 1
fi

if [ !  -f "$1" ]
then
    echo -e "usage: input is not a file or it does not exist."
    exit 1
fi

file_path=$1
if [ `wc -l < $file_path` -eq "0" ]
then
    echo -e "usage: the file is empty - no .bin file is produced."
    exit 1
fi

#debug
function debugMessage() {
    output=$1
    #echo $output
}

#NOW LOOK AT THE VALID FILE AND VALIDATE/CONVERT COMMANDS
function successful_program() {
    echo "the content of the .bin file is:"
    xxd -p -c 1 program.bin
    exit 0
}

function run_quit_program() {
    file_path=$1
    if [ `head -2 $file_path | tail -1` == "QUIT,0,0" ]
    then
        rm program.bin
        touch program.bin
        printf '\x20' >> program.bin #byte 1 (QUIT,0)
        printf '\x00' >> program.bin #byte 2 (,0)

        successful_program
    else
        echo -e "file: incorrect file layout"
        exit 1
    fi
}

function dec_to_bin() {
    membin=''
    tmp=$1
    for weight in 128 64 32 16 8 4 2 1
    do
        if (( $tmp >= $weight )); then
            bit=1
            tmp=$(( $tmp - $weight ))
        else
            bit=0
        fi
        membin="$membin$bit"
    done
    echo $membin
}

function run_add-sub_program() {
    file_path=$1
    line2=`head -2 $file_path | tail -1`
    line3=`head -3 $file_path | tail -1`

    #check is positive numbers
    if ! [[ $line2 =~ ^[0-9]+ ]] || ! [[ $line3 =~ ^[0-9]+ ]]
    then
        echo "file: data values must be positive digits"
        exit 1
    fi
    #check is numbers within range
    if ! [ $line2 -le "128" ] || ! [ $line3 -le "128" ]
        then
            echo "file: data values must be within 0-128"
            exit 1
    fi

    #array time
    dataArray=()
    dataArray[0]=`dec_to_bin $line2`
    dataArray[1]=`dec_to_bin $line3`

    file_lines=`wc -l < $file_path`
    file_lines=$(( file_lines - 3 ))
    
    #process only lines after line 3, up to 100 lines
    for line in `tail -$file_lines $file_path | head -100`
    do

        if [ ${#line} -gt "11" ]
        then
            echo -e "file: command $line longer than 11 characters"
            exit 1
        fi

        IFS=',' splitLine=($line)
        
        ins=${splitLine[0]}
        if ! [[ `echo $ins | grep -E 'LOAD|STORE|ADD|SUB|QUIT|PRINT'` ]]
        then
            echo -e "file: command $ins not found"
            exit 1
        fi
        reg=${splitLine[1]}
        mem=${splitLine[2]}

        if [ "$ins" == "LOAD" ]
        then
            ins='000001'
        elif [ "$ins" == "STORE" ]
        then
            ins='000010'
        elif [ "$ins" == "ADD" ]
        then
            ins='000011'
        elif [ "$ins" == "SUB" ]
        then
            ins='000100'
        elif [ "$ins" == "QUIT" ]
        then
            ins='001000'
        elif [ "$ins" == "PRINT" ]
        then
            ins='001001'
        fi

        if [[ $reg == '' ]]
        then
            echo -e "The reg. part of ${splitLine[0]}, is empty."
            exit 1
        fi
        if [[ $reg =~ ^[0-3]$ ]]
        then
            if [ $reg -eq "0" ]
            then
                reg='00'
            elif [ $reg -eq "1" ]
            then
                reg='01'
            elif [ $reg -eq "2" ]
            then
                reg='10'
            elif [ $reg -eq "3" ]
            then
                reg='11'
            fi
        else
            echo -e "file: $reg must be a number."
            exit 1
        fi

        if [[ $mem == '' ]]
        then
            echo -e "The mem. part of ${splitLine[0]},${splitLine[1]} is empty."
            exit 1
        fi
        if [[ $mem =~ ^[0-9]+ ]]
        then
            if [ $mem -le "255" ]
            then
                mem=`dec_to_bin $mem` #success
            else
                echo -e "$mem must be a number from 0-255"
                exit 1
            fi
        else
            echo -e "file: $mem must be a number."
            exit 1
        fi

        dataArray+=("$ins$reg")
        dataArray+=("$mem")
    done < <(ls -1 | head -2)

    rm program.bin
    touch program.bin
    prev_data=""
    for data in ${dataArray[@]}; do
        #toOutput=`printf '%x' "$((2#$data))"` #alternate method

        # USYD CODE CITATION ACKNOWLEDGEMENT
        #I declare that the majority of the following code has been taken
        #from the website titled: "Stack Exchange" and it is not my own work.
        #
        #original URL
        #https://unix.stackexchange.com/questions/65280/binary-to-hexadecimal-and-decimal-in-a-shell-script
        #Last access September, 2026
        toOutput=`echo "obase=16; ibase=2; $data" | bc` #binary to hex
        #End of copied code

        debugMessage $data
        debugMessage $toOutput
        debugMessage "###"
        printf "\x$toOutput" >> program.bin #hex to raw binary

        if [ "$prev_data" == "00100000" ] && [ "$data" == "00000000" ]; then
            successful_program
        fi
        prev_data="$data"
    done
    echo -e "file: must end with QUIT,0,0"
    exit 1

}

#check n
n=`head -1 $file_path`
if [[ n -eq "0" ]]
then
    echo "It is a QUIT program"
    run_quit_program $file_path
else
    if [[ n -eq "2" ]]
    then
        echo "It is an ADD/SUB program"
        run_add-sub_program $file_path
    else
        echo -e "file: file is invalid - no .bin file is produced"
        exit 1
    fi
fi