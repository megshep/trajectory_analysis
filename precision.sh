#!/bin/bash
#SBATCH --job-name=convert_double
#SBATCH --output=/mnt/iusers01/nm01/j90161ms/logs/fsl/fsl_convert_%j.out
#SBATCH --error=/mnt/iusers01/nm01/j90161ms/logs/fsl/fsl_convert_%j.err
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=4
#SBATCH --mem=64G
#SBATCH --time=4:00:00
#SBATCH --partition=himem

# Load FSL
module load apps/binapps/fsl/6.0.5

# Use all requested CPUs in FSL - this will allow it to complete faster
export FSL_PARALLEL=4

# Directories for rc1 and rc2 inc. new directory for output
RC1_DIR="/net/scratch/j90161ms/rc1_clean"
RC2_DIR="/net/scratch/j90161ms/rc2_clean"
OUT_DIR="/net/scratch/j90161ms/double_prec"

# Make output directory 
mkdir -p "$OUT_DIR"

# Convert RC1 files
for f in "$RC1_DIR"/rc1*.nii*; do
    fname=$(basename "$f")
    # Add 'd' after rc1
    outname="${fname/rc1/rc1d}"
    fslmaths "$f" -odt double "$OUT_DIR/$outname"
done

# Convert RC2 files
for f in "$RC2_DIR"/rc2*.nii*; do
    fname=$(basename "$f")
    # Add 'd' after rc2
    outname="${fname/rc2/rc2d}"
    fslmaths "$f" -odt double "$OUT_DIR/$outname"
done

echo "All RC1 and RC2 images converted to double precision in $OUT_DIR."

