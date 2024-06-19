#!/bin/sh

video_stream_detect.sh &
while true
do
    echo "reset tutk_product_test"
    /tmp/tutk_test/tutk_product_test
done
