suppressPackageStartupMessages({
  library(digest)
  library(dplyr)
  library(lubridate)
  library(plotly)
  library(readr)
  library(rvest)
  library(shiny)
  library(shinycssloaders)
  library(tidyr)
})

# Define the storage directory
output_dir <- 'output'

# USER DEFINED FUNCTIONS ---------------------------------------------------------------------------

# Save data function
saveData <- function(data) {
  # Create a unique file name
  file_name <- sprintf("%s_%s.csv", as.integer(Sys.time()), digest(data))
  # Write the file to the local system
  write.csv(x = data, file = file.path(output_dir, file_name), row.names = FALSE, quote = TRUE)
}

# Read data function
loadData <- function() {
  # Read all the files into a list
  files <- list.files(output_dir, full.names = TRUE)
  data <- lapply(files, read.csv, stringsAsFactors = FALSE) 
  # Concatenate all data together into one data.frame
  data <- do.call(rbind, data)
  data
}