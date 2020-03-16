#!/bin/bash
cd /tmp
cp -f named.conf.template /etc/named.conf
cp -f rndc.conf /etc/rndc.conf
mkdir -p /etc/named/zones/
for i in $(echo $zones | sed "s/,/ /g")
do
    # call your procedure/other scripts here below
    echo "Creating zone for $i"
    cat <<EOF >> /etc/named.conf
zone "template-zone" {
    type master;
    file "/etc/named/zones/template-zone";
};
EOF
    cp -f template-zone /etc/named/zones/$i
    sed -i "s/template-zone/$i/g" /etc/named.conf
    sed -i "s/template-zone/$i/g" /etc/named/zones/$i
done
/usr/sbin/named -u named -c /etc/named.conf
#Create A records now
while true; do
kubectl get ingress|awk '{print $2}'| while read line; do
   for i in $(echo $zones | sed "s/,/ /g")
   do
     echo $line
     if [[ "$line" == *"$i"* ]]; then
        for host in $(echo $line | sed "s/,/ /g")
        do
          if grep -q $host "/etc/named/zones/$i"; then
            # Do nothing
            echo "A record for $host already exists"
          else
            echo "Creating A record for $host"
            echo "${host}.       IN      A       $(getent hosts ${ingress_name}.${ingress_namespace}.svc.cluster.local | awk \'{ print $1 }\')" >> /etc/named/zones/$i
            rndc reload $i
          fi
        done
     fi
   done
   # ... more code ... #
done
sleep 10
done
