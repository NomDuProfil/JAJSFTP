#!/bin/bash
# -----------------------------------------------------------------------------
# Script Name: install_script.sh
# Project: JajSFTP
# Author: NomDuProfil
# GitHub: https://github.com/NomDuProfil/JajSFTP
# -----------------------------------------------------------------------------

# +==================================+
# |    Initialization variables      |
# +==================================+

ADMIN_USERNAME=${admin_username}
ADMIN_EMAIL=${admin_email}
S3_NAME=${s3_name}
AWS_REGION=${aws_region}
SERVER_IP=$(curl -sS http://checkip.amazonaws.com)

# +==================================+
# | Update and packages installation |
# +==================================+

yum update -y
amazon-linux-extras install -y epel
yum install -y git gcc gcc-c++ make automake libtool fuse fuse-devel curl-devel libxml2-devel openssl-devel

# +==================================================+
# |    Download s3fs-fuse and binary generation      |
# +==================================================+

latest_version=$(curl -s https://api.github.com/repos/s3fs-fuse/s3fs-fuse/releases/latest | grep "tag_name" | awk -F '"' '{print $4}')

if [ -z "$latest_version" ]; then
  exit 1
fi

curl -L -o s3fs-fuse.zip "https://github.com/s3fs-fuse/s3fs-fuse/archive/refs/tags/$${latest_version}.zip"

unzip s3fs-fuse.zip
cd "s3fs-fuse-$${latest_version#v}"

./autogen.sh
./configure
make
sudo make install

cd ..
rm -rf "s3fs-fuse-$${latest_version#v}" s3fs-fuse.zip

# +============================================+
# |          Server Configuration              |
# +============================================+

echo "SyslogFacility AUTH
LogLevel INFO
LoginGraceTime 1m
MaxAuthTries 3
MaxSessions 5
PasswordAuthentication no
PermitEmptyPasswords no
ChallengeResponseAuthentication no
UsePAM yes
X11Forwarding yes
PrintMotd no
AcceptEnv LANG LC_*
Subsystem       sftp    internal-sftp
Match Group sftponly
        ChrootDirectory /mnt/sftp_s3
        PasswordAuthentication yes
        X11Forwarding no
        AllowTcpForwarding no
        ForceCommand internal-sftp
        PermitTunnel no
        AllowAgentForwarding no" > /etc/ssh/sshd_config

# +============================================+
# |             User creation                  |
# +============================================+

read PASSWORD SALT_HASH < <(python3 -c "import os, crypt, random; password=''.join(random.choice('abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789') for _ in range(20)); salt=crypt.mksalt(crypt.METHOD_SHA512); hash=crypt.crypt(password, salt); print(password, hash)")
groupadd sftponly
useradd -g sftponly -s /sbin/nologin -p "$SALT_HASH" "$ADMIN_USERNAME"

# +============================================+
# |               Start services               |
# +============================================+

mkdir /mnt/sftp_s3
/usr/local/bin/s3fs $S3_NAME /mnt/sftp_s3/ -o iam_role=auto -o nonempty -o allow_other -o use_cache=/tmp
systemctl restart sshd

# +============================================+
# |       Configuration folder permission      |
# +============================================+

chmod 755 /mnt/sftp_s3/
mkdir /mnt/sftp_s3/uploads
chown $ADMIN_USERNAME:sftponly /mnt/sftp_s3/uploads

# +============================================+
# |          Sending information               |
# +============================================+

while true; do
    VALIDATION_STATUS=$(aws ses get-identity-verification-attributes --region "$AWS_REGION" --identities "$ADMIN_EMAIL" --output text | awk '{print $2}')
    echo "$VALIDATION_STATUS"
    if [ "$VALIDATION_STATUS" == "Success" ]; then
        echo "Email has been verified."
        break
    else
        echo "Waiting for email verification..."
        sleep 10
    fi
done

FROM_EMAIL="$ADMIN_EMAIL"
TO_EMAIL="$ADMIN_EMAIL"
SUBJECT="JajSFTP - Access Information"
BODY=$(cat <<EOF
<html>
  <body>
    <p>Hi,</p>
    <p>Here is all your information for your SFTP server:</p>
    <ul>
      <li><strong>SFTP IP:</strong> $SERVER_IP</li>
      <li><strong>Username:</strong> $ADMIN_USERNAME</li>
      <li><strong>Password:</strong> $PASSWORD</li>
    </ul>
    <p>Thanks,</p>
  </body>
</html>
EOF
)

aws ses send-email --from "$FROM_EMAIL" --destination "ToAddresses=$TO_EMAIL" --message "Subject={Data='$SUBJECT',Charset=utf-8},Body={Html={Data='$BODY',Charset=utf-8}}" --region "$AWS_REGION"
