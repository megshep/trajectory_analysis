#!/bin/bash
#SBATCH --job-name=check_header
#SBATCH --output=/mnt/iusers01/nm01/j90161ms/logs/head_logs/head2_%j.out
#SBATCH --error=/mnt/iusers01/nm01/j90161ms/logs/head_logs/head2_%j.err
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=24
#SBATCH --mem=256G
#SBATCH --time=5-00:00:00
#SBATCH --partition=himem

# -------------------------------
# Load MATLAB
module load apps/binapps/matlab/R2024b

# Path to SPM installation
export USER_SPM_DIR="/mnt/iusers01/nm01/j90161ms/scratch/spm25/spm"

# Change to the directory where you submitted the job
cd "$SLURM_SUBMIT_DIR"

# Run MATLAB non-interactively, calling the check_header.m script
matlab -nodisplay -nosplash -batch "try; addpath(getenv('USER_SPM_DIR')); run('/mnt/iusers01/nm01/j90161ms/trajectory/check_header.m'); catch ME; disp(getReport(ME)); exit(1); end; exit(0);"

