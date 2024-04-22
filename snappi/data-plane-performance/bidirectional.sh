#!/bin/bash

help() {
    echo "Usage: $0 [options]"
    echo
    echo "Options:"
    echo "  -s <frame_size>          Set the frame size in bytes (e.g., 9000)"
    echo "  -t <test_time>           Specify the test duration in seconds (e.g., 10)"
    echo "  -l <line_rate_per_flow>  Set the line rate per flow as a percentage (e.g., 100)"
}

while getopts "hs:t:l:" option; do
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

echo "frame_size=$frame_size"
echo "duration=$duration"
echo "line_rate_per_flow=$line_rate_per_flow"

echo "Running test: python3 -m pytest ./py/test_bidirectional.py \
 --frame_size $frame_size \
 --duration $duration \test_bidirectional
 --line_rate_per_flow $line_rate_per_flow"

python3 -m pytest -q ./py/test_bidirectional.py \
 --frame_size $frame_size \
 --duration $duration \
 --line_rate_per_flow $line_rate_per_flow