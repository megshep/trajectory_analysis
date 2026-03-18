
library(oro.nifti)

# Set working directory to where the scans, CSV, and mask are
setwd <- "/mnt/iusers01/nm01/j90161ms/scratch/final_sample"

# Load in the mask of the bilateral amygdala (not reorienting, so that it stays in MNI space)
# before doing this, I combined the left and right amygdala masks using FSL
mask_file <- file.path(working_dir, "bilateral_amygdala.nii")
if(!file.exists(mask_file)) stop("Mask file not found!")
mask <- readNIfTI(mask_file, reorient = FALSE)

# Read in the IDs from the demographics CSV (stopping factors being automatically loaded in as string variables)
id_file <- file.path(working_dir, "final_demographics_traj.csv")

#this is a sanity check --> identifies if there are mismatches 
if(!file.exists(id_file)) stop("ID CSV file not found!")
ids <- read.csv(id_file, stringsAsFactors = FALSE)$Subject_ID

# This is the function to extract the ROI, based on the IDs
# this checks to make sure that there is a normalised and smoothed scan associated with the ID
# (this works across all timepoints because of how the IDs are named in the excel)
extract_roi <- function(id) {

  # construct the absolute path to this participant's NIfTI
  img_file <- file.path(working_dir, paste0("smwrc", id, ".nii"))

  # this is an inbuilt sanity check --> sends out a warning message to tell me if the code has failed at this time point
  if (!file.exists(img_file)) {
    warning(paste("File not found:", img_file))
    return(NULL)
  }

  # this then loads in the associated NIfTI file
  img <- readNIfTI(img_file, reorient = FALSE)

  # sanity check: dimensions must match the mask
  if (!all(dim(img) == dim(mask))) {
    warning(paste("Dimension mismatch for ID:", id))
    return(NULL)
  }

  # extract bilateral amygdala voxels (anywhere where the intensity value is larger than 0 in the mask)
  roi_vals <- img[mask > 0]

  # produces a .csv for this individual with raw voxel intensities
  out_file <- file.path(working_dir, paste0("smwrc", id, "_amygdala_voxels.csv"))
  write.csv(roi_vals, out_file, row.names = FALSE)

  cat("Saved CSV for participant:", id, "->", out_file, "\n")
}

# Loop over all IDs to repeat this for everyone in the list
for(id in ids){
  extract_roi(id)
}

cat("All participants processed!\n")



