#!/bin/bash
#SBATCH --job-name=shoot_template
#SBATCH --output=/mnt/iusers01/nm01/j90161ms/logs/shoot_logs/shoot_%A_%a.out
#SBATCH --error=/mnt/iusers01/nm01/j90161ms/logs/shoot_logs/shoot_%A_%a.err
#SBATCH --array=1-1229%1229        # Adjust as needed for number of subjects
#SBATCH --time=72:00:00
#SBATCH --mem=20G
#SBATCH --cpus-per-task=1

# Load MATLAB module
module load apps/binapps/matlab/R2024b

# Path to SPM installation
export USER_SPM_DIR="/mnt/iusers01/nm01/j90161ms/scratch/spm25/spm"

# Change to the directory where you submitted the job
cd "$SLURM_SUBMIT_DIR"

# Run MATLAB non-interactively, calling your shoot.m script
matlab -nodisplay -nosplash -batch "try; addpath(getenv('USER_SPM_DIR')); run('/mnt/iusers01/nm01/j90161ms/trajectory/geodesic_shoot.m'); catch ME; disp(getReport(ME)); exit(1); end; exit(0);"


