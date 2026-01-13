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
                                                                                             
# Load FSL into the CSF - this is the path to it on the CSF

module load apps/binapps/fsl/6.0.5
export FSLDIR=/opt/apps/apps/binapps/fsl/6.0.5
export PATH=$FSLDIR/bin:$PATH
# I also asked it to use all the CPUs to make this a quick as possible 
export FSL_PARALLEL=$SLURM_CPUS_PER_TASK

# Setting the input and output directories (and I made the output directory at the same time) - the input could just be my scratch space but I moved the files so I don't
# have to keep filtering out the rc1 and rc2 avg images from a previous analysis
RC1_DIR="/net/scratch/j90161ms/rc1_clean"
RC2_DIR="/net/scratch/j90161ms/rc2_clean"
OUT_DIR="/net/scratch/j90161ms/double_prec"

mkdir -p "$OUT_DIR"

#This reads the binary data itself to check the file header; it basically says, “Go to byte 70 of the file, read 2 bytes, and tell me the number stored there.”
#This confirms that it is in float32 rather than float64 before converting
# Check datatype from NIfTI header (pure bash)
get_dtype() {
    file="$1"
    od -An -t u2 -j 70 -N 2 "$file" | tr -d ' '
}

# Convert to double precision if not already float64
convert_if_needed() {
    infile="$1"
    fname=$(basename "$infile")

    # Determine output filename
    if [[ "$fname" == rc1* ]]; then
        outname="${fname/rc1/rc1d}"
    elif [[ "$fname" == rc2* ]]; then
        outname="${fname/rc2/rc2d}"
    else
        outname="d_$fname"
    fi

    outfile="$OUT_DIR/$outname"

    # Check datatype - tell me if it is either skipping it because it is already double precision, or if it is being converted
    dt=$(get_dtype "$infile")
    if [[ "$dt" -eq 64 ]]; then
        echo "$infile is already double precision, skipping."
    else
        echo "Converting $infile to double precision..."
        fslmaths "$infile" "$outfile" -odt double
    fi
}


# Process RC1 files - actually converting rc1s 
for f in "$RC1_DIR"/rc1*.nii*; do
    convert_if_needed "$f"
done


# Process RC2 files - actually converting rc2s
for f in "$RC2_DIR"/rc2*.nii*; do
    convert_if_needed "$f"
done

echo "All RC1 and RC2 images processed. Output in $OUT_DIR."
