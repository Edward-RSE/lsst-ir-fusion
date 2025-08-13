import argparse
import re
import subprocess

PIPELINE_TASKS = [
    "2.0_startSingleFrame.slurm",
    "3.0_startCalibrate.slurm",
    "4.0_startCoadd.slurm",
    "5_ingestHSC.slurm",
    "6.0_startMultiVisit.slurm",
]

INGEST_TASKS = [
    "1_butler_ingest.slurm",
]

RESTART_TASKS = [
    "2.1_restartSingleFrame.slurm",
    "4.1_restartCoadd.slurm",
    "6.1_restartMultiVisit.slurm",
]

parser = argparse.ArgumentParser()
parser.add_argument("--start-from", help="Start submitting from this script (inclusive)")
args = parser.parse_args()

# Apply start-from filter
if args.start_from:
    if args.start_from not in PIPELINE_TASKS:
        raise ValueError(f"{args.start_from} not found in job list")
    start_idx = PIPELINE_TASKS.index(args.start_from)
    jobs_to_submit = list(PIPELINE_TASKS[start_idx:])
else:
    jobs_to_submit = list(PIPELINE_TASKS)

previous_jobid = None
for job_file in jobs_to_submit:
    cmd = ["sbatch"]
    if previous_jobid:
        cmd.append(f"--dependency=afterok:{previous_jobid}")
    cmd.append(job_file)

    print(f"Submitting: {' '.join(cmd)}")
    result = subprocess.run(cmd, stdout=subprocess.PIPE, text=True, check=True)
    match = re.search(r"Submitted batch job (\d+)", result.stdout)
    if match:
        previous_jobid = match.group(1)
    else:
        raise RuntimeError(f"Could not extract job ID from: {result.stdout}")

