#!/bin/bash
#SBATCH --job-name=normalise
#SBATCH --output=/mnt/iusers01/nm01/j90161ms/logs/norm_logs/norm_%A_%a.out
#SBATCH --error=/mnt/iusers01/nm01/j90161ms/logs/norm_logs/norm_%A_%a.err
#SBATCH --array=1-3693%3693
#SBATCH --time=72:00:00
#SBATCH --mem=20G
#SBATCH --cpus-per-task=1

module load apps/binapps/matlab/R2024b

export USER_SPM_DIR="/mnt/iusers01/nm01/j90161ms/scratch/spm25/spm"

cd "$SLURM_SUBMIT_DIR"

matlab -nodisplay -nosplash -batch "try; addpath(getenv('USER_SPM_DIR')); run('/mnt/iusers01/nm01/j90161ms/trajectory/normalise_smooth.m'); catch ME; disp(getReport(ME)); exit(1); end; exit(0);"








