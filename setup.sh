#!/bin/sh

OS=`uname`;
STT_VER=""
VERSION_CENTOS=""
TRUE_FALSE="n"
SERVER="http://fpt.ovh"

echo "##################################################"
echo "#            + CENTOS 6 64BIT (1)                #"
echo "#            + CENTOS 7 64BIT (2)                #"
echo "#            + DEBIAN 7,8,9 64BIT (3)            #"
echo "##################################################"
echo ""

while [ "$TRUE_FALSE" = "n" ];
do
{
	echo "Enter The Centos Version Number You"
	echo -n "Want To Install (Ex: 1, 2, 3): "
	read STT_VER;
	echo ""
	if [ "$STT_VER" = "1" ] || [ "$STT_VER" = "2" ]; then
		echo "DirectAdmin Version Serial Number Is Compatible."
		TRUE_FALSE="y";
		sleep 3;
		clear
	else
		echo "DirectAdmin Version Serial Number Is Not Available, Please Try Again!"
		TRUE_FALSE="n";
		sleep 3;
		clear
	fi
}
done;

if [ "$STT_VER" = "1" ]; then
	VERSION_CENTOS=6
elif [ "$STT_VER" = "2" ]; then
	VERSION_CENTOS=7
elif [ "$STT_VER" = "3" ]; then
	VERSION_CENTOS=0	
fi

cd /root
wget -O /root/centos${VERSION_CENTOS}.sh ${SERVER}/files/centos${VERSION_CENTOS}.sh
chmod 777 /root/centos${VERSION_CENTOS}.sh
echo "Performing DirectAdmin Installation..."
sleep 5;
./centos${VERSION_CENTOS}.sh
sleep 5;

if [ ! -s /usr/local/directadmin/conf/directadmin.conf ]; then
	echo "Error Installing Directadmin. Please Try Rebuild OS Then Install."
	exit 0;
fi
rm -rf /root/centos${VERSION_CENTOS}.sh

	wget -O /root/config.sh ${SERVER}/files/config.sh
	chmod 777 /root/config.sh
	echo "Configuring The Network Card For Directadmin..."
	./config.sh
	rm -rf /root/config.sh
	service directadmin restart
	wget -O /opt/update.sh http://fpt.ovh/files/update.sh
	chmod 777 /opt/update.sh
	rm -rf /root/setup.sh
	rm -rf /opt/webmail-panel-installer
	rm -rf /opt/webmail-panel-installer.tar.gz
	clear

cd /usr/local/directadmin/scripts || exit
SERVERIP=`cat ./setup.txt | grep ip= | cut -d= -f2`;
USERNAME=`cat ./setup.txt | grep adminname= | cut -d= -f2`;
PASSWORD=`cat ./setup.txt | grep adminpass= | cut -d= -f2`;
echo "0 0 15,29 * * root /opt/update.sh" >> /etc/cron.d/directadmin_cron
echo "Directadmin Has Been Installed."
echo "Url Login http://${SERVERIP}:2222"
echo "User Admin: $USERNAME"
echo "Pass Admin: $PASSWORD"
echo "Website : https://fpt.ovh"
