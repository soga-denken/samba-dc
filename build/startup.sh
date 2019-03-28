#!/bin/bash
# this is startup script to initialize samba dc.

set -e

adminpass=$(cat /run/secrets/AdminPassSecret)
#echo "my pass: " ${adminpass}
# setup environmental variables
# unless required, all 

REALM="${netbios^^}.${domain^^}"
FDQN="${hostname,,}.${REALM,,}"
# print setting
echo "DC's IP: " ${ip}
echo "realm: " ${REALM}
echo "netbios: " ${netbios}
echo "DNS List: " ${dnslist}
echo "country: " ${country}
echo "company: " ${company}
echo "certificate is valid for:" ${certdays}



if [ ! -e /keys/${mykey} ]; then
    echo "certificate does not exists. generating..."
    # initialize openssl
    mkdir -p /keys
    openssl req -newkey rsa:2048 -keyout /keys/${mykey}              \
                -nodes -x509 -days ${certdays} -out /keys/${mycert}  \
                -subj "/C=${country}/ST=${state}/L=${city}/O=${company}/OU=${department}/CN=${FDQN}"
    chmod 600 /keys/${mykey}
else
    echo "key files already exist"
    ls /keys
fi

if [ ! -e /etc/samba/smb.conf ]; then

    # make a folder for backup
    if [ ! -e /backup ]; then
        mkdir -p /backup
    fi

    # run samba domain provisioning!
    echo "/etc/samba/smb.conf does not exists. generating..."
    samba-tool domain provision --use-rfc2307                       \
        --domain=${netbios^^}                                       \
        --realm=${REALM}                                            \
        --server-role=dc                                            \
        --dns-backend=SAMBA_INTERNAL                                \
        --adminpass=${adminpass}                                    \
        --option="wins support = yes"                               \
        --option="template shell = /bin/bash"                       \
        --option="tidmap_ldb:use rfc2307 = yes"                     \
        --option="winbind nss info = rfc2307"                       \
        --option="idmap config ${netbios^^}: unix_nss_info = yes"   \
        --option="idmap config ${netbios^^}: unix_primary_group = yes"\
        --option="winbind enum users = yes"                         \
        --option="winbind enum groups = yes"                        \
        --option="tls enabled  = yes"                               \
        --option="tls cafile   = "                                  \
        --option="tls keyfile  = /keys/${mykey}"                    \
        --option="tls certfile = /keys/${mycert}"                   \
        --option="dns forwarder=${dnslist}"
        # todo add host ip option
    # to use windows dc, modify /etc/nsswitch.conf
    # if this is not modified, then you will encounter security ID structure is invalid error!
	sed -i 's/passwd:         compat/passwd:         compat winbind/' /etc/nsswitch.conf
	sed -i 's/group:         compat/group:         compat winbind/'   /etc/nsswitch.conf

    # copy kerberos file
    mv /etc/krb5.conf /etc/krb5.conf.bak 
    mv /var/lib/samba/private/krb5.conf /etc/krb5.conf
fi

# if supervisor file does not exists, then create it.
if [ ! -e /etc/supervisor/conf.d/samba.conf ]; then
    echo "/etc/supervisor/conf.d/samba.conf does not exists. generating..."
    # set up supervisord
    touch /etc/supervisor/conf.d/samba.conf
    printf  "[supervisord]\nnodaemon=true\n[program:samba]\ncommand=/usr/sbin/samba -i" >> /etc/supervisor/conf.d/supervisord.conf
fi #end if initialization

# easy to use backup script
if [ ! -e /bin/backup ]; then
    touch /bin/backup
    echo "#!/bin/bash" >/bin/backup
    echo "samba-tool domain backup offline --targetdir=/backup" >> /bin/backup
    chmod +x /bin/backup
fi

# start supervisord!
/usr/bin/supervisord

exit 0