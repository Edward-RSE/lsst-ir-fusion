LOG_INTERVAL=30
MEM_LOG_DIR="$SLURM_SUBMIT_DIR/mem_logs"
mkdir -p "$MEM_LOG_DIR"

echo "Starting memory logging on all nodes..."
# srun --ntasks=$SLURM_JOB_NUM_NODES --ntasks-per-node=1 --exclusive bash -c "
#     LOG_FILE=$MEM_LOG_DIR/memlog_\$(hostname)_$SLURM_JOB_ID.log
# 	echo \"ts total used free\" >> \$LOG_FILE
#     while true; do
#         ts=\$(date '+%Y-%m-%dT%H:%M:%S')
#         read -r total used free < <(free -b | awk '/^Mem:/ {print \$2, \$3, \$4}')
#         echo \"\$ts \$total \$used \$free\" >> \$LOG_FILE
#         sleep $LOG_INTERVAL
#     done
# " &
bash -c "
    LOG_FILE=$MEM_LOG_DIR/memlog_\$(hostname)_$SLURM_JOB_ID.log
	echo \"ts total used free\" >> \$LOG_FILE
    while true; do
        ts=\$(date '+%Y-%m-%dT%H:%M:%S')
        read -r total used free < <(free -b | awk '/^Mem:/ {print \$2, \$3, \$4}')
        echo \"\$ts \$total \$used \$free\" >> \$LOG_FILE
        sleep $LOG_INTERVAL
    done
" &
