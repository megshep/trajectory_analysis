#!/bin/bash
#SBATCH --job-name=change_maps
#SBATCH --output=/mnt/iusers01/nm01/j90161ms/maps_logs/change_map_%A_%a.out
#SBATCH --error=/mnt/iusers01/nm01/j90161ms/maps_logs/change_map_%A_%a.err
#SBATCH --array=1-1233%1233
#SBATCH --time=72:00:00
#SBATCH --mem=20G
#SBATCH --cpus-per-task=1

# Load in MATLAB 
module load apps/binapps/matlab/R2024b 

# Set the SPM path environment variable - this includes the directory where SPM itself is saved
export USER_SPM_DIR="/mnt/iusers01/nm01/j90161ms/scratch/spm25/spm"

# Ensure we run in the job submission directory
cd "$SLURM_SUBMIT_DIR"

SUB_ID=$SLURM_ARRAY_TASK_ID

# Run the MATLAB script 
matlab -nodisplay -nosplash -batch "try;addpath(getenv('USER_SPM_DIR'));run('/mnt/iusers01/nm01/j90161ms/scratch/final_sample/create_change_maps.m');catch ME;fprintf(2,'Error: %s\n', ME.message);disp(getReport(ME, 'extended'));end;exit"


