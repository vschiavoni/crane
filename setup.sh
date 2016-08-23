#Setup a machine for Crane either to act as primary or backup.
#
#Assumptions: 
#- base os: Ubuntu 14.04 LTS (UniNE cluster VM template ID: 404 )
#- there must be a user ubuntu (this is the case for the VMs deployed from our template)
# To execute it inside a screen session:
# /bin/bash -c 'screen -t test /bin/bash /home/ubuntu/setup.sh;'
#Author: valerio.schiavoni@unine.ch

echo "export MSMR_ROOT=$HOME/crane" >> ~/.profile
echo "export XTERN_ROOT=$HOME/crane/xtern" >> ~/.profile
echo "export LD_LIBRARY_PATH=$MSMR_ROOT/libevent_paxos/.local/lib:$LD_LIBRARY_PATH" >> ~/.profile
wget https://raw.githubusercontent.com/vschiavoni/crane/master/install.sh
bash -l install.sh
