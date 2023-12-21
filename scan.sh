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

# Declare an empty array to store the grep results
declare -a grep_results

# Loop through each search string in the array
for string in "${search_strings[@]}"; do
  # Run the grep command with the current search string and store the results in the array grep_results
  while IFS= read -r line; do
    grep_results+=("$line")
  done < <(grep -Rlw "$path" -e "$string")
done

# Remove duplicates from the array grep_results
readarray -t unique_grep_results < <(printf '%s\n' "${grep_results[@]}" | sort -u)

# Display the unique results
printf '%s\n' "${unique_grep_results[@]}"
