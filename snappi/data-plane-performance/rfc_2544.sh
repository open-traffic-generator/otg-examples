#!/bin/bash

help() {
    echo "Usage: $0 [options]"
    echo
    echo "Options:"
    echo "  -s <frame_size_list>          Set the list of frame_sizes in bytes (e.g., \"768,1024,1518,9000\")"
    echo "  -d <direction>                Specify the data direction (upstream or downstream)"
}

while getopts "hs:d:" option; do
    case $option in
        h) # display Help
            help
            exit;;
        s) #frame sizes
            echo $OPTARG
            frame_sizes=$OPTARG
            ;;
        d) #direction
            echo $OPTARG
            direction=$OPTARG 
            ;; 
    esac
done

echo "frame_sizes=$frame_sizes"
echo "direction=$direction"

# Default values
if [ -z "$frame_sizes" ]
then
   frame_sizes="768,1024,1518,9000"
fi

if [ -z "$direction" ]
then
   direction="upstream"
fi

echo "frame_sizes=$frame_sizes"
echo "direction=$direction"


echo "Running test: python3 -m pytest ./py/test_rfc2544.py \
 --frame_sizes $frame_sizes \
 --direction $direction"

python3 -m pytest -q ./py/test_rfc2544.py \
 --frame_sizes $frame_sizes \
 --direction $direction
