#!/bin/bash

LOG_INTERVAL=30
PROC_LOG_DIR="$SLURM_SUBMIT_DIR/proc_logs"
mkdir -p "$PROC_LOG_DIR"
export PROC_LOG_DIR LOG_INTERVAL USER SLURM_JOB_ID

echo "Starting process logging on all nodes..."

# srun --ntasks=$SLURM_JOB_NUM_NODES --ntasks-per-node=1 --exclusive 
bash -c '
    LOG_FILE="$PROC_LOG_DIR/proclog_$(hostname)_$SLURM_JOB_ID.log"
    while true; do
        ts=$(date "+%Y-%m-%dT%H:%M:%S")
        echo "=== $ts ===" >> "$LOG_FILE"
        ps -u "$USER" -o pid,psr,%mem,%cpu,cmd,args --sort=-%cpu -ww \
            | grep -v "ps -u" \
            | grep -v "sleep $LOG_INTERVAL" \
            | grep -v "bash -c" >> "$LOG_FILE"
        echo >> "$LOG_FILE"
        sleep $LOG_INTERVAL
    done
' &

