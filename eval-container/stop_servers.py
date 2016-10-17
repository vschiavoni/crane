#!/usr/bin/python2.7

import argparse
import time
import logging
import datetime
import signal
import sys
import os
import subprocess

logger = logging.getLogger("Benchmark.Master")

MSMR_ROOT = ''
USER = os.environ["USER"]
MSMR_ROOT = os.environ["MSMR_ROOT"]

def kill_previous_process(args):
    
    print "Killing residual processes"
    cmd = 'sudo killall -9 mencoder worker-run.py server.out %s %s-amd64- %s-amd64- %s-amd64-' % (
            args.app, args.head, args.worker1, args.worker2)
    rcmd = 'parallel-ssh -l {username} -v -p 3 -i -t 15 -h hostfile {command}'.format(
            username=USER, command=cmd)
    p = subprocess.Popen(rcmd, shell=True, stdout=subprocess.PIPE)
    output, err = p.communicate()
    print output

    print "Removing temporaries"
    cmd = 'sudo rm -rf /dev/shm/*'
    rcmd = 'parallel-ssh -l {username} -v -p 3 -i -t 15 -h hostfile {command}'.format(
            username=USER, command=cmd)
    p = subprocess.Popen(rcmd, shell=True, stdout=subprocess.PIPE)
    output, err = p.communicate()
    print output

    # killall criu-cr.py via sudo
    # sgx2 worker2
    cmd = 'sudo killall -9 criu-cr.py &> /dev/null' 
    rcmd = 'parallel-ssh -l {username} -v -p 1 -i -t 15 -h worker2 {command}'.format(
            username=USER, command=cmd)
    p = subprocess.Popen(rcmd, shell=True, stdout=subprocess.PIPE)
    output, err = p.communicate()
    print output

def main(args):
    """
    Main module of start_servers.py
    """
    kill_previous_process(args)


###############################################################################
# Main - Parse command line options and invoke main()   
if __name__ == "__main__":

    parser = argparse.ArgumentParser(description='Explauncher(master)')

    parser.add_argument('-a', type=str, dest="app", action="store",
            help="Name of the application. e.g. microbenchmark.")
    parser.add_argument('-x', type=int, dest="xtern", action="store",
            help="Whether xtern is enabled.")
    parser.add_argument('-p', type=int, dest="proxy", action="store",
            help="Whether proxy is enabled.")
    parser.add_argument('-l', type=int, dest="leader_ele", action="store",
            help="Whether demo leader election.")
    parser.add_argument('-k', type=int, dest="checkpoint", action="store",
            help="Whether checkpointing on replicas is enabled.")
    parser.add_argument('-t', type=int, dest="checkpoint_period", action="store",
            help="Period of CRIU checkpoint")
    parser.add_argument('-c', type=str, dest="msmr_root_client", action="store",
            help="The directory of m-smr.")
    parser.add_argument('-s', type=str, dest="msmr_root_server", action="store",
            help="The directory of m-smr.")
    parser.add_argument('--sp', type=int, dest="sp", action="store",
            help="Schedule with paxos.")
    parser.add_argument('--sd', type=int, dest="sd", action="store",
            help="Schedule with DMT.")
    parser.add_argument('--scmd', type=str, dest="scmd", action="store",
            help="The command to execute the real server.")
    parser.add_argument('--ccmd', type=str, dest="ccmd", action="store",
            help="The command to execute the client.")
    parser.add_argument('-b', type=str, dest="build_project", action="store", default="false",
            help="The command to rebuild the whole project.")
    parser.add_argument('--head', type=str, dest="head", action="store", default="none",
            help="The analysis tool to run on the head machine.")
    parser.add_argument('--worker1', type=str, dest="worker1", action="store", default="none",
            help="The analysis tool to run on the worker1 machine.")
    parser.add_argument('--worker2', type=str, dest="worker2", action="store", default="none",
            help="The analysis tool to run on the worker2 machine.")
    parser.add_argument('--enable-lxc', type=str, dest="enable_lxc",
            action="store", default="no", help="The tool to run the server in a lxc container.")
    parser.add_argument('--dmt-log-output', type=int, dest="dmt_log_output",
            action="store", default=0, help="Run the DMT and log outputs (send(), write()) of servers.")

    args = parser.parse_args()
    print "Replaying parameters:"
    print "app : " + args.app
    print "proxy : " + str(args.proxy)
    print "xtern : " + str(args.xtern)
    print "joint : " + str(args.sp) + " " + str(args.sd)
    print "leader election : " + str(args.leader_ele)
    print "checkpoint : " + str(args.checkpoint)
    print "checkpoint_period : " + str(args.checkpoint_period)
    print "MSMR_ROOT : " + args.msmr_root_client
    print "build project : " + args.build_project

    main_start_time = time.time()

    MSMR_ROOT = args.msmr_root_client
    main(args)

    main_end_time = time.time()

    logger.info("Total time : %f sec", main_end_time - main_start_time)
