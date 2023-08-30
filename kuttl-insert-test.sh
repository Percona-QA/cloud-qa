#!/bin/bash
#
# This script inserts a blank space into kuttl test list
# (id's of test cases including and after requested will be increased)

# Check if argument is provided
if [ -z "$1" ]
  then
    echo "Please provide a number of test case which number should be increased."
    exit 1
fi

# Loop through the files in descending order and rename them
for file in $(ls -v -r [0-9][0-9]-*)
do
  # Get the number from the beginning of the filename
  number=$(echo "$file" | cut -d '-' -f 1)
  
  # Check if the number is greater than or equal to the argument
  if [ "$number" -ge "$1" ]
    then
      # Increase the number by 1 and rename the file
      new_number=$(expr "$number" + 1)
      new_number_padded=$(printf "%02d" "$new_number")
      new_file=$(echo "$file" | sed "s/^$number-/$new_number_padded-/")
      echo "$file -> $new_file"
      mv "$file" "$new_file"
  fi
done
