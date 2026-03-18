#!/bin/bash
#SBATCH --job-name=amygdala_roi
#SBATCH --output=/mnt/iusers01/nm01/j90161ms/logs/amygdala_logs/amygdala_%A_%a.out
#SBATCH --error=/mnt/iusers01/nm01/j90161ms/logs/amygdala_logs/amygdala_%A_%a.err
#SBATCH --time=72:00:00
#SBATCH --mem=20G
#SBATCH --cpus-per-task=1

# load R module
module load apps/gcc/R/4.5.0

# run your existing R script
Rscript extract_ROI.R
