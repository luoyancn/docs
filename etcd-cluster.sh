#!/usr/bin/env bash
set -e
# set the ip of each member of etcd cluster.
etcd1=10.1.1.16
etcd2=10.1.1.17
etcd3=10.1.1.18

etcd_initial_cluster="etcd1=http://${etcd1}:2380,etcd2=http://${etcd2}:2380,etcd3=http://${etcd3}:2380"
etcd_cluster_name="etcd-cluster-k8s"

for etcd_name in etcd1 etcd2 etcd3; do
    curr_host_ip=${!etcd_name}
    ssh ${curr_host_ip} -o StrictHostKeyChecking=no "
        sed -i -r \
            -e 's|.*ETCD_NAME=.*|ETCD_NAME=\"'${etcd_name}'\"|' \
            -e 's|.*ETCD_DATA_DIR=.*|ETCD_DATA_DIR=\"/var/lib/etcd/'${etcd_name}'\"|' \
            -e 's|.*ETCD_LISTEN_PEER_URLS=.*|ETCD_LISTEN_PEER_URLS=\"http://'${curr_host_ip}':2380\"|' \
            -e 's|.*ETCD_LISTEN_CLIENT_URLS=.*|ETCD_LISTEN_CLIENT_URLS=\"http://'${curr_host_ip}':2379,http://127.0.0.1:2379,http://127.0.0.1:4001\"|' \
            -e 's|.*ETCD_INITIAL_ADVERTISE_PEER_URLS=.*|ETCD_INITIAL_ADVERTISE_PEER_URLS=\"http://'${curr_host_ip}':2380\"|' \
            -e 's|.*ETCD_INITIAL_CLUSTER=.*|ETCD_INITIAL_CLUSTER=\"'${etcd_initial_cluster}'\"|' \
            -e 's|.*ETCD_INITIAL_CLUSTER_STATE=.*|ETCD_INITIAL_CLUSTER_STATE=\"new\"|' \
            -e 's|.*ETCD_INITIAL_CLUSTER_TOKEN=.*|ETCD_INITIAL_CLUSTER_TOKEN=\"'${etcd_cluster_name}'\"|' \
            -e 's|.*ETCD_ADVERTISE_CLIENT_URLS=.*|ETCD_ADVERTISE_CLIENT_URLS=\"http://'${curr_host_ip}':2379\"|' \
            /etc/etcd/etcd.conf
"
done
