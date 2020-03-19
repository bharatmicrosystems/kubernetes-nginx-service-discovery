config_dir=$1
domain=$2

if [ "$#" -ne 2 ]; then
    echo "Usage: setup.sh <config_dir> <domain>"
    exit 1
fi

cp -a kubernetes-nginx-service-discovery-agent.sh /usr/bin/
sed -i "s%config_dir_ph%${config_dir}%g" /usr/bin/kubernetes-nginx-service-discovery-agent.sh
sed -i "s%domain_ph%${domain}%g" /usr/bin/kubernetes-nginx-service-discovery-agent.sh

cp -a kubernetes-nginx-service-discovery.service /etc/systemd/system/
systemctl daemon-reload
systemctl enable kubernetes-nginx-service-discovery.service
systemctl start kubernetes-nginx-service-discovery.service
