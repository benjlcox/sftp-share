#!/bin/bash

for type in rsa dsa ecdsa ed25519; do
  if ! [ -e "/ssh/ssh_host_${type}_key" ]; then
    echo "/ssh/ssh_host_${type}_key not found, generating..."
    ssh-keygen -f "/ssh/ssh_host_${type}_key" -N '' -t ${type}
  fi

  ln -sf "/ssh/ssh_host_${type}_key" "/etc/ssh/ssh_host_${type}_key"
done

if ( id ${USER} ); then
    echo "INFO: User ${USER} already exists"
else
    echo "INFO: User ${USER} does not exists, we create it"
    ENC_PASS=$(perl -e 'print crypt($ARGV[0], "password")' ${PASS})

    useradd -m -p ${ENC_PASS} -u ${USER_UID} ${USER}
    usermod ${USER} -s /bin/sh

    usermod ${USER} -g sftponly

    mkdir /data/home
    chmod 777 /data/home
    mkdir /data/home/Inbox
    chmod 777 /data/home/Inbox

    useradd -d /data/home ${USER}
    usermod ${USER} -s /bin/sh

    ln -s /data/home/Inbox /data

fi

exec /usr/sbin/sshd -D
