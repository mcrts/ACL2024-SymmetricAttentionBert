#!/bin/bash
CURRENT=$(dirname -- "$(readlink -f -- "$BASH_SOURCE")")
BASE=$(dirname -- $CURRENT )

# make sure only first task per node installs stuff, others wait
DONEFILE="/tmp/install_done_${SLURM_JOBID}"
if [[ $SLURM_LOCALID == 0 ]]; then
  
  # put your install commands here (remove lines you don't need):
  pip install $BASE/plpi
  
  # Tell other tasks we are done installing
  touch "${DONEFILE}"
else
  # Wait until packages are installed
  while [[ ! -f "${DONEFILE}" ]]; do sleep 1; done
fi