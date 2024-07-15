# Load necessary library
library(readr)

# Read command line arguments
args <- commandArgs(trailingOnly = TRUE)

# Check if the input file name is provided
if (length(args) == 0) {
  stop("Please provide the input file name as a command line argument.")
}

# Input file name from command line argument
input_file <- args[1]

# Read sample names from the input file
sample_names <- read_lines(input_file)

# Extract the second element
extracted_elements <- sapply(sample_names, function(name) {
  elements <- unlist(strsplit(name, "\\."))
  return(elements[2])
})

# Create a data frame
coldata <- data.frame(sample_name = sample_names, extracted_element = extracted_elements)

# Save to CSV
output_file <- "coldata.csv"
write.csv(coldata, output_file, row.names = FALSE)

# Print a message indicating the output file
cat("coldata.csv has been generated.\n")


