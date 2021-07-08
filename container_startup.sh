#!/bin/bash

sudo /etc/init.d/postgresql start
bosh-registry-migrate -c ./registry.cfg
bosh-registry -c ./registry.cfg