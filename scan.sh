#!/bin/bash

# Check if an argument was provided
exclude_paths=()

while (( "$#" )); do
  case "$1" in
    -p|--path)
      path="$2"
      shift 2
      ;;
    -e|--exclude-path)
      exclude_paths+=("$2")
      shift 2
      ;;
    --)
      shift
      break
      ;;
    *)
      echo "Invalid option: -$OPTARG" >&2
      exit 1
      ;;
  esac
done

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

  string=$(echo "$string" | tr -d '\n')

  # Print the current position and total
  echo "Scanning string $counter of $total: scan keyword $string"

  # Run the grep command with the current search string and store the results in the array grep_results
  while IFS= read -r line; do
    grep_results+=("$line")
  done < <(grep -Rlw "$path" -e "$string")
done

echo "==================================================================================================="
echo "suspect file list:"

# Remove duplicates from the array grep_results
readarray -t unique_grep_results < <(printf '%s\n' "${grep_results[@]}" | sort -u)

# Display the unique results
printf '%s\n' "${unique_grep_results[@]}"

echo "==================================================================================================="
echo "backdoor suspect list:"

# Check if unique_grep_results is not empty
if [ ${#unique_grep_results[@]} -ne 0 ]; then
  # Loop through each file in unique_grep_results
  for file in "${unique_grep_results[@]}"; do
    # Calculate the md5sum of the file
    md5=$(md5sum "$file" | awk '{ print $1 }')

    # Check if the md5sum is in sum5list.txt
    if grep -q "$md5" sum5list.txt; then
      echo "The file $file is backdoor."
    else
      echo "The file $file is not backdoor, please inform this script author for next investigation."
    fi
  done
fi

while IFS= read -r line
do
  # Adds each path to the exclude variable
  exclude_paths="$exclude_paths -not -path '$line/*'"
done < exclude_paths.txt

while IFS= read -r line
do
  # Adds each path to the exclude variable
  exclude_files="$exclude_files -not -name '$line/*'"
done < exclude_files.txt

echo "==================================================================================================="
echo "writeable folder list:"

find $path -type d -perm /u=w,g=w,o=w $exclude_paths

echo "==================================================================================================="
echo "writeable file list:"

find $path -type f -perm /u=w,g=w,o=w $exclude_paths $exclude_files