# Set working directory
setwd("/mnt/iusers01/nm01/j90161ms/scratch/final_sample")

# Load libraries
library(readr)
library(dplyr)
library(purrr)

# Get a list of all the CSV files that contain the ROI values extracted for each subject. Mine are named smwrcID_FU2/3_amygdala_voxels.csv, so refine this as needed.
file_list <- list.files(pattern = "amygdala_voxels\\.csv$", full.names = TRUE)

process_file <- function(file_path) {
  
  # Read the individual CSV (my ROI was extracted so that each CSV only had one single column 'x')
  df <- read_csv(file_path, col_types = cols())
  
  # Extract subject ID and optional FU visit
  # this is done this way because BL doesn't have any indication of visit, but FU2 and FU3 are in the name, and this needs to be preserved in the list of IDs 
  id <- sub(".*?(\\d+(?:_FU\\d+)?).*", "\\1", basename(file_path))
  
  # Sanity check (in case something doesn't match, that way I can backtrace the problem and manually fill any gaps)
  if (identical(id, basename(file_path))) {
    warning(paste("ID not found for file:", file_path))
    return(NULL)
  }
  
  # Convert column 'x' from my csv into a single row to make it easier to merge into one big dataframe
  row_values <- df$x
  
  # Create dataframe with meaningful column names (e.g., ID, voxel1, voxel2)
  # transpose ensures one row per subject
  out <- tibble(ID = id) %>%
    bind_cols(as_tibble(t(row_values), .name_repair = "minimal")) %>%
    setNames(c("ID", paste0("V", seq_along(row_values))))
  
  return(out)
}

# Apply function to all files within the folder and combine into one dataframe
final_df <- map_dfr(file_list, process_file)

# Save final dataset
write_csv(final_df, "extracted_ROI_all.csv")
