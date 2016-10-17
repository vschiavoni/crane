#!/bin/bash
# Stop the servers.

cd $XTERN_ROOT
xtern_ver=`git log -n 1 --format="%h"`
cd -

cd $MSMR_ROOT/libevent_paxos
libevent_ver=`git log -n 1 --format="%h"`
cd -

dir_name=$xtern_ver'-'$libevent_ver
if [ ! $1 ]; then
  echo "invalid usage. "
fi

# run the server config script
source $1 $3;

./stop_servers.py -a ${app} -x ${xtern} -p ${proxy} -l ${leader_elect} \
  -k ${checkpoint} -t ${checkpoint_period} \
  -c ${msmr_root_client} -s ${msmr_root_server} \
  --sp ${sch_paxos} --sd ${sch_dmt} \
  --scmd "${server_cmd}" --ccmd "${client_cmd}" -b ${build_project} ${analysis_tools} \
  --enable-lxc ${enable_lxc} --dmt-log-output ${dmt_log_output} | tee perf_log/$dir_name/$app/$app-$3-`date +"%s"`.log
