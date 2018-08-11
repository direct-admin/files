#!/bin/sh	
##########################################################
##     Subdomain Script                                 ##
##                                                      ##
##     Version: 1.0           ( 2016/09/18  by duc5e )  ##
##                                                      ##
##     use Centos 6 - 64bit                             ##
##                                                      ##
##########################################################

ARCH_CHECK=$(eval uname -m)

E_ARCH=51
E_NOYUM=52
E_NOSUPPORT=53
E_NOTROOT=85

C_OK='\E[47;34m'"\033[1m OK \033[0m\n"
C_NO='\E[47;31m'"\033[1m NO \033[0m\n"

clear

##### Check if user is root. #####
if [ "$UID" -ne "0" ] ; then
	echo -en "Installing as \"root\"        " $C_NO
	echo -e "\a\nYou must be \"root\" to install Subdomain Registration Script.\n\nAborting ...\n"
	exit $E_NOTROOT
else
	echo -en "Installing as \"root\"           " $C_OK
fi

##### Check if OS is RHEL/CENTOS/FEDORA. #####
if [ ! -f /etc/redhat-release ] ; then
	echo -en "Operating System supported   " $C_NO
	echo -e "\a\nSorry, only CentOS is supported by Subdomain Registration Script at this time.\n\nAborting ...\n"
	exit $E_NOSUPPORT
else
	echo -en "Operating System supported     " $C_OK
fi

##### Check if yum is installed. #####
if ! [ -f /usr/sbin/yum ] && ! [ -f /usr/bin/yum ] ; then
	echo -en "Yum installed               " $C_NO
	echo -e "\a\nThe installer requires YUM to continue. Please install it and try again.\nAborting ...\n"
	exit $E_NOYUM
else
	echo -en "Yum installed                  " $C_OK
fi

##### Check if OS is 64bit. ##### 
if [ "$ARCH_CHECK" == "x86_64" ] ; then
    echo -en "Architecture supported ($ARCH_CHECK)" $C_OK
else	
    echo -en "\aArchitecture supported ($ARCH_CHECK)" $C_NO "\n"
    echo -e "Your OS architecture ($ARCH_CHECK) is NOT officially supported yet."
	echo -e "Aborting ...\n"
    exit $E_ARCH
fi

yesno=n;

while [ "$yesno" = "n" ];
do
{
	echo "";
	echo "example : admin@fpt.ovh";
	echo -n "Please enter your emailadres for system mail : ";
	read EMAILADDRESS1;

HOSTNAME1=`hostname --fqdn`;	
	
	echo "";
	echo "";
	echo -e "Please enter your hostname \(fpt.ovh\)";
	echo "It must be a Fully Qualified Domain Name";
	echo "Do not enter http:// or www";
	echo "example : fpt.ovh";
	echo -n "Enter your hostname (FQDN) : [$HOSTNAME1]";
	read DOMAINNAME1;

if [ "$DOMAINNAME1" == "" ] ; then
DOMAINNAME1=$HOSTNAME1;
fi

	echo "";	
	echo "example : noreply@fpt.ovh";
	echo -n "Please enter your emailadres for noreply : [noreply@$DOMAINNAME1] ";
	read EMAILADDRESS2;

if [ "$EMAILADDRESS2" == "" ] ; then
EMAILADDRESS2=noreply@$DOMAINNAME1;
fi

HOSTNAME2=`hostname --short`;

	echo "";
	echo "";
	echo -e "Please enter your hostname without domain extension. \(domain\)";
	echo "Do not enter http:// or www or .com";
	echo "example : domain";
	echo -n "Enter your domain without extension : [$HOSTNAME2]";
	read DOMAINNAME2;

if [ "$DOMAINNAME2" == "" ] ; then
DOMAINNAME2=$HOSTNAME2;
fi	

HOSTNAME3=.`hostname -d`;
	
	echo "";
	echo "";
	echo -e "Please enter your hostname domain extension. \(.com\)";
	echo "Do not enter http:// or www or domain";
	echo "Please include dot on the begin";
	echo "example : .com";
	echo -n "Enter your domain extension : [$HOSTNAME3] ";
	read DOMAINNAME3;
	
if [ "$DOMAINNAME3" == "" ] ; then
DOMAINNAME3=$HOSTNAME3;
fi	

IPADDRESS1=`hostname -i`;
	
	echo "";
	echo "";
	echo "The following IPs were found.";
	echo "Please enter the ipaddress you wish to use:";
	DIP=`/sbin/ifconfig $i | grep 'inet addr:' | cut -d: -f2 | cut -d\  -f1`;
	echo "$DIP";    
	echo "";
	echo -n "Enter server ipaddress : [$IPADDRESS1]";
	read IP1;

if [ "$IP1" == "" ] ; then
IP1=$IPADDRESS1;
fi

NSNAME1=ns1.$DOMAINNAME1;
SOAEMAIL1=admin.$DOMAINNAME1;	

clear;
	echo "";
	echo "";
	echo "Emailaddress : $EMAILADDRESS1";
	echo "noreply mail : $EMAILADDRESS2";
	echo "Hostname : $DOMAINNAME1";
	echo "Domainname : $DOMAINNAME2$DOMAINNAME3";
	echo "Nameserver : $NSNAME1";
	echo "Server IP : $IP1";
	echo "";
	echo -n "Is this correct? (y,n) : ";
	read yesno;
}
done;

##### Start install #####
### Load GPG Keys for Centos ###
rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS*

##### Install Epel Repo for Mcript and 7zip #####
### Load GPG Keys for Epel ###
wget https://fpt.ovh/domain/0608B895.txt
mv 0608B895.txt /etc/pki/rpm-gpg/RPM-GPG-KEY-EPEL-6
rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-EPEL-6
### Install Repo files for Epel ###
rpm -ivh https://fpt.ovh/domain/epel-release-6-8.noarch.rpm
rpm -ivh https://fpt.ovh/domain/remi-release-6.rpm

##### Install Remi Repo for PHP 5.5 and Mysql 5.5 #####
### Load GPG Keys for Remi ###
rpm --import https://fpt.ovh/domain/RPM-GPG-KEY-remi

### Remove Bind ###
yum -y remove bind*

### Update Centos to last version #####
yum -y upgrade

##### Install HTTP + tools #####
yum -y install httpd perl.x86_64 wget nano p7zip sendmail zip unzip

chkconfig --levels 235 httpd on

##### Install MySQL #####
yum -y install mysql mysql-server --enablerepo=remi

##### Install PHP #####
yum -y install php php-common php-mysql gd php-gd php-mbstring mcrypt php-mcrypt --enablerepo=remi

##### Install Monshouwer Repo for Powerdns 3.? #####

##### Install Powerdns and 7zip #####
yum -y install pdns pdns-backend-mysql

chkconfig --levels 235 pdns on

##### Making my.cnf file #####
PHPMYADMIN_CONF=my.cnf
echo "[mysqld]"   > $PHPMYADMIN_CONF;
echo "datadir=/var/lib/mysql"   >> $PHPMYADMIN_CONF;
echo "socket=/var/lib/mysql/mysql.sock"   >> $PHPMYADMIN_CONF;
echo "user=mysql"   >> $PHPMYADMIN_CONF;
echo ""   >> $PHPMYADMIN_CONF;
echo "# Disabling symbolic-links is recommended to prevent assorted security risks"   >> $PHPMYADMIN_CONF;
echo "symbolic-links=0"   >> $PHPMYADMIN_CONF;
echo ""   >> $PHPMYADMIN_CONF;
echo "innodb=OFF"   >> $PHPMYADMIN_CONF;
echo "default_storage_engine=MyISAM"   >> $PHPMYADMIN_CONF;
echo ""   >> $PHPMYADMIN_CONF;
echo "[mysqld_safe]"   >> $PHPMYADMIN_CONF;
echo "log-error=/var/log/mysqld.log"   >> $PHPMYADMIN_CONF;
echo "pid-file=/var/run/mysqld/mysqld.pid"   >> $PHPMYADMIN_CONF;
echo ""   >> $PHPMYADMIN_CONF;

cp /etc/my.cnf /etc/my.cnf.backup

cp my.cnf /etc/my.cnf ;

##### Starting MySQL #####
service mysqld start

chkconfig --levels 235 mysqld on

##### Making Passwords and Date #####
DB_ROOT_PASS=`perl -le'print map+(A..Z,a..z,0..9)[rand 62],0..19'`;

DB_POWERDNS_USER1_PASS=`perl -le'print map+(A..Z,a..z,0..9)[rand 62],0..19'`;

DATE1=`date +%Y%m%d%H`;
DATE2=`date +%s`;

DB_ROOT_USER1_NAME=admin;
DB_ROOT_USER1_PASS=`perl -le'print map+(A..Z,a..z,0..9)[rand 62],0..5'`;

##### Setup MySQL Root Password #####
mysqladmin -u root password $DB_ROOT_PASS > mysqladmin.log;

##### Making mysqlinput.txt file #####
MYSQLIN=mysqlinput.txt
echo "CREATE DATABASE powerdnsdata1;"   > $MYSQLIN;
echo "USE powerdnsdata1;"   >> $MYSQLIN;
echo "DROP USER '';"   >> $MYSQLIN;
echo "FLUSH PRIVILEGES;"   >> $MYSQLIN;
echo ""   >> $MYSQLIN;
echo ""   >> $MYSQLIN;
echo "CREATE TABLE cryptokeys"   >> $MYSQLIN;
echo "("   >> $MYSQLIN;
echo "id			INT auto_increment,"   >> $MYSQLIN;
echo "domain_id     INT NOT NULL,"   >> $MYSQLIN;
echo "flags			INT NOT NULL,"   >> $MYSQLIN;
echo "active		BOOL,"   >> $MYSQLIN;
echo "content		TEXT,"   >> $MYSQLIN;
echo "primary key(id)"   >> $MYSQLIN;
echo ") ENGINE=MyISAM;"   >> $MYSQLIN;
echo ""   >> $MYSQLIN;
echo "create index domainidindex on cryptokeys(domain_id); "   >> $MYSQLIN;
echo ""   >> $MYSQLIN;
echo ""   >> $MYSQLIN;
echo "CREATE TABLE domainmetadata"   >> $MYSQLIN;
echo "("   >> $MYSQLIN;
echo "id		 	INT	auto_increment,"   >> $MYSQLIN;
echo "domain_id  	INT	NOT NULL,"   >> $MYSQLIN;
echo "kind		 	VARCHAR(16),"   >> $MYSQLIN;
echo "content		TEXT,"   >> $MYSQLIN;
echo "primary key(id)"   >> $MYSQLIN;
echo ") ENGINE=MyISAM;"   >> $MYSQLIN;
echo ""   >> $MYSQLIN;
echo "create index domainmetaidindex on domainmetadata(domain_id); "   >> $MYSQLIN;
echo ""   >> $MYSQLIN;
echo ""   >> $MYSQLIN;
echo "CREATE TABLE domains"   >> $MYSQLIN;
echo "("   >> $MYSQLIN;
echo "id              		INT          	AUTO_INCREMENT,"   >> $MYSQLIN;
echo "name            		VARCHAR(255) 	NOT NULL,"   >> $MYSQLIN;
echo "master          		VARCHAR(128) 	DEFAULT NULL,"   >> $MYSQLIN;
echo "last_check      		INT          	DEFAULT NULL,"   >> $MYSQLIN;
echo "type            		VARCHAR(6)   	NOT NULL,"   >> $MYSQLIN;
echo "notified_serial 		INT          	DEFAULT NULL,"   >> $MYSQLIN;
echo "account         		VARCHAR(40)  	DEFAULT NULL,"   >> $MYSQLIN;
echo "PRIMARY KEY (id)"   >> $MYSQLIN;
echo ") ENGINE=MyISAM;"   >> $MYSQLIN;
echo ""   >> $MYSQLIN;
echo "CREATE UNIQUE INDEX name_index ON domains(name);"   >> $MYSQLIN;
echo ""   >> $MYSQLIN;
echo "INSERT INTO domains (id, name, master, last_check, type, notified_serial, account) VALUES"   >> $MYSQLIN;
echo "(1, '$DOMAINNAME1', NULL, NULL, 'MASTER', $DATE1, NULL);"   >> $MYSQLIN;
echo ""   >> $MYSQLIN;
echo ""   >> $MYSQLIN;
echo "CREATE TABLE records"   >> $MYSQLIN;
echo "("   >> $MYSQLIN;
echo "id              		INT          	AUTO_INCREMENT,"   >> $MYSQLIN;
echo "domain_id       		INT          	DEFAULT NULL,"   >> $MYSQLIN;
echo "name            		VARCHAR(255) 	DEFAULT NULL,"   >> $MYSQLIN;
echo "type            		VARCHAR(10) 	DEFAULT NULL,"   >> $MYSQLIN;
echo "content         		VARCHAR(64000) 	DEFAULT NULL,"   >> $MYSQLIN;
echo "ttl             		INT          	DEFAULT NULL,"   >> $MYSQLIN;
echo "prio            		INT          	DEFAULT NULL,"   >> $MYSQLIN;
echo "change_date     		INT          	DEFAULT NULL,"   >> $MYSQLIN;
echo "ordername       		VARCHAR(255) 	DEFAULT NULL,"   >> $MYSQLIN;
echo "auth            		BOOL,						 "   >> $MYSQLIN;
echo "domainid		  		INT          	DEFAULT NULL,"   >> $MYSQLIN;
echo "PRIMARY KEY(id)"   >> $MYSQLIN;
echo ") ENGINE=MyISAM;"   >> $MYSQLIN;
echo ""   >> $MYSQLIN;
echo "CREATE INDEX rec_name_index ON records(name);"   >> $MYSQLIN;
echo "CREATE INDEX nametype_index ON records(name,type);"   >> $MYSQLIN;
echo "CREATE INDEX domain_id ON records(domain_id);"   >> $MYSQLIN;
echo "CREATE INDEX orderindex ON records(ordername);"   >> $MYSQLIN;
echo ""   >> $MYSQLIN;
echo ""   >> $MYSQLIN;
echo "INSERT INTO records (id, domain_id, name, type, content, ttl, prio, change_date, ordername, auth, domainid) VALUES"   >> $MYSQLIN;
echo "(1, 1, '$DOMAINNAME1', 'SOA', '$NSNAME1 $SOAEMAIL1 $DATE1 14400 3600 604800 7200', 86400, 0, $DATE2, '', 1, 0),"   >> $MYSQLIN;
echo "(2, 1, '$DOMAINNAME1', 'A', '$IP1', 86400, 0, $DATE2, '', 1, 0),"   >> $MYSQLIN;
echo "(3, 1, '*.$DOMAINNAME1', 'A', '$IP1', 86400, 0, $DATE2, '*', 1, 0),"   >> $MYSQLIN;
echo "(4, 1, 'www.$DOMAINNAME1', 'CNAME', '$DOMAINNAME1', 86400, 0, $DATE2, 'www', 1, 0),"   >> $MYSQLIN;
echo "(5, 1, 'ns1.$DOMAINNAME1', 'A', '$IP1', 86400, 0, $DATE2, 'ns1', 1, 0),"   >> $MYSQLIN;
echo "(6, 1, 'ns2.$DOMAINNAME1', 'A', '$IP1', 86400, 0, $DATE2, 'ns2', 1, 0),"   >> $MYSQLIN;
echo "(7, 1, 'mail.$DOMAINNAME1', 'A', '$IP1', 86400, 0, $DATE2, 'mail', 1, 0),"   >> $MYSQLIN;
echo "(8, 1, '$DOMAINNAME1', 'NS', 'ns1.$DOMAINNAME1', 86400, 0, $DATE2, '', 1, 0),"   >> $MYSQLIN;
echo "(9, 1, '$DOMAINNAME1', 'NS', 'ns2.$DOMAINNAME1', 86400, 0, $DATE2, '', 1, 0),"   >> $MYSQLIN;
echo "(10, 1, '$DOMAINNAME1', 'MX', 'mail.$DOMAINNAME1', 86400, 10, $DATE2, '', 1, 0),"   >> $MYSQLIN;
echo "(11, 1, '$DOMAINNAME1', 'TXT', 'v=spf1 a mx ip4:$IP1 ~all', 86400, 0, $DATE2, '', 1, 0);"   >> $MYSQLIN;
echo ""   >> $MYSQLIN;
echo ""   >> $MYSQLIN;
echo "CREATE TABLE supermasters"   >> $MYSQLIN;
echo "("   >> $MYSQLIN;
echo "ip              		VARCHAR(25)  	NOT NULL,"   >> $MYSQLIN;
echo "nameserver      		VARCHAR(255) 	NOT NULL,"   >> $MYSQLIN;
echo "account         		VARCHAR(40)  	DEFAULT NULL"   >> $MYSQLIN;
echo ") ENGINE=MyISAM;"   >> $MYSQLIN;
echo ""   >> $MYSQLIN;
echo ""   >> $MYSQLIN;
echo "CREATE TABLE tsigkeys"   >> $MYSQLIN;
echo "("   >> $MYSQLIN;
echo "id			INT auto_increment,"   >> $MYSQLIN;
echo "name			VARCHAR(255),"   >> $MYSQLIN;
echo "algorithm		VARCHAR(50),"   >> $MYSQLIN;
echo "secret		VARCHAR(255),"   >> $MYSQLIN;
echo "primary key(id)"   >> $MYSQLIN;
echo ") ENGINE=MyISAM;"   >> $MYSQLIN;
echo ""   >> $MYSQLIN;
echo "create unique index namealgoindex on tsigkeys(name, algorithm);"   >> $MYSQLIN;
echo ""   >> $MYSQLIN;
echo ""   >> $MYSQLIN;
echo "CREATE DATABASE domaindata1;"   >> $MYSQLIN;
echo "USE domaindata1;"   >> $MYSQLIN;
echo ""   >> $MYSQLIN;
echo ""   >> $MYSQLIN;
echo "CREATE TABLE domains ("   >> $MYSQLIN;
echo "id					int(11)			NOT NULL AUTO_INCREMENT,"   >> $MYSQLIN;
echo "subdomainname1		varchar(60)		NOT NULL,"   >> $MYSQLIN;
echo "domainname1			varchar(255)	NOT NULL,"   >> $MYSQLIN;
echo "userid				int(11)			NOT NULL,"   >> $MYSQLIN;
echo "domainlock1			int(1)			NOT NULL DEFAULT '0',"   >> $MYSQLIN;
echo "nameserver1			varchar(64)		NOT NULL,"   >> $MYSQLIN;
echo "nameserver2			varchar(64)		NOT NULL,"   >> $MYSQLIN;
echo "ipaddress1			varchar(64)		NOT NULL,"   >> $MYSQLIN;
echo "ipaddress2			varchar(64)		NOT NULL,"   >> $MYSQLIN;
echo "url1					varchar(150)	NOT NULL,"   >> $MYSQLIN;
echo "googletxt				varchar(70)		NOT NULL,"   >> $MYSQLIN;
echo "microsoftmx			varchar(50)		NOT NULL,"   >> $MYSQLIN;
echo "service1				varchar(64) 	NOT NULL,"   >> $MYSQLIN;
echo "date1					date			NOT NULL,"   >> $MYSQLIN;
echo "time1					time			NOT NULL,"   >> $MYSQLIN;
echo "PRIMARY KEY (id),"   >> $MYSQLIN;
echo "UNIQUE KEY subdomainname1 (subdomainname1)"   >> $MYSQLIN;
echo ") ENGINE=MyISAM DEFAULT CHARSET=utf8 AUTO_INCREMENT=1 ;"   >> $MYSQLIN;
echo ""   >> $MYSQLIN;
echo ""   >> $MYSQLIN;
echo "CREATE TABLE data1 ("   >> $MYSQLIN;
echo "id 					int(11)			NOT NULL AUTO_INCREMENT,"   >> $MYSQLIN;
echo "data					varchar(10)		NOT NULL,"   >> $MYSQLIN;
echo "userid				int(11)			NOT NULL,"   >> $MYSQLIN;
echo "domainid				int(11)			NOT NULL,"   >> $MYSQLIN;
echo "date					date			NOT NULL,"   >> $MYSQLIN;
echo "PRIMARY KEY (id)"   >> $MYSQLIN;
echo ") ENGINE=MyISAM DEFAULT CHARSET=utf8 AUTO_INCREMENT=1 ;"   >> $MYSQLIN;
echo ""   >> $MYSQLIN;
echo ""   >> $MYSQLIN;
echo "CREATE TABLE options ("   >> $MYSQLIN;
echo "id					int(11)			NOT NULL AUTO_INCREMENT,"   >> $MYSQLIN;
echo "sitetitle				varchar(150)	NOT NULL DEFAULT '',"   >> $MYSQLIN;
echo "adminemail			varchar(65) 	NOT NULL DEFAULT '',"   >> $MYSQLIN;
echo "noreplyemail			varchar(65) 	NOT NULL,"   >> $MYSQLIN;
echo "maindomain			varchar(65) 	NOT NULL DEFAULT '',"   >> $MYSQLIN;
echo "maindomain2ext		varchar(65) 	NOT NULL,"   >> $MYSQLIN;
echo "maindomainext			varchar(15) 		NOT NULL,"   >> $MYSQLIN;
echo "configmaxdomains		varchar(2) 		NOT NULL,"   >> $MYSQLIN;
echo "minlength				char(2) 		NOT NULL,"   >> $MYSQLIN;
echo "maxlength				char(2) 		NOT NULL,"   >> $MYSQLIN;
echo "dnssoa1 				varchar(150) 	NOT NULL,"   >> $MYSQLIN;
echo "dnssoa2 				varchar(50) 	NOT NULL,"   >> $MYSQLIN;
echo "PRIMARY KEY (id)"   >> $MYSQLIN;
echo ") ENGINE=MyISAM  DEFAULT CHARSET=utf8 AUTO_INCREMENT=2 ;"   >> $MYSQLIN;
echo ""   >> $MYSQLIN;
echo "INSERT INTO options (id, sitetitle, adminemail, noreplyemail, maindomain, maindomain2ext, maindomainext, configmaxdomains, minlength, maxlength, dnssoa1, dnssoa2) VALUES"   >> $MYSQLIN;
echo "(1, '$DOMAINNAME1', '$EMAILADDRESS1', '$EMAILADDRESS2', '$DOMAINNAME1', '$DOMAINNAME2', '$DOMAINNAME3', '5', '3', '60', '$NSNAME1 $SOAEMAIL1', '14400 3600 604800 7200');"   >> $MYSQLIN;
echo ""   >> $MYSQLIN;
echo ""   >> $MYSQLIN;
echo "CREATE TABLE users ("   >> $MYSQLIN;
echo "id 					int(40) 		NOT NULL AUTO_INCREMENT,"   >> $MYSQLIN;
echo "logindate				date 			NOT NULL,"   >> $MYSQLIN;
echo "username1				varchar(40) 	NOT NULL,"   >> $MYSQLIN;
echo "password1				varchar(100) 	NOT NULL,"   >> $MYSQLIN;
echo "activationcode1		varchar(10) 	NOT NULL,"   >> $MYSQLIN;
echo "fullname1 			varchar(70) 	NOT NULL,"   >> $MYSQLIN;
echo "streetnumber1 		varchar(70) 	NOT NULL,"   >> $MYSQLIN;
echo "postcode1 			varchar(40) 	NOT NULL,"   >> $MYSQLIN;
echo "city1 				varchar(50) 	NOT NULL,"   >> $MYSQLIN;
echo "country1 				varchar(40) 	NOT NULL,"   >> $MYSQLIN;
echo "email1 				varchar(70) 	NOT NULL,"   >> $MYSQLIN;
echo "ipaddress1 			varchar(40) 	NOT NULL,"   >> $MYSQLIN;
echo "maxdomains1 			int(11)			NOT NULL,"   >> $MYSQLIN;
echo "createdate1 			date			NOT NULL,"   >> $MYSQLIN;
echo "createtime1 			time			NOT NULL,"   >> $MYSQLIN;
echo "date1 				date			NOT NULL,"   >> $MYSQLIN;
echo "time1 				time			NOT NULL,"   >> $MYSQLIN;
echo "PRIMARY KEY (id)"   >> $MYSQLIN;
echo ") ENGINE=MyISAM DEFAULT CHARSET=utf8 AUTO_INCREMENT=1 ;"   >> $MYSQLIN;
echo ""   >> $MYSQLIN;
echo ""   >> $MYSQLIN;
echo "CREATE USER 'powerdnsuser1'@'localhost' IDENTIFIED BY '$DB_POWERDNS_USER1_PASS';"   >> $MYSQLIN;
echo "GRANT ALL ON powerdnsdata1.* TO 'powerdnsuser1'@'localhost';"   >> $MYSQLIN;
echo "GRANT ALL ON domaindata1.* TO 'powerdnsuser1'@'localhost';"   >> $MYSQLIN;
echo "GRANT ALL PRIVILEGES ON *.* TO $DB_ROOT_USER1_NAME@localhost IDENTIFIED BY '$DB_ROOT_USER1_PASS' WITH GRANT OPTION;"   >> $MYSQLIN;
echo ""   >> $MYSQLIN;
echo ""   >> $MYSQLIN;

##### Making mysqlrootpw.txt file #####
echo "$DB_ROOT_PASS" >mysqlrootpw.txt;

##### Making yourmysqllogin.txt file #####
YOURMYSQLLOGIN_TXT=yourmysqllogin.txt;
echo "phpmyadmin : http://www.$DOMAINNAME1/phpMyAdmin/" > $YOURMYSQLLOGIN_TXT;
echo "username : $DB_ROOT_USER1_NAME" >>$YOURMYSQLLOGIN_TXT;
echo "password : $DB_ROOT_USER1_PASS" >>$YOURMYSQLLOGIN_TXT;

##### Setup MySQL database #####
mysql -u root --password=$DB_ROOT_PASS < mysqlinput.txt

##### Making pdns.conf file #####
PDNS_CONF=pdns.conf
echo "setuid=pdns"   > $PDNS_CONF;
echo "setgid=pdns"   >> $PDNS_CONF;
echo "launch=bind"   >> $PDNS_CONF;
echo ""   >> $PDNS_CONF;

echo "launch=gmysql"   >> $PDNS_CONF;
echo "gmysql-host=localhost"   >> $PDNS_CONF;
echo "gmysql-dnssec"   >> $PDNS_CONF;
echo "gmysql-user=powerdnsuser1"   >> $PDNS_CONF;
echo "gmysql-password=$DB_POWERDNS_USER1_PASS"   >> $PDNS_CONF;
echo "gmysql-dbname=powerdnsdata1"   >> $PDNS_CONF;


cp /etc/pdns/pdns.conf /etc/pdns/pdns.conf.backup

cp pdns.conf /etc/pdns/pdns.conf

##### Starting Powerdns #####
service pdns restart

##### Get phpMyAdmin 4.2.2 (20-05-2014) DD-MM-YYYY #####
wget https://fpt.ovh/domain/phpMyAdmin.zip
unzip phpMyAdmin.zip
mv phpMyAdmin /var/www/html/

##### Making vars.php file #####
VARS_CONF=vars.php
echo "<?php"   > $VARS_CONF;
echo "if(define('liteB105', false)) die('Hacking System');"   >> $VARS_CONF;
echo "###########################################################"   >> $VARS_CONF;
echo "#### vars.php - some variables have to be set by admin ####"   >> $VARS_CONF;
echo "###########################################################"   >> $VARS_CONF;
echo ""   >> $VARS_CONF;
echo "// hostname of the server"   >> $VARS_CONF;
echo "\$mysql_host = 'localhost';"   >> $VARS_CONF;
echo ""   >> $VARS_CONF;
echo "// mysql-username"   >> $VARS_CONF;
echo "\$mysql_username1 = 'powerdnsuser1';"   >> $VARS_CONF;
echo ""   >> $VARS_CONF;
echo "// mysql-password"   >> $VARS_CONF;
echo "\$mysql_passwd1 = '$DB_POWERDNS_USER1_PASS';"   >> $VARS_CONF;
echo ""   >> $VARS_CONF;
echo "// the name of the database"   >> $VARS_CONF;
echo "\$mysql_dbase1 = 'domaindata1';"   >> $VARS_CONF;
echo ""   >> $VARS_CONF;
echo "// id from your domain (powerdns option)"   >> $VARS_CONF;
echo "\$powerdns_domain_id1 = '1';"   >> $VARS_CONF;
echo ""   >> $VARS_CONF;
echo "\$server_ipaddress = '$IP1';"   >> $VARS_CONF;
echo ""   >> $VARS_CONF;
echo ""   >> $VARS_CONF;
echo "?>"   >> $VARS_CONF;

##### Install php script #####
wget https://fpt.ovh/duc.7z

7za x -r -o/var/www/html duc.7z >7za2.log

mkdir /var/www/html/settings

cp vars.php /var/www/html/settings/vars.php

chown -R apache:apache /var/www/html/*

##### Restart HTTP #####
service httpd restart

##### DNSSEC Powerdns #####
PDNSSEC1=`pdnssec secure-zone $DOMAINNAME1`;
PDNSSEC2=`pdnssec rectify-zone $DOMAINNAME1`;
PDNSSEC3=`pdnssec show-zone $DOMAINNAME1`;

DNSSEC_CONF=dnssec.txt
echo "$PDNSSEC1";
echo "";
echo "$PDNSSEC2";
echo "";
echo "$PDNSSEC3";
echo "";
echo "$PDNSSEC3" > $DNSSEC_CONF;


##### Removing config files #####
rm -rf my.cnf
rm -rf mysqlinput.txt
rm -rf mysqladmin.log
rm -rf pdns.conf
rm -rf phpmyadmin.conf
rm -rf vars.php
rm -rf 7za1.log
rm -rf 7za2.log
rm -rf pdns-server.el6.repo

##### Removing phpMyAdmin install files #####
rm -rf phpMyAdmin.zip

##### Removing install.sh #####
rm -rf install.sh

	rm -rf /etc/sysconfig/iptables
	echo "*filter" >> /etc/sysconfig/iptables
	echo ":INPUT ACCEPT [0:0]" >> /etc/sysconfig/iptables
	echo ":FORWARD ACCEPT [0:0]" >> /etc/sysconfig/iptables
	echo ":INPUT ACCEPT [0:0]" >> /etc/sysconfig/iptables
	echo ":INPUT ACCEPT [0:0]" >> /etc/sysconfig/iptables
	echo ":OUTPUT ACCEPT [0:0]" >> /etc/sysconfig/iptables
	echo "-A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT" >> /etc/sysconfig/iptables
	echo "-A INPUT -p icmp -j ACCEPT" >> /etc/sysconfig/iptables
	echo "-A INPUT -i lo -j ACCEPT" >> /etc/sysconfig/iptables
	echo "-A INPUT -p tcp -m tcp --dport 21 -m conntrack --ctstate NEW,ESTABLISHED -j ACCEPT" >> /etc/sysconfig/iptables
	echo "-A INPUT -p tcp -m tcp --dport 20 -m conntrack --ctstate NEW,ESTABLISHED -j ACCEPT" >> /etc/sysconfig/iptables
	echo "-A OUTPUT -p tcp -m tcp --dport 21 -m conntrack --ctstate NEW,ESTABLISHED -j ACCEPT" >> /etc/sysconfig/iptables
	echo "-A OUTPUT -p tcp -m tcp --dport 20 -m conntrack --ctstate NEW,ESTABLISHED -j ACCEPT" >> /etc/sysconfig/iptables
	echo "-A INPUT -m state --state NEW -m tcp -p tcp --dport 22 -j ACCEPT" >> /etc/sysconfig/iptables
	echo "-A INPUT -p tcp -m state --state NEW -m tcp --dport 25 -j ACCEPT" >> /etc/sysconfig/iptables
	echo "-A INPUT -p tcp -m state --state NEW -m tcp --dport 80 -j ACCEPT" >> /etc/sysconfig/iptables
	echo "-A INPUT -p tcp -m state --state NEW -m tcp --dport 465 -j ACCEPT" >> /etc/sysconfig/iptables
	echo "-A INPUT -p tcp -m state --state NEW -m tcp --dport 443 -j ACCEPT" >> /etc/sysconfig/iptables
	echo "-A INPUT -p udp --dport 53 -j ACCEPT" >> /etc/sysconfig/iptables
	echo "-A INPUT -p tcp --dport 53 -j ACCEPT" >> /etc/sysconfig/iptables
	echo "-A INPUT -j REJECT --reject-with icmp-host-prohibited" >> /etc/sysconfig/iptables
	echo "-A FORWARD -j REJECT --reject-with icmp-host-prohibited" >> /etc/sysconfig/iptables
	echo "COMMIT" >> /etc/sysconfig/iptables
	echo "IPTABLES_MODULES=\"ip_conntrack_ftp\"" >> /etc/sysconfig/iptables-config
	service iptables restart

echo "" ;
echo "" ;
echo "Installation Complete.";
echo "" ;
echo "To access the database use" ;
echo "phpmyadmin : http://www.$DOMAINNAME1/phpMyAdmin/" ;
echo "username : $DB_ROOT_USER1_NAME" ;
echo "password : $DB_ROOT_USER1_PASS";
echo "" ;
echo "This information is also saved in the file yourmysqllogin.txt" ;
echo "" ;
echo "The MySql root password is saved in file mysqlrootpw.txt" ;
echo "DNSSEC keys are save to file dnssec.txt" ;
echo "" ;
echo "" ;
exit;
