#!/bin/bash
export LD_PRELOAD=/home/valerio/crane/libevent_paxos/client-ld-preload/libclilib.so.1.0
/home/valerio/redis-2.8.17/src/redis-benchmark -h 10.3.1.1 -p 9000 -n 100000 -c 20
