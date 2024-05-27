#!/usr/bin/env bash

python -m pip install --upgrade pip
mv /tmp/plpi /opt/plpi
pip install -e /opt/plpi
exit 0;