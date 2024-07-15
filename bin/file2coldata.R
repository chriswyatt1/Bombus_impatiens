# Load necessary library
library(readr)

# Read sample names from a file
sample_names <- read_lines("sample_names.txt")

# Extract the second element
extracted_elements <- sapply(sample_names, function(name) {
  elements <- unlist(strsplit(name, "\\."))
  return(elements[2])
})

# Create a data frame
coldata <- data.frame(sample_name = sample_names, extracted_element = extracted_elements)

# Save to CSV
write.csv(coldata, "coldata.csv", row.names = FALSE)
