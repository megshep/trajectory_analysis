# Set working directory
setwd("/mnt/iusers01/nm01/j90161ms/scratch/final_sample")

# Load libraries
library(readr)
library(dplyr)
library(purrr)

# Get list of all of the CSV files that contain the ROI values extracted for each subject
# Only include non-empty amygdala voxel files
file_list <- list.files(pattern = "_amygdala_voxels\\.csv$", full.names = TRUE)

# Function to process one file
process_file <- function(file_path) {
  
  # Read the individual CSV (my ROI was extracted so that each CSV only had one single column 'x')
  df <- read_csv(file_path, col_types = cols())
  
  # Extract subject ID and optional FU visit
  # Handles FU visits (e.g., _FU3) or just ID for baseline
  id <- sub(".*?(\\d+(?:_FU\\d+)?).*", "\\1", basename(file_path))
  
  # Sanity check (in case something doesn't match)
  if (identical(id, basename(file_path))) {
    warning(paste("ID not found for file:", file_path))
    return(NULL)
  }
  
  # Convert column 'x' from my csv into a single row
  row_values <- df$x
  
  # Skip completely empty data
  if (length(row_values) == 0) return(NULL)
  
  # Create dataframe with meaningful column names (ID, V1, V2, ...)
  out <- tibble(ID = id) %>%
    bind_cols(as_tibble(t(row_values), .name_repair = "minimal")) %>%
    setNames(c("ID", paste0("V", seq_along(row_values))))
  
  return(out)
}

# Process files in chunks to avoid memory overhead
chunk_size <- 500  # adjust if memory is limited
chunks <- split(file_list, ceiling(seq_along(file_list) / chunk_size))

# create tibble 
final_df <- tibble()

# Loop through chunks and combine
for (i in seq_along(chunks)) {
  message("Processing chunk ", i, " of ", length(chunks))
  chunk_df <- map_dfr(chunks[[i]], process_file)
  final_df <- bind_rows(final_df, chunk_df)
}

# Save final dataset
write_csv(final_df, "extracted_ROI_all.csv")
