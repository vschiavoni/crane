#!/bin/bash
#Do no execute this script directly. Instead, this is executed from setup.sh

sudo apt-get install --assume-yes build-essential
sudo apt-get install --assume-yes libboost-dev git subversion nano libconfig-dev libevent-dev \
    sqlite3 libsqlite3-dev libdb-dev libboost-system-dev autoconf m4 dejagnu flex bison axel zlib1g-dev \
    libbz2-dev libxml-libxml-perl python-pip python-setuptools python-dev libxslt1-dev libxml2-dev \
    wget curl php5-cgi psmisc mencoder
sudo pip install numpy
sudo pip install OutputCheck
git clone https://github.com/ruigulala/crane.git

cd $MSMR_ROOT
git submodule update --init --recursive #maybe useless

cd $XTERN_ROOT
mkdir obj && cd obj
./../configure --prefix=$XTERN_ROOT/install
make clean; make; make install
cd $MSMR_ROOT/libevent_paxos
./mk
make clean; 
make 

sudo apt-get install --assume-yes software-properties-common
sudo add-apt-repository -y ppa:ubuntu-lxc/daily
sudo apt-get update
sudo apt-get install --assume-yes lxc

sudo mount /dev/vdb /mnt/containers #specific to our VM template
sudo lxc-create -t ubuntu -n u1 -- -r trusty -a amd64
sudo lxc-start -n u1
sudo lxc-stop -n u1

sudo bash -c "echo '/dev/shm dev/shm none bind,create=dir' > /mnt/containers/u1/fstab"
sudo bash -c "echo 'lxc.network.ipv4 = 10.0.3.111/16' >> /mnt/containers/u1/config"
sudo bash -c "echo 'lxc.console = none' >> /mnt/containers/u1/config"
sudo bash -c "echo 'lxc.tty = 0' >> /mnt/containers/u1/config"
sudo bash -c "echo 'lxc.cgroup.devices.deny = c 5:1 rwm' >> /mnt/containers/u1/config"
sudo bash -c "echo 'lxc.rootfs = /mnt/containers/u1/rootfs' >> /mnt/containers/u1/config"
sudo bash -c "echo 'lxc.mount = /mnt/containers/u1/fstab' >> /mnt/containers/u1/config"
sudo bash -c "echo 'lxc.mount.auto = proc:rw sys:rw cgroup-full:rw' >> /mnt/containers/u1/config"
sudo bash -c "echo 'lxc.aa_profile = unconfined' >> /mnt/containers/u1/config"
sudo lxc-start -n u1

touch ~/.ssh/config
echo "10.0.3.*" >> ~/.ssh/config
echo "	User ubuntu" >> ~/.ssh/config
echo "	IdentityFile ~/.ssh/lxc_priv_key" >> ~/.ssh/config
echo "StrictHostKeyChecking no" >> ~/.ssh/config
cat /dev/zero| ssh-keygen -f /home/ubuntu/.ssh/lxc_priv_key -N ""
ssh-copy-id -i /home/ubuntu/.ssh/lxc_priv_key.pub ubuntu@10.0.3.111