#!/bin/bash

# https://github.com/myvin/ijoke

readonly BINARY_NAME="ijoke"
readonly VERSION="v0.0.1"

usage() {
cat <<EOF

ijoke - https://github.com/myvin/ijoke

Command-line joke generator.

Usage: ${BINARY_NAME} <command> ...

Options:

-c, --count     Set output joke count
-h, --help      Print ijoke command line options
-v, --version   Print current ijoke version

EOF
exit 0
}

title="\033[32;4mijoke - https://github.com/myvin/ijoke\033[0m"
length=0

dump() {
    count=$1
    seq=0
    jokes=`cat jokes/index.json`
    list=`echo $jokes | jq '.'`
    length=`echo $jokes | jq 'length'`

    while [ $count -gt 0 ]
    do
        count=`expr $count - 1`
        seq=`expr $seq + 1`

        index=`expr $RANDOM % $length + 1`
        joke=`echo $jokes | jq .[$index]`

        question=`echo $joke | jq .setup?`
        answer=`echo $joke | jq .punchline?`

        content="$content\033[32m#$seq\nQ: $question\nA: $answer\033[0m\n\n"
    done
    echo -e "\n$title\n\n$content"
}

if [ $# -eq 0 ];
then
    dump 1
    exit 0
else
    case $1 in
        "-h" | "--help") usage
        ;;
        "-v" | "--version")
        echo $VERSION
        exit 0
        ;;
        "-c" | "--count")
        if [ $2 -gt 10 ] 2>/dev/null
        then
            echo -n "it will cost more time because the count argument is too large. are you sure to continue? (y/n)"
            while read SURE
            do
                if [ $SURE = "y" ] || [ $SURE = "Y" ]
                then
                    dump $2
                    exit 0
                else
                    echo "you can generate jokes again"
                    exit 1
                fi
            done
        elif [ $2 -gt 0 ] 2>/dev/null
        then
            dump $2
            exit 0
        elif [ $2 -le 0 ] 2>/dev/null
        then
            echo "error: option -c/--count: numeric argument must be greater than 0"
            exit 1
        else
            echo "error: option -c/--count: numeric argument required"
            exit 1
        fi
        ;;
        *) echo "error: invalid option $1"
        exit 1
        ;;
    esac
fi

