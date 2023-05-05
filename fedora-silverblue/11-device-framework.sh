#!/bin/bash

# fixing brightness keys
sudo rpm-ostree kargs --append="module_blacklist=hid_sensor_hub"

# fixing screen freezes
sudo rpm-ostree kargs --append="i915.enable_psr=0"
