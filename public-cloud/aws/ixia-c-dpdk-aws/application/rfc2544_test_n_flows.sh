#!/bin/bash

help()
{
    echo "Usage:"
    echo " $0 [-s <frame_sizes>] [-d <direction>]"
    echo "   -s <frame_sizes>    --- list of frame_sizes in bytes, e.g. \"768,1024,1518,9000\""
    echo "   -d <direction>      --- string - upstream or downstream"
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

cd /home/ixia/ixia-c-tests

echo "" > throughput_results_rfc2544_n_flows.json  # clean old results


echo "Running test: python3 -m pytest ./py/test_throughput_rfc2544_n_flows.py \
 --frame_sizes $frame_sizes \
 --direction $direction"

python3 -m pytest ./py/test_throughput_rfc2544_n_flows.py \
 --frame_sizes $frame_sizes \
 --direction $direction

cat throughput_results_rfc2544_n_flows.json  | jq
cat throughput_results_rfc2544_n_flows.json  | jq > tmp.json
cat tmp.json > throughput_results_rfc2544_n_flows.json
rm tmp.json

