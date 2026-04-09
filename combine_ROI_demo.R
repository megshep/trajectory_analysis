setwd("/Users/megsheppard/Desktop/trajectory/extract_ROI")

# Load libraries
library(readr)
library(dplyr)

# Read in the files
demo_df <- read.csv("final_demographics_traj.csv")   # the file with final demographics, CTQ, TCV etc.
roi_df  <- read_csv("extracted_ROI_voxels.csv")           # the file where the amygdala ROI values are

# Make sure ID columns have the same name
# (change these if your column names differ)
colnames(demo_df)[colnames(demo_df) == "Subject_ID"] <- "ID"
colnames(roi_df)[colnames(roi_df) == "Subject_ID"] <- "ID"

# convert both to character (compatible types) before merging 
demo_df$ID <- as.character(demo_df$ID)
roi_df$ID  <- as.character(roi_df$ID)

# Merge TCV into the big dataset by ID
merged_df <- demo_df %>%
  left_join(roi_df, by = "ID")

# Save new file
write_csv(merged_df, "final_dataset.csv")



