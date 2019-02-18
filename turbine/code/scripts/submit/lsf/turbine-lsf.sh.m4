changecom(`dnl')#!/bin/bash -l

# We use changecom to change the M4 comment to dnl, not hash

# Copyright 2013 University of Chicago and Argonne National Laboratory
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License

# TURBINE-LSF.SH.M4
# The Turbine LSF template.  This is automatically filled in
# by M4 in turbine-lsf-run.zsh

# Created: esyscmd(`date')

# Define convenience macros
define(`getenv', `esyscmd(printf -- "$`$1' ")')
define(`getenv_nospace', `esyscmd(printf -- "$`$1'")')

ifelse(getenv(PROJECT), `',,
#BSUB -P getenv(PROJECT))
#BSUB -J getenv(TURBINE_JOBNAME)
#BSUB -nnodes getenv_nospace(NODES)
#BSUB -W getenv(WALLTIME)
#BSUB -e getenv(OUTPUT_FILE)
#BSUB -o getenv(OUTPUT_FILE)

set -eu

VERBOSE=getenv(VERBOSE)
if (( ${VERBOSE} ))
then
 set -x
fi

echo "TURBINE-LSF"
echo

cd ${TURBINE_OUTPUT}

TURBINE_HOME=getenv(TURBINE_HOME)
COMMAND="getenv(COMMAND)"
PROCS=getenv(PROCS)

# Start the user environment variables pasted by M4
getenv(USER_ENVS_CODE)
# End environment variables pasted by M4

# Construct jsrun-formatted user environment variable arguments
USER_ENVS_ARGS=()
for K in ${!USER_ENVS[@]}
do
  USER_ENVS_ARGS+=( -E $K="${USER_ENVS[$K]}" )
done

# Restore user PYTHONPATH if the system overwrote it:
export PYTHONPATH=getenv(PYTHONPATH)

export LD_LIBRARY_PATH=getenv_nospace(LD_LIBRARY_PATH):getenv(TURBINE_LD_LIBRARY_PATH)
source ${TURBINE_HOME}/scripts/turbine-config.sh

module load gcc/6.4.0
module load spectrum-mpi/10.2.0.10-20181214
module load cuda/9.2.148
# PATH=/opt/ibm/spectrum_mpi/jsm_pmix/bin:$PATH

set -x
echo
which jsrun

START=$( date +%s.%N )
hostname
jsrun --nrs $PROCS --tasks_per_rs 1 --cpu_per_rs 1 --gpu_per_rs 1 --rs_per_host $PPN -E TCLLIBPATH "${USER_ENVS_ARGS[@]}" ${COMMAND}
# ~/mcs/ste/mpi/t.x # bash -c hostname
CODE=$?
echo
echo EXIT CODE: $CODE
STOP=$( date +%s.%N )
# Bash cannot do floating point arithmetic:
DURATION=$( awk -v START=${START} -v STOP=${STOP} \
            'BEGIN { printf "%.3f\n", STOP-START }' < /dev/null )
echo "MPIEXEC TIME: ${DURATION}"
exit $CODE
