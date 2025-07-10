#!/bin/bash

# Install dependencies
sudo yum update -y
sudo yum install -y wget java-17-openjdk

# Setup variables
NEXUS_VERSION="3.77.1-01"
NEXUS_DIR="nexus-${NEXUS_VERSION}"
NEXUS_TAR="${NEXUS_DIR}-unix.tar.gz"
NEXUS_URL="https://download.sonatype.com/nexus/3/${NEXUS_TAR}"

# Create directories
mkdir -p /opt/nexus/
cd /tmp
rm -rf /tmp/nexus-install && mkdir /tmp/nexus-install
cd /tmp/nexus-install

# Download and extract Nexus
wget "$NEXUS_URL" -O nexus.tar.gz
tar -xzf nexus.tar.gz
mv "$NEXUS_DIR" /opt/nexus

# Create nexus user if not exists
id -u nexus &>/dev/null || sudo useradd -r -M -s /sbin/nologin nexus

# Set permissions
chown -R nexus:nexus /opt/nexus

# Configure nexus.rc
echo 'run_as_user="nexus"' | tee /opt/nexus/$NEXUS_DIR/bin/nexus.rc

# Create systemd service
cat <<EOT > /etc/systemd/system/nexus.service
[Unit]
Description=Nexus Repository Manager
After=network.target

[Service]
Type=forking
LimitNOFILE=65536
ExecStart=/opt/nexus/$NEXUS_DIR/bin/nexus start
ExecStop=/opt/nexus/$NEXUS_DIR/bin/nexus stop
User=nexus
Restart=on-abort

[Install]
WantedBy=multi-user.target
EOT

# Enable and start Nexus
systemctl daemon-reload
systemctl enable nexus
systemctl start nexus

