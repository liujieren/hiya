
#!/bin/bash
lsblk
vgcreate systemvg /dev/vdb1
lvcreate -L 200MiB -n vo systemvg /dev/vdb1
lsblk
mkdir /vo
mkfs.ext3 /dev/systemvg/vo
echo "/dev/systemvg/vo /vo ext3 defaults 0  0" >> /etc/fstab
mount -a
lsblk
lvextend -L 300MiB /dev/systemvg/vo /dev/vdb1
resize2fs /dev/systemvg/vo
lsblk
vgcreate datastore -s 16MiB /dev/vdb2
lvcreate -l 50 -n database datastore
mkfs.ext3 /dev/datastore/databash
mkdir /mnt/bash
echo "/dev/datastore/databash  /mnt/databash  ext3 defaults 0  0" >> /etc/fstab
echo "/dev/vdb3  swap  swap  defaults 0  0" >> /etc/fstab
mkswap /dev/vdb3
swapon -a
swapon -s
moung -a
groupadd adminuser
useradd -G adminuser natasha
useradd -G adminuser harry
useradd -s /sbin/nologin sarah
echo flectrag | passwd --stdin natasha
echo flectrag | passwd --stdin harry
echo flectrag | passwd --stdin sarah
mkdir -p /home/admins
chown :adminuser /home/admins
chmod 770 /home/admins
ls -ld /home/admins
useradd -u 3456 alex
echo flectrag | passwd --stdin alex
