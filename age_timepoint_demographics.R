
setwd("/Users/megsheppard/Desktop/trajectory/extract_ROI")

#read in the data
data <- read.csv("final_dataset.csv")

time <- data$Time
age <- data$Age_years

#extracts how many unique groups there are and stores output
output <- numeric(length(unique(time)))

#this defines the groups based on the data itself e.g., naturally occurring groups
time_points <- unique(time)

#this loops over groups (rather than rows) to average the age across the timepoints
for (i in seq_along(time_points)) {
  #this picks the current iteration
  current_time <- time_points[i]
  #this filters and computes the mean of the age for the current iteration (timepoint)
  output[i] <- sd(age[time == current_time])
}

output
