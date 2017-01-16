#!/bin/bash
export LD_PRELOAD=/home/valerio/crane/libevent_paxos/client-ld-preload/libclilib.so.1.0
#ab -n 1000 -k -c 8 http://10.3.1.1:9000/test.php
ab -n 1000 -c 8 http://10.3.1.1:9000/test.php
ab -n 1000 -c 8 http://10.3.1.1:7000/test.php
ab -n 1000 -c 8 http://10.3.1.1:9000/test_long.php
ab -n 1000 -c 8 http://10.3.1.1:7000/test_long.php
ab -n 1000 -c 8 http://10.3.1.1:9000/index.html
ab -n 1000 -c 8 http://10.3.1.1:7000/index.html

#/opt/wrk2/bin/wrk -d 30s -c 20 -t 8 -R 1000 http://10.3.1.1:9000/test.php
