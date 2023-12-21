#!/bin/bash

# Check if an argument was provided
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 path"
    exit 1
fi

# Store the argument into a variable
path=$1

# Read the file list.txt and store each line into the array search_strings
readarray -t search_strings < list.txt

# Get the total number of search strings
total=${#search_strings[@]}

# Create an empty array to store the grep results
grep_results=()

# Initialize a counter
counter=0

# Loop through each search string in the array
for string in "${search_strings[@]}"; do
  # Increment the counter
  ((counter++))

  # Print the current position and total
  echo "Scanning string $counter of $total: $string"

  # Run the grep command with the current search string and store the results in the array grep_results
  while IFS= read -r line; do
    grep_results+=("$line")
  done < <(grep -Rlw "$path" -e "$string")
done

# Remove duplicates from the array grep_results
readarray -t unique_grep_results < <(printf '%s\n' "${grep_results[@]}" | sort -u)

# Display the unique results
printf '%s\n' "${unique_grep_results[@]}"
