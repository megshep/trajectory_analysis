#!/bin/bash
#SBATCH --job-name=shoot_template
#SBATCH --output=/mnt/iusers01/nm01/j90161ms/logs/shoot_logs/shoot_%j.out
#SBATCH --error=/mnt/iusers01/nm01/j90161ms/logs/shoot_logs/shoot_%j.err
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=24
#SBATCH --mem=512G
#SBATCH --time=4-00:00:00
#SBATCH --partition=himem       # Use the high-memory partition

# Load MATLAB module
module load apps/binapps/matlab/R2024b

# Path to SPM installation
export USER_SPM_DIR="/mnt/iusers01/nm01/j90161ms/scratch/spm25/spm"

# Change to the directory where you submitted the job
cd "$SLURM_SUBMIT_DIR"

# Run MATLAB non-interactively, calling the geodesic shooting script
matlab -nodisplay -nosplash -batch "try; addpath(getenv('USER_SPM_DIR')); run('/mnt/iusers01/nm01/j90161ms/trajectory/geodesic_shooting.m'); catch ME; disp(getReport(ME)); exit(1); end; exit(0);"




