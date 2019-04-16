#!/bin/bash


trap "echo TRAPed signal" HUP INT QUIT TERM

export DJANGO_SETTINGS_MODULE='settings'

CONTAINER_ALREADY_STARTED="CONTAINER_ALREADY_STARTED_PLACEHOLDER"
if [ -e $CONTAINER_ALREADY_STARTED ]; then
    echo "-- Not first container startup --"
else
	# Do this only for the first time the container
	# is started
    echo "-- First container startup --"

	#Add User and permissions
	OURUSER=atlas
	OURGROUP=${OURUSER}
	PREFIX=/usr/local/ironport
	name=eval_portal

	/bin/getent passwd atlas || /sbin/useradd -c "Atlas user" -M -d ${PREFIX}/${name} atlas
	PRODROOT=/usr/local/ironport/eval_portal
	mkdir -p /data/var/log/evalportal/
	touch /data/var/log/evalportal/evalportal.log
	chown -R ${OURUSER}:${OURGROUP}  /data/var/log/evalportal
	chmod -R 755 /data/var/log/evalportal/
	chcon -R system_u:object_r:httpd_log_t:s0 /data/var/log/evalportal/

	# Log directories.
	mkdir -p /data/var/log/httpd/order.ces.cisco.com
	chown -R ${OURUSER}:${OURGROUP}  /data/var/log/httpd/order.ces.cisco.com
	chmod 755 /data/var/log/httpd/order.ces.cisco.com
	chcon -R system_u:object_r:httpd_log_t:s0 /data/var/log/httpd/order.ces.cisco.com

    if [ $MODE == 'dev' ];then
        cp /usr/local/ironport/evalportal/apache/eval_portal_apache.conf /etc/httpd/conf.d/
        cp /usr/local/ironport/evalportal/apache/order.ces.cisco.com.key /etc/pki/tls/private/order.ces.cisco.com.key
        cp /usr/local/ironport/evalportal/apache/order.ces.cisco.com.crt /etc/pki/tls/certs/order.ces.cisco.com.crt
    else
        cp /usr/local/ironport/evalportal/apache/eval_portal_apache.conf /etc/httpd/conf.d/
        cp /configs/order.ces.cisco.com.key /etc/pki/tls/private/order.ces.cisco.com.key
        cp /configs/order.ces.cisco.com.crt /etc/pki/tls/certs/order.ces.cisco.com.crt
        cp /configs/settings.py /usr/local/ironport/evalportal/
        cp /configs/main.cf /etc/postfix/main.cf
    fi

	chmod -R 755 /usr/local/ironport/
	chown -R ${OURUSER}:${OURGROUP} /usr/local/ironport/
	chcon -R system_u:object_r:httpd_sys_rw_content_t:s0 /usr/local/ironport/evalportal/
fi

export DJANGO_SETTINGS_MODULE='settings'
python manage.py migrate

chmod -R 755 /usr/local/ironport/evalportal/db.sqlite3
chown ${OURUSER}:${OURGROUP} /usr/local/ironport/evalportal/db.sqlite3

# start Postfix service
/usr/sbin/postfix -c /etc/postfix start

# start service in foreground here
/usr/sbin/httpd -D FOREGROUND
if [ $? -eq 0 ];then
    touch $CONTAINER_ALREADY_STARTED
fi

echo "[hit enter key to exit] or run 'docker stop <container>'"
read


echo "exited $0"
