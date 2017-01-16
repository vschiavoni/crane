#!/bin/bash
export LD_PRELOAD=/home/valerio/crane/libevent_paxos/client-ld-preload/libclilib.so.1.0
./mcperf -s 10.3.1.1 -p 9000
unset LD_PRELOAD 
