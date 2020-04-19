#!/bin/bash

DOCKER_BRIDGE_IP="172.17.0.1"

sed -i "\$i # Allow all connections from docker bridge" /var/lib/postgresql/data/pg_hba.conf
sed -i "\$i host\tall\t\tall\t\t$DOCKER_BRIDGE_IP/32\t\ttrust\n" /var/lib/postgresql/data/pg_hba.conf
