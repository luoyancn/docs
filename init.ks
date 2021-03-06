# This is a kickstart for making a non-bootable container environment.
#
# Convert the result to a tarfile with
#
#   virt-tar-out -a fedora.qcow2 / - | bzip2 --best > fedora.tar.bz2
#
#
# This kickstart file is designed to be used with appliance-creator and
# may need slight modification for use with actual anaconda or other tools.
# We intend to target anaconda-in-a-vm style image building for F20, but
# not necessarily for containers -- that's yet to be worked out.
lang en_US.UTF-8
keyboard us
timezone --utc Etc/UTC
auth --useshadow --enablemd5
selinux --disabled
rootpw --lock --iscrypted locked
zerombr
clearpart --all
part / --size 1024 --fstype=ext4
# Repositories
repo --name=fedora --mirrorlist=https://mirrors.fedoraproject.org/metalink?repo=fedora-$releasever&arch=$basearch
repo --name=fedora-updates --mirrorlist=https://mirrors.fedoraproject.org/metalink?repo=updates-released-f$releasever&arch=$basearch
reboot
# Package list.
%packages --excludedocs
basesystem
bash
coreutils
cronie
curl
dhcp-client
dnf
dnf-yum
e2fsprogs
filesystem
glibc
grubby
hostname
initscripts
iproute
iputils
kbd
less
man-db
ncurses
openssh-clients
openssh-server
parted
passwd
plymouth
policycoreutils
procps-ng
rootfiles
rpm
selinux-policy-targeted
setup
shadow-utils
sudo
systemd
uboot-tools
util-linux
vim-minimal
# removed below
NetworkManager
NetworkManager-libnm
grubby
man-db
firewalld-filesystem
selinux-policy
selinux-policy-targeted
firewalld
ebtables
glib-networking
gsettings-desktop-schemas
libsoup
dhcp-client
initscripts
kbd
plymouth
plymouth-scripts
ppp
kbd-legacy
bind99-license
avahi-libs
avahi-autoipd
uboot-tools
dtc
libedit
openssh-clients
libproxy
libpipeline
libpcap
iproute
linux-atm-libs
hardlink
dracut
dhcp-libs
dbus-glib
dbus-python
python-firewall
python-slip-dbus
libgudev1
gobject-introspection
pygobject3-base
polkit-libs
cronie
cronie-noanacron
crontabs
iputils
trousers
dnsmasq
libdrm
dracut
bind99-libs
policycoreutils
kbd-misc
parted
passwd
uboot-tools
hwdata
libpciaccess
libdrm
dhcp-common
groff-base
less
hostname
libselinux-utils
libmodman
libnl3
libdaemon
plymouth-core-libs
libndp
procps-ng
libselinux-python
python-slip
kpartx
%end
%post --erroronfail
# setup systemd to boot to the right runlevel
echo -n "Setting default runlevel to multiuser text mode"
rm -f /etc/systemd/system/default.target
ln -s /lib/systemd/system/multi-user.target /etc/systemd/system/default.target
echo .
# create devices which appliance-creator does not
ln -s /proc/kcore /dev/core
mknod -m 660 /dev/loop0 b 7 0
mknod -m 660 /dev/loop1 b 7 1
rm -rf /dev/console
ln -s /dev/tty1 /dev/console
echo -n "Network fixes"
# initscripts don't like this file to be missing.
cat > /etc/sysconfig/network << EOF
NETWORKING=yes
NOZEROCONF=yes
EOF
# For cloud images, 'eth0' _is_ the predictable device name, since
# we don't want to be tied to specific virtual (!) hardware
rm -f /etc/udev/rules.d/70*
ln -s /dev/null /etc/udev/rules.d/80-net-name-slot.rules
# simple eth0 config, again not hard-coded to the build hardware
cat > /etc/sysconfig/network-scripts/ifcfg-eth0 << EOF
DEVICE="eth0"
BOOTPROTO="dhcp"
ONBOOT="yes"
TYPE="Ethernet"
EOF
# generic localhost names
cat > /etc/hosts << EOF
127.0.0.1   localhost localhost.localdomain localhost4 localhost4.localdomain4
::1         localhost localhost.localdomain localhost6 localhost6.localdomain6
EOF
echo .
# Because memory is scarce resource in most cloud/virt environments,
# and because this impedes forensics, we are differing from the Fedora
# default of having /tmp on tmpfs.
echo "Disabling tmpfs for /tmp."
systemctl mask tmp.mount
echo "Removing random-seed so it's not the same in every image."
rm -f /var/lib/random-seed
echo "Compressing cracklib."
gzip -9 /usr/share/cracklib/pw_dict.pwd
echo "Minimizing locale-archive."
localedef --list-archive | grep -v en_US | xargs localedef --delete-from-archive
mv /usr/lib/locale/locale-archive /usr/lib/locale/locale-archive.tmpl
/usr/sbin/build-locale-archive
# this is really kludgy and will be fixed with a better way of building
# these containers
mv /usr/share/locale/en /usr/share/locale/en_US /tmp
rm -rf /usr/share/locale/*
mv /tmp/en /tmp/en_US /usr/share/locale/
mv /usr/share/i18n/locales/en_US /tmp
rm -rf /usr/share/i18n/locales/*
mv /tmp/en_US /usr/share/i18n/locales/
echo '%_install_langs C:en:en_US:en_US.UTF-8' >> /etc/rpm/macros.imgcreate
echo "Removing extra packages."
rm -vf /etc/yum/protected.d/*
dnf -C -y remove NetworkManager --setopt="clean_requirements_on_remove=1"
dnf -C -y remove NetworkManager-libnm --setopt="clean_requirements_on_remove=1"
dnf -C -y remove grubby --setopt="clean_requirements_on_remove=1"
dnf -C -y remove man-db --setopt="clean_requirements_on_remove=1"
dnf -C -y remove firewalld-filesystem --setopt="clean_requirements_on_remove=1"
dnf -C -y remove selinux-policy --setopt="clean_requirements_on_remove=1"
dnf -C -y remove selinux-policy-targeted --setopt="clean_requirements_on_remove=1"
dnf -C -y remove firewalld --setopt="clean_requirements_on_remove=1"
dnf -C -y remove ebtables --setopt="clean_requirements_on_remove=1"
dnf -C -y remove glib-networking --setopt="clean_requirements_on_remove=1"
dnf -C -y remove gsettings-desktop-schemas --setopt="clean_requirements_on_remove=1"
dnf -C -y remove libsoup --setopt="clean_requirements_on_remove=1"
dnf -C -y remove dhcp-client --setopt="clean_requirements_on_remove=1"
dnf -C -y remove initscripts --setopt="clean_requirements_on_remove=1"
dnf -C -y remove kbd --setopt="clean_requirements_on_remove=1"
dnf -C -y remove plymouth --setopt="clean_requirements_on_remove=1"
dnf -C -y remove plymouth-scripts --setopt="clean_requirements_on_remove=1"
dnf -C -y remove ppp --setopt="clean_requirements_on_remove=1"
dnf -C -y remove kbd-legacy --setopt="clean_requirements_on_remove=1"
dnf -C -y remove bind99-license --setopt="clean_requirements_on_remove=1"
dnf -C -y remove avahi-libs --setopt="clean_requirements_on_remove=1"
dnf -C -y remove avahi-autoipd --setopt="clean_requirements_on_remove=1"
dnf -C -y remove uboot-tools --setopt="clean_requirements_on_remove=1"
dnf -C -y remove dtc --setopt="clean_requirements_on_remove=1"
dnf -C -y remove libedit --setopt="clean_requirements_on_remove=1"
dnf -C -y remove openssh-clients --setopt="clean_requirements_on_remove=1"
dnf -C -y remove libproxy --setopt="clean_requirements_on_remove=1"
dnf -C -y remove libpipeline --setopt="clean_requirements_on_remove=1"
dnf -C -y remove libpcap --setopt="clean_requirements_on_remove=1"
dnf -C -y remove iproute --setopt="clean_requirements_on_remove=1"
dnf -C -y remove linux-atm-libs --setopt="clean_requirements_on_remove=1"
dnf -C -y remove hardlink --setopt="clean_requirements_on_remove=1"
dnf -C -y remove dracut --setopt="clean_requirements_on_remove=1"
dnf -C -y remove dhcp-libs --setopt="clean_requirements_on_remove=1"
dnf -C -y remove dbus-glib --setopt="clean_requirements_on_remove=1"
dnf -C -y remove dbus-python --setopt="clean_requirements_on_remove=1"
dnf -C -y remove python-firewall --setopt="clean_requirements_on_remove=1"
dnf -C -y remove python-slip-dbus --setopt="clean_requirements_on_remove=1"
dnf -C -y remove libgudev1 --setopt="clean_requirements_on_remove=1"
dnf -C -y remove gobject-introspection --setopt="clean_requirements_on_remove=1"
dnf -C -y remove pygobject3-base --setopt="clean_requirements_on_remove=1"
dnf -C -y remove polkit-libs --setopt="clean_requirements_on_remove=1"
dnf -C -y remove cronie --setopt="clean_requirements_on_remove=1"
dnf -C -y remove cronie-noanacron --setopt="clean_requirements_on_remove=1"
dnf -C -y remove crontabs --setopt="clean_requirements_on_remove=1"
dnf -C -y remove iputils --setopt="clean_requirements_on_remove=1"
dnf -C -y remove trousers --setopt="clean_requirements_on_remove=1"
dnf -C -y remove dnsmasq --setopt="clean_requirements_on_remove=1"
dnf -C -y remove libdrm --setopt="clean_requirements_on_remove=1"
dnf -C -y remove dracut --setopt="clean_requirements_on_remove=1"
dnf -C -y remove bind99-libs --setopt="clean_requirements_on_remove=1"
dnf -C -y remove policycoreutils --setopt="clean_requirements_on_remove=1"
dnf -C -y remove kbd-misc --setopt="clean_requirements_on_remove=1"
dnf -C -y remove parted --setopt="clean_requirements_on_remove=1"
dnf -C -y remove passwd --setopt="clean_requirements_on_remove=1"
dnf -C -y remove uboot-tools --setopt="clean_requirements_on_remove=1"
dnf -C -y remove hwdata --setopt="clean_requirements_on_remove=1"
dnf -C -y remove libpciaccess --setopt="clean_requirements_on_remove=1"
dnf -C -y remove libdrm --setopt="clean_requirements_on_remove=1"
dnf -C -y remove dhcp-common --setopt="clean_requirements_on_remove=1"
dnf -C -y remove groff-base --setopt="clean_requirements_on_remove=1"
dnf -C -y remove less --setopt="clean_requirements_on_remove=1"
dnf -C -y remove hostname --setopt="clean_requirements_on_remove=1"
dnf -C -y remove libselinux-utils --setopt="clean_requirements_on_remove=1"
dnf -C -y remove libmodman --setopt="clean_requirements_on_remove=1"
dnf -C -y remove libnl3 --setopt="clean_requirements_on_remove=1"
dnf -C -y remove libdaemon --setopt="clean_requirements_on_remove=1"
dnf -C -y remove plymouth-core-libs --setopt="clean_requirements_on_remove=1"
dnf -C -y remove libndp --setopt="clean_requirements_on_remove=1"
dnf -C -y remove procps-ng --setopt="clean_requirements_on_remove=1"
dnf -C -y remove libselinux-python --setopt="clean_requirements_on_remove=1"
dnf -C -y remove python-slip --setopt="clean_requirements_on_remove=1"
dnf -C -y remove kpartx --setopt="clean_requirements_on_remove=1"
echo "Removing boot, since we don't need that."
rm -rf /boot/*
echo "Cleaning old yum repodata."
dnf clean all
rm -rf /var/lib/yum/yumdb/*
truncate -c -s 0 /var/log/yum.log
echo "Fixing SELinux contexts."
/usr/sbin/fixfiles -R -a restore
echo "Zeroing out empty space."
# This forces the filesystem to reclaim space from deleted files
dd bs=1M if=/dev/zero of=/var/tmp/zeros || :
rm -f /var/tmp/zeros
echo "(Don't worry -- that out-of-space error was expected.)"
%end
