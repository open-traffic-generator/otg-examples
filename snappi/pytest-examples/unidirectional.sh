#!/bin/bash

help()
{
    echo "Usage:"
    echo " $0 [-s <frame_size>] [-t <test_time>] [-l <line_rate_per_flow>] [-d direction]"
    echo "   -s <frame_size>          --- int - bytes, e.g. 9000"
    echo "   -t <test_time>           --- int - seconds, e.g. 10"
    echo "   -l <line_rate_per_flow>  --- float - percentage, e.g. 23.5"
    echo "   -d <direction>           --- string - upstream or downstream"
}

while getopts "hs:t:l:d:" option; do
    case $option in
        h) # display Help
            help
            exit;;
        s) #frame size
            echo $OPTARG
            frame_size=$OPTARG
            ;;
        t) #duration
            echo $OPTARG
            duration=$OPTARG
            ;;
        l) #line_rate_per_flow
            echo $OPTARG
            line_rate_per_flow=$OPTARG 
            ;;
        d) #direction
            echo $OPTARG
            direction=$OPTARG 
            ;; 
    esac
done

# Default values
if [ -z "$frame_size" ]
then
   frame_size=9000
fi

if [ -z "$duration" ]
then
   duration=10
fi

if [ -z "$line_rate_per_flow" ]
then
   line_rate_per_flow=100
fi

if [ -z "$direction" ]
then
   direction="upstream"
fi

echo "frame_size=$frame_size"
echo "duration=$duration"
echo "line_rate_per_flow=$line_rate_per_flow"
echo "direction=$direction"

echo "Running test: python3 -m pytest ./py/test_unidirectional.py \
 --frame_size $frame_size \
 --duration $duration \
 --line_rate_per_flow $line_rate_per_flow \
 --direction $direction"

python3 -m pytest ./py/test_unidirectional.py \
 --frame_size $frame_size \
 --duration $duration \
 --line_rate_per_flow $line_rate_per_flow \
 --direction $direction