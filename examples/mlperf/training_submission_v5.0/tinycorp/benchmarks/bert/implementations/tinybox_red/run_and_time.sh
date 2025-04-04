#!/bin/bash

export PYTHONPATH="."
export MODEL="bert"
export SUBMISSION_PLATFORM="tinybox_red"
export DEFAULT_FLOAT="HALF" SUM_DTYPE="HALF" GPUS=6 BS=96 EVAL_BS=96
export OPT_LAMB_BETA_1=0.60466 OPT_LAMB_BETA_2=0.85437 DECAY=0.1

export BEAM=3 BEAM_UOPS_MAX=4000 BEAM_UPCAST_MAX=256 BEAM_LOCAL_MAX=1024 BEAM_MIN_PROGRESS=5
export IGNORE_JIT_FIRST_BEAM=1
export BASEDIR="/raid/datasets/wiki"

# pip install -e ".[mlperf]"
export LOGMLPERF=1

export SEED=$RANDOM
DATETIME=$(date "+%m%d%H%M")
LOGFILE="bert_red_${DATETIME}_${SEED}.log"

# init
sudo rmmod amdgpu || true
BENCHMARK=10 INITMLPERF=1 BEAM_LOG_SURPASS_MAX=1 python3 examples/mlperf/model_train.py | tee $LOGFILE

# run
# TODO: AMD driver hangs during init, but is 5% faster per step in real run.
sudo modprobe amdgpu
PARALLEL=0 RUNMLPERF=1 python3 examples/mlperf/model_train.py | tee -a $LOGFILE
sudo rmmod amdgpu || true