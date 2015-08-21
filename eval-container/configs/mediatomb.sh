# Setups for MediaTomb
# Notice :
# 1. For each mode, change start-sever, run-client and local.options accordingly.
# 2. Better comment out the LD_PRELOAD for client in master.py

source configs/default-options.sh
app="mediatomb"                                       # app name appears in process list

# evaluation options are moved into default-options.sh as plan functions.

dmt_log_output=0
leader_elect=0                                        # 1 enable leader election demo, 0 otherwise
checkpoint=0                                          # 1 use checkpoint on relicas, 0 otherwise
checkpoint_period=10                                  # period of CRIU checkpoint, e.g. 10 seconds
msmr_root_client=`echo $MSMR_ROOT`        # root dir for m-smr
msmr_root_server=`echo $MSMR_ROOT`
input_url="127.0.0.1"                                 # url for client to query
analysis_tools=""
proxy_ld_preload="LD_PRELOAD=${msmr_root_server}/libevent_paxos/client-ld-preload/libclilib.so"
client_bin="${msmr_root_client}/apps/apache/install/bin/ab"

# CPU bound workloads.
client_opt_7000="-n 8 -c 8 http://128.59.17.174:7000/content/media/object_id/8/res_id/none/pr_name/vlcmpeg/tr/1"
client_opt_9000="-n 8 -c 8 http://128.59.17.174:9000/content/media/object_id/8/res_id/none/pr_name/vlcmpeg/tr/1"

# IO bound workloads.
#client_opt_7000="-n 8 -c 8 http://128.59.17.174:7000/content/media/object_id/8/res_id/0"
#client_opt_9000="-n 8 -c 8 http://128.59.17.174:9000/content/media/object_id/8/res_id/0"

if [ $proxy -eq 1 ]
then
    if [ $leader_elect -eq 1 ]
    then
        client_cmd="parallel-ssh -v -p 1 -i -t 15 -h head '${proxy_ld_preload} ${client_bin} ${client_opt_9000}'"
    else
	client_cmd="parallel-ssh -v -p 1 -i -t 15 -h head '${proxy_ld_preload} ${client_bin} ${client_opt_9000}'"
    fi
else
	client_cmd="parallel-ssh -v -p 1 -i -t 15 -h head '${client_bin} ${client_opt_7000}'"
fi
                                                      # command to start the clients
local_server_ip=""
if [ $enable_lxc"X" == "yesX" ]
then
	local_server_ip="10.0.3.111"
	echo "Now you run CRANE with lxc on mediatomb, if previously you did not run it with lxc, please log into the u1 container, go to \
	~/hku/m-smr/apps/mediatomb, and run ./generate-database 10.0.3.111 on all bug0X machines."
	sleep 2
else
	local_server_ip="127.0.0.1"
	echo "Now you run CRANE without lxc on mediatomb, if previously you ran it with lxc, please log into the u1 container, go to \
	~/hku/m-smr/apps/mediatomb, and run ./generate-database 127.0.0.1 on all bug0X machines."
	sleep 2
fi
server_cmd="'${msmr_root_server}/apps/mediatomb/install/bin/mediatomb \
	-i ${local_server_ip} -p 7000 -m ${msmr_root_server}/apps/mediatomb &> server-out.txt &'"
                                                      # command to start the real server
