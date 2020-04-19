#!/bin/bash

DOCKER_BRIDGE_IP="172.17.0.1"

sed -i "\$i # Allow all connections from docker bridge" $PGDATA/pg_hba.conf
sed -i "\$i host\tall\t\tall\t\t$DOCKER_BRIDGE_IP/32\t\ttrust\n" $PGDATA/pg_hba.conf
