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

# Define the fields we want to save from the ui
fields <- c('sid', 'date', 'scenario', 'range', 'distance', 'yards', 'metres')

# Define the storage directory
outputDir <- "summary"

# Save data function
saveData <- function(data) {
  data <- t(data)
  # Create a unique file nameq
  fileName <- sprintf("%s_%s.csv", as.integer(Sys.time()), digest(data))
  # Write the file to the local system
  write.csv(x = data, file = file.path(outputDir, fileName), row.names = FALSE, quote = TRUE)
}

# Read data function
loadData <- function() {
  # Read all the files into a list
  files <- list.files(outputDir, full.names = TRUE)
  data <- lapply(files, read.csv, stringsAsFactors = FALSE) 
  # Concatenate all data together into one data.frame
  data <- do.call(rbind, data)
  data
}

