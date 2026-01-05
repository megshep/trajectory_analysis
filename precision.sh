#!/bin/bash
#SBATCH --job-name=convert_to_double   # Job name
#SBATCH --output=convert_to_double.out # Standard output
#SBATCH --error=convert_to_double.err  # Standard error
#SBATCH --partition=normal             # Queue/partition
#SBATCH --nodes=1                      # Number of nodes
#SBATCH --ntasks=1                     # Number of tasks
#SBATCH --cpus-per-task=4              # CPU cores per task
#SBATCH --time=01:00:00                # Walltime in HH:MM:SS

# Load MATLAB module
module load apps/binapps/matlab/R2024b

# Run the MATLAB script in batch mode
matlab -nodisplay -nosplash -r "run('/mnt/iusers01/nm01/j90161ms/trajectory/precision.m'); exit;"
