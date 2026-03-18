library(oro.nifti)

# set working directory to where the scans, CSV, and mask are
setwd("/mnt/iusers01/nm01/j90161ms/scratch/final_sample")

# load in the mask of the bilateral amygdala (not reorienting, so that it stays in MNI space)
# before doing this, I combined the left and right amygdala masks using fsl 
mask <- readNIfTI("bilateral_amygdala_mask.nii", reorient = FALSE)

#this is the function to extract the ROI, based on the IDs
# this checks to make sure that there is a normalised and smoothed scan associated with the ID 
# (this works across all timepoints because of how the IDs are named in the excel)
extract_roi <- function(id) {
  
  # construct the filename for this participant
  img_file <- paste0("smwrc", id, ".nii") 
  
  # this is an inbuilt sanity check --> sends out a warning message to tell me if the code has failed at this time point
  if (!file.exists(img_file)) {
    warning(paste("File not found:", img_file))
    return(NULL)
  }
  
  # this then loads in the associated nifti file
  img <- readNIfTI(img_file, reorient = FALSE)
  
  # sanity check: dimensions must match the mask
  if (!all(dim(img) == dim(mask))) {
    warning(paste("Dimension mismatch for ID:", id))
    return(NULL)
  }
  
  # extract bilateral amygdala voxels (anywhere where the intensity value is larger than 0 in the mask)
  roi_vals <- img[mask > 0]
  
  # produces a .csv for this individual with raw voxel intensities
  out_file <- paste0("smwrc", id, "_amygdala_voxels.csv")
  write.csv(roi_vals, out_file, row.names = FALSE)
}
