#!/bin/bash/
echo " hey DBA, We starting cassandra setup....Please wait"
sudo dnf update -y
sudo yum install java-11-openjdk -y
sudo yum install wget -y
sudo mkdir -p /var/lib/cassandra; sudo chown -R $USER:$GROUP /var/lib/cassandra
wget https://archive.apache.org/dist/cassandra/4.0.13/apache-cassandra-4.0.13-bin.tar.gz
tar -xzvf apache-cassandra-4.0.13-bin.tar.gz
sudo cp -r apache-cassandra-4.0.13 /opt/
sudo chown -R $USER:$GROUP /opt/apache-cassandra-4.0.13/

echo " now we setup bash enviorment ....Please wait"

tee /home/ec2-user/.bash_profile <<EOF
export CASSANDRA_HOME=/opt/apache-cassandra-4.0.13
export CASSANDRA_CONF=/opt/apache-cassandra-4.0.13/conf
export CASSANDRA_LOG_DIR=/opt/apache-cassandra-4.0.13/logs
export CASSANDRA_HEAPDUMP_DIR=/opt/apache-cassandra-4.0.13/logs
export PATH=/opt/apache-cassandra-4.0.13/bin:$PATH

alias d='du -hx --max-depth=1'
alias l='ls -lh --color=auto'
alias n='nodetool status'

export PS1='\u@\h:\W $ '

clear
echo -e "\e[0m\033[31m
   _____                              _
  / ____|                            | |
 | |     __ _ ___ ___  __ _ _ __   __| |_ __ __ _
 | |    / _' / __/ __|/ _' | '_ \ / _' | '__/ _' |
 | |___| (_| \__ \__ \ (_| | | | | (_| | | | (_| |
  \_____\__,_|___/___/\__,_|_| |_|\__,_|_|  \__,_|

    Apache Cassandra-Server
\e[0m " ;
EOF



echo " Now, We configure cassandra.ymal file ....Please wait"

# Variables to customize
CLUSTER_NAME="prod_Cluster"
NUM_TOKENS=256
SEED_NODES="172.31.19.105,172.31.27.103"  # Adjust with your seed node IPs for DC we need public ip atleast 2 node per dc
CASSANDRA_DIR="/opt/apache-cassandra-4.0.13"  # Adjust to where you extracted the tarball
CASSANDRA_CONF_PATH="/opt/apache-cassandra-4.0.13/conf/cassandra.yaml"  # Path to cassandra.yaml in the tarball directory
PASSWORD_AUTH="PasswordAuthenticator"
AUTHORIZER="CassandraAuthorizer"
#DATA_DIR="/var/lib/cassandra/data"  # Replace with your desired data directory path
#COMMITLOG_DIR="/var/lib/cassandra/commitlog"  # Replace with your desired commitlog path
#SAVED_CACHES_DIR="/var/lib/cassandra/saved_caches"  # Replace with your desired saved_caches path

# Detect the machine's IP address automatically
LISTEN_ADDRESS=$(hostname -I | awk '{print $1}')
RPC_ADDRESS=$LISTEN_ADDRESS
#BROADCAST_RPC_ADDRESS=$LISTEN_ADDRESS

# Check if cassandra.yaml exists
if [ ! -f "$CASSANDRA_CONF_PATH" ]; then
    echo "cassandra.yaml not found at $CASSANDRA_CONF_PATH. Please check the Cassandra installation path."
    exit 1
fi

# Update cassandra.yaml file
echo "Updating cassandra.yaml file for node with IP $LISTEN_ADDRESS..."

sed -i "s/^cluster_name:.*/cluster_name: '$CLUSTER_NAME'/" $CASSANDRA_CONF_PATH
sed -i "s/^num_tokens:.*/num_tokens: $NUM_TOKENS/" $CASSANDRA_CONF_PATH
sed -i "s/^listen_address:.*/listen_address: $LISTEN_ADDRESS/" $CASSANDRA_CONF_PATH
sed -i "s/^rpc_address:.*/rpc_address: $LISTEN_ADDRESS/" $CASSANDRA_CONF_PATH
#sed -i "s/^broadcast_rpc_address:.*/broadcast_rpc_address: $BROADCAST_RPC_ADDRESS/" $CASSANDRA_CONF_PATH
sed -i "s/^endpoint_snitch:.*/endpoint_snitch: GossipingPropertyFileSnitch/" $CASSANDRA_CONF_PATH
#sed -i "s/^endpoint_snitch:.*/endpoint_snitch: Ec2MultiRegionSnitch" $CASSANDRA_CONF_PATH
#Update data directory paths in cassandra.yaml

# Seed nodes configuration
sed -i "s/.*- seeds:.*/        - seeds: \"$SEED_NODES\"/" $CASSANDRA_CONF_PATH

# Enable authentication
echo "Enabling authentication and authorization..."

sed -i "s/^authenticator:.*/authenticator: $PASSWORD_AUTH/" $CASSANDRA_CONF_PATH
sed -i "s/^authorizer:.*/authorizer: $AUTHORIZER/" $CASSANDRA_CONF_PATH

# List of parameters to uncomment
PARAMETERS=(
    "data_file_directories:"
    "- /var/lib/cassandra/data"
    "hints_directory:"
    "commitlog_directory:"
    "cdc_raw_directory:"
    "saved_caches_directory:"
)

# Uncomment each parameter
for PARAM in "${PARAMETERS[@]}"; do
    sed -i "s|^#\s*\($PARAM\)|\1|" "$CASSANDRA_CONF_PATH"
done

echo "All specified parameters have been uncommented in $CASSANDRA_CONF_PATH."

echo " hey DBA, We have done all this things now you can start cassandra all server"
cd /opt/apache-cassandra-4.0.13/bin/
 ./cassandra -R
