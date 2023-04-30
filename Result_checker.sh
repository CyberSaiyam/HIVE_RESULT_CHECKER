#!/bin/bash

echo "Script Started..."

# Ask user for queries file name
read -p "Enter name of file containing queries: " input_file

# Ask user for expected file name
read -p "Enter name of file containing expected results: " expected_file

# Read queries from input file
IFS=$'\n' read -r -d '' -a queries < $input_file

# Output file for storing query results
output_file="output.txt"

# Delete the output file if it already exists
if [ -f "$output_file" ]; then
  rm "$output_file"
fi

# Loop through each query
for query in "${queries[@]}"
do
    # Execute the query and store the result in the output file
    hive -e "$query" | sed -n '4s/|[[:blank:]]*//gp' | tee -a $output_file

done


file1="$expected_file"
file2="output.txt"

# Remove whitespaces from both files
sed -i 's/[[:blank:]]//g' "$file1"
sed -i 's/[[:blank:]]//g' "$file2"

# Count number of lines in both files
file1_lines=$(cat "$file1" | wc -l)
file2_lines=$(cat "$file2" | wc -l)

# Check if both files have the same number of lines
if [ "$file1_lines" -ne "$file2_lines" ]; then
    echo "Error: Both files do not have the same number of lines"
    exit 1
fi

# Output file for storing summary results
summary_file="summary.txt"

# Delete the summary file if it already exists
if [ -f "$summary_file" ]; then
  rm "$summary_file"
fi

# Loop through each line in the files and compare values
for (( i=1; i<=$file1_lines; i++ ))
do
    # Get value from line i in file1
    value1=$(sed -n "${i}p" "$file1")

    # Get value from line i in file2
    value2=$(sed -n "${i}p" "$file2")

    # Compare values and print result
    if [ "$value1" = "$value2" ]; then
        echo "Query: ${queries[$i-1]}" | tee -a $summary_file
        echo "Expected Result: $value1" | tee -a $summary_file
        echo "Actual Result: $value2" | tee -a $summary_file
		echo "Query $i passed" | tee -a $summary_file
		echo "------------------------------------------------" >> "$summary_file"
    else
        echo "Query: ${queries[$i-1]}" | tee -a $summary_file
        echo "Expected Result: $value1" | tee -a $summary_file
        echo "Actual Result: $value2" | tee -a $summary_file
		echo "Query $i failed because $value1 != $value2" | tee -a $summary_file
		echo "------------------------------------------------" >> "$summary_file"
    fi
done

echo "A summary file is created."
echo "Script Ended!!!"
