#!/bin/bash
echo "/etc/hosts需要自己写好"
sleep 1
echo "时间直接与真机同步"
sleep 1
echo "yum仓库只会添加mon.osd.tools"
sleep 1
echo "检查磁盘是否给好三块"
sleep 1
sed -i '3s/server 0.rhel.pool.ntp.org iburst/#server 0.rhel.pool.ntp.org iburst/' /etc/chrony.conf
sed -i '4s/server 1.rhel.pool.ntp.org iburst/#server 1.rhel.pool.ntp.org iburst/' /etc/chrony.conf
sed -i '5s/server 2.rhel.pool.ntp.org iburst/#server 2.rhel.pool.ntp.org iburst/' /etc/chrony.conf
sed -i '6s/server 3.rhel.pool.ntp.org iburst/server 192.168.4.50 iburst/' /etc/chrony.conf
sed -i 's/gpgcheck=1/gpgcheck=0/' /etc/yum.conf
read -p "请输入yum仓库的名称：" yumname
echo [mon] >> /etc/yum.repos.d/$yumname
echo name=mon >> /etc/yum.repos.d/$yumname
echo baseurl=ftp://192.168.4.254/ceph/rhceph-2.0-rhel-7-x86_64/MON >> /etc/yum.repos.d/$yumname
echo enabled=1 >> /etc/yum.repos.d/$yumname
echo [osd] >> /etc/yum.repos.d/$yumname
echo name=osd >> /etc/yum.repos.d/$yumname
echo baseurl=ftp://192.168.4.254/ceph/rhceph-2.0-rhel-7-x86_64/OSD >> /etc/yum.repos.d/$yumname
echo enable=1 >> /etc/yum.repos.d/$yumname
echo [tools] >> /etc/yum.repos.d/$yumname
echo name=tools >> /etc/yum.repos.d/$yumname
echo baseurl=ftp://192.168.4.254/ceph/rhceph-2.0-rhel-7-x86_64/Tools >> /etc/yum.repos.d/$yumname
echo enabled=1 >> /etc/yum.repos.d/$yumname
yum clean all
yum repolist
ssh-keygen -f /root/.ssh/id_rsa -N ''
echo "进行免密登入设置"
sleep 1
read -p "请输入4网段的IP尾号：" weihao
for i in $weihao
do
        ssh-copy-id 192.168.4.$i
done
echo "正在拷贝yum仓库 /etc/hosts   /etc/chrony.conf"
for i in $weihao
do
        scp /etc/yum.repos.d/192.168.4.254_rhel7.repo root@192.168.4.$i:/etc/yum.repos.d/
        scp /etc/hosts  root@192.168.4.$i:/etc/
        scp /etc/chrony.conf  root@192.168.4.$i:/etc/
done
yum -y install ceph-deploy
mkdir ceph
cd ceph
read -p "正在创建ceph集群配置，输入虚拟机的名称(多台以空格格开)：" name
  for m in $name
                do
                echo $m >> name.txt
                done
        for o in `cat name.txt`
        do
        ceph-deploy new $o
        ceph-deploy install $o
        ceph-deploy admin $o
        done
echo "即将初始化所有节点的mon服务..."
sleep 1
ceph-deploy mon create-initial
read -p "正在磁盘分区与分区归属的操作，请输入你要远程的机子名(本机名不用输入):" name2
        for n in $name2
        do
        echo $n >> name2.txt
        done
                for f in `cat name2.txt`
                do
                ssh $f  parted  /dev/vdb  mklabel  gpt
                ssh $f  parted  /dev/vdb  mkpart primary  1M  50%
                ssh $f  parted  /dev/vdb  mkpart primary  50%  100%
                ssh $f  chown  ceph.ceph  /dev/vdb1
                ssh $f  chown  ceph.ceph  /dev/vdb2
                ssh $f  echo chown ceph.ceph /dev/vdb? >> /etc/rc.d/rc.local
                done
echo "初始化磁盘"
        for o in `cat name.txt`
        do
        ceph-deploy disk zap $o:vdc  $o:vdd
        done
echo "创建OSD存储空间"
                for o in `cat name.txt`
                do
                ceph-deploy osd create $o:vdc:/dev/vdb1 $o:vdd:/dev/vdb2
                done
                        for k in `cat name.txt`
                        do
                        ssh root@$k "systemctl restart chronyd"
                        done
ceph -s
#########该脚本可能会出现找不到keyring文件错误  执行完脚本之后手动ceph-deploy admin node* 即可 
#########该脚本是实验脚本 并非实体工作环境使用脚本
