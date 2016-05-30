#Setup a machine for Crane either to act as primary or backup.
#
#Assumptions: 
#- base os: Ubuntu 14.04 LTS (UniNE cluster VM template ID: 404 )
#- there must be a user ubuntu (this is the case for the VMs deployed from our template)
# 
#Author: valerio.schiavoni@unine.ch

echo "export MSMR_ROOT=/home/ubuntu/crane" >> ~/.profile
echo "export XTERN_ROOT=/home/ubuntu/crane/xtern" >> ~/.profile
echo "export LD_LIBRARY_PATH=$MSMR_ROOT/libevent_paxos/.local/lib:$LD_LIBRARY_PATH" >> ~/.profile
wget 
bash -l install.sh
