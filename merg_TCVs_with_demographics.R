setwd("/Users/megsheppard/Desktop/trajectory")

# Load libraries
library(readr)
library(dplyr)
library(readxl)

# Read in your files
long_df <- read_xlsx("trajectory_demographics.xlsx")   # your file with ID + timepoints
tcv_df  <- read_csv("tcv_combined.csv")           # file with ID + TCV

# Make sure ID columns have the same name
# (change these if your column names differ)
colnames(long_df)[colnames(long_df) == "Subject_ID"] <- "ID"
colnames(tcv_df)[colnames(tcv_df) == "Subject"] <- "ID"

# convert both to character (compatible types) before merging 
long_df$ID <- as.character(long_df$ID)
tcv_df$ID  <- as.character(tcv_df$ID)

# Merge TCV into the big dataset by ID
merged_df <- long_df %>%
  left_join(tcv_df, by = "ID")

# Save new file
write_csv(merged_df, "demographics_with_TCV.csv")
