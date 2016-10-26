#!/bin/bash
#Do no execute this script directly. Instead, this is executed from setup.sh

sudo apt-get install --assume-yes build-essential libboost-dev git subversion nano libconfig-dev libevent-dev \
    sqlite3 libsqlite3-dev libdb-dev libboost-system-dev autoconf m4 dejagnu flex bison axel zlib1g-dev \
    libbz2-dev libxml-libxml-perl python-pip python-setuptools python-dev libxslt1-dev libxml2-dev \
    wget curl php5-cgi psmisc mencoder
sudo pip install numpy
sudo pip install OutputCheck
git clone https://github.com/vschiavoni/crane.git

cd $MSMR_ROOT
git submodule update --init --recursive #maybe useless

cd $XTERN_ROOT
mkdir obj && cd obj
./../configure --prefix=$XTERN_ROOT/install
make clean
make 
make install
cd $MSMR_ROOT/libevent_paxos
./mk
make clean
make 
cd $MSMR_ROOT/apps/apache
./mk

sudo apt-get install --assume-yes software-properties-common
sudo add-apt-repository -y ppa:ubuntu-lxc/daily
sudo apt-get update
sudo apt-get install --assume-yes lxc

#if you have enough disk space, this section can be commented 
if [ "$HOSTNAME" = ubuntu ]; then
	sudo bash -c "echo 'lxc.lxcpath = /mnt/containers' > /etc/lxc/lxc.conf"
	sudo mkdir /mnt/containers
	sudo mount /dev/vdb /mnt/containers #specific to our VM template
fi
#

sudo lxc-create -t ubuntu -n u1 -- -r trusty -a amd64 -b $USER
sudo lxc-start -n u1
sudo lxc-stop -n u1

if [ "$HOSTNAME" = ubuntu ]; then
	sudo bash -c "echo '/dev/shm dev/shm none bind,create=dir' > /mnt/containers/u1/fstab"
	sudo bash -c "echo 'lxc.network.ipv4 = 10.0.3.111/16' >> /mnt/containers/u1/config"
	sudo bash -c "echo 'lxc.console = none' >> /mnt/containers/u1/config"
	sudo bash -c "echo 'lxc.tty = 0' >> /mnt/containers/u1/config"
	sudo bash -c "echo 'lxc.cgroup.devices.deny = c 5:1 rwm' >> /mnt/containers/u1/config"
	sudo bash -c "echo 'lxc.rootfs = /mnt/containers/u1/rootfs' >> /mnt/containers/u1/config"
	sudo bash -c "echo 'lxc.mount = /mnt/containers/u1/fstab' >> /mnt/containers/u1/config"
	sudo bash -c "echo 'lxc.mount.auto = proc:rw sys:rw cgroup-full:rw' >> /mnt/containers/u1/config"
	sudo bash -c "echo 'lxc.aa_profile = unconfined' >> /mnt/containers/u1/config"
else
	sudo bash -c "echo '/dev/shm dev/shm none bind,create=dir' > /var/lib/lxc/u1/fstab"
	sudo bash -c "echo 'lxc.network.ipv4 = 10.0.3.111/16' >> /var/lib/lxc/u1/config"
	sudo bash -c "echo 'lxc.console = none' >> /var/lib/lxc/u1/config"
	sudo bash -c "echo 'lxc.tty = 0' >> /var/lib/lxc/u1/config"
	sudo bash -c "echo 'lxc.cgroup.devices.deny = c 5:1 rwm' >> /var/lib/lxc/u1/config"
	sudo bash -c "echo 'lxc.rootfs = /var/lib/lxc/u1/rootfs' >> /var/lib/lxc/u1/config"
	sudo bash -c "echo 'lxc.mount = /var/lib/lxc/u1/fstab' >> /var/lib/lxc/u1/config"
	sudo bash -c "echo 'lxc.mount.auto = proc:rw sys:rw cgroup-full:rw' >> /var/lib/lxc/u1/config"
	sudo bash -c "echo 'lxc.aa_profile = unconfined' >> /var/lib/lxc/u1/config"	
fi

sudo lxc-start -n u1
sleep 2 #wait a bit, it takes a while to bootstrap
ssh-keygen -f "/home/valerio/.ssh/known_hosts" -R 10.0.3.111 #in case of previous entries
#TODO cleanup ssh/config with previous entries, or avoid adding one if it already exists
touch ~/.ssh/config
echo "Host 10.0.3.*" >> ~/.ssh/config
echo "	User $USER" >> ~/.ssh/config
echo "	IdentityFile ~/.ssh/lxc_priv_key" >> ~/.ssh/config
echo "StrictHostKeyChecking no" >> ~/.ssh/config
cat /dev/zero| ssh-keygen -f $HOME/.ssh/lxc_priv_key -N ""
sudo apt-get install --assume-yes expect
/usr/bin/expect <<EOD
spawn ssh-copy-id -i $HOME/.ssh/lxc_priv_key.pub $USER@10.0.3.111
expect "*password:*"
send "ubuntu\r"
expect eof
EOD

#Make the lxc user able to sudo passwordlessly
/usr/bin/expect <<EOD
spawn sudo lxc-attach -n u1
expect "*root*"
send "echo '$USER ALL= NOPASSWD: ALL' >> /etc/sudoers\r"
send "exit\r"
expect eof
EOD

ssh -t 10.0.3.111 "sudo apt-get install --assume-yes build-essential libboost-dev git subversion nano libconfig-dev libevent-dev \
    sqlite3 libsqlite3-dev libdb-dev libboost-system-dev autoconf m4 dejagnu flex bison axel zlib1g-dev \
    libbz2-dev libxml-libxml-perl python-pip python-setuptools python-dev libxslt1-dev libxml2-dev \
    wget curl php5-cgi psmisc mencoder"
ssh -t 10.0.3.111 "sudo pip install numpy"
ssh -t 10.0.3.111 "sudo pip install OutputCheck"
ssh -t 10.0.3.111 "git clone https://github.com/vschiavoni/crane.git"
ssh -t 10.0.3.111 "echo 'export MSMR_ROOT=\$HOME/crane' >> ~/.profile"
ssh -t 10.0.3.111 "echo 'export XTERN_ROOT=\$MSMR_ROOT/xtern' >> ~/.profile"
ssh -t 10.0.3.111 "echo 'export LD_LIBRARY_PATH=\$MSMR_ROOT/libevent_paxos/.local/lib:\$MSMR_ROOT/libevent_paxos/client-ld-preload:\$LD_LIBRARY_PATH' >> ~/.profile"
ssh -t 10.0.3.111 "bash -c 'source ~/.profile; cd \$XTERN_ROOT/ ; mkdir obj ; cd obj ; ./../configure --prefix=\$XTERN_ROOT/install; make clean; make; make install '"
ssh -t 10.0.3.111 "bash -c 'source ~/.profile; cd \$MSMR_ROOT/libevent_paxos; ./mk; make clean; make'"
ssh -t 10.0.3.111 "bash -c 'source ~/.profile; cd \$MSMR_ROOT/tools/criu/ ; wget http://download.openvz.org/criu/criu-1.6.tar.bz2; tar jxvf criu-1.6.tar.bz2'"
ssh -t 10.0.3.111 "sudo apt-get update && apt-get install --assume-yes libprotobuf-dev libprotoc-dev protobuf-c-compiler libprotobuf-c0 libprotobuf-c0-dev asciidoc bsdmainutils protobuf-compiler"
ssh -t 10.0.3.111 "bash -c 'source ~/.profile; cd \$MSMR_ROOT/tools/criu/criu-1.6 && make -j; sudo make install '"
ssh -t 10.0.3.111 "bash -c 'source ~/.profile; cd \$MSMR_ROOT/apps/apache; ./mk'"