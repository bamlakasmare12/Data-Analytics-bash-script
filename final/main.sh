#!/bin/bash

# Check for the correct number of command-line arguments
if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <csv_file> <delimiter>"
    exit 1
fi

# Store command-line arguments
csv_file="$1"
delimiter="$2"


# Menu-driven interface
while true; do
    choice=$(dialog --backtitle "CSV Data Analysis" \
        --menu "Select an option:" 15 60 8 \
        1 "Display number of rows and columns" \
        2 "List unique values in a column" \
        3 "Display column names (header)" \
        4 "Minimum and maximum values for numeric columns" \
        5 "Most frequent value for categorical columns" \
        6 "Calculate summary statistics for numeric columns" \
        7 "Filter and extract rows and columns" \
        8 "Sort the CSV file based on a column" \
        9 "Exit" \
        3>&1 1>&2 2>&3)

    case "$choice" in
        1) # Display number of rows and columns
            num_rows=$(cat "$csv_file" | wc -l)
            num_columns=$(head -n 1 "$csv_file" | tr "$delimiter" '\n' | wc -l)
            dialog --msgbox "CSV File: $csv_file\nDelimiter: $delimiter\n\nNumber of Rows: $num_rows\nNumber of Columns: $num_columns" 10 50
            dialog --yesno "Do you want to save the result to a file?" 10 50
            response=$?
            if [ $response -eq 0 ]; then
                dialog --inputbox "Enter the filename to save the result:" 10 50 2> /tmp/save_filename.txt
                save_filename=$(cat /tmp/save_filename.txt)
                echo "CSV File: $csv_file" > "$save_filename"
                echo "Delimiter: $delimiter" >> "$save_filename"
                echo "Number of Rows: $num_rows" >> "$save_filename"
                echo "Number of Columns: $num_columns" >> "$save_filename"
                dialog --msgbox "Result saved to '$save_filename'" 10 50
            else
                dialog --msgbox "Result not saved." 10 50
            fi

            # Clean up temporary files
            rm -f /tmp/save_filename.txt
            ;;
        2) # List unique values in a column
            dialog --inputbox "Enter the column name to extract unique values from:" 10 50 2> /tmp/column_name.txt
            column_name=$(cat /tmp/column_name.txt)
            
            # Extract the specified column and use 'sort' and 'uniq' to get unique values
            unique_values=$(awk -F "$delimiter" -v colname="$column_name" 'NR==1 { for (i=1; i<=NF; i++) if ($i == colname) colnum=i } NR>1 { if (colnum) print $colnum }' "$csv_file" | sort | uniq)

            # Display the unique values using dialog
            dialog --title "Unique Values" --msgbox "$unique_values" 20 80
            dialog --yesno "Do you want to save the result to a file?" 10 50
            response=$?
            if [ $response -eq 0 ]; then
                dialog --inputbox "Enter the filename to save the result:" 10 50 2> /tmp/save_filename.txt
                save_filename=$(cat /tmp/save_filename.txt)
                echo "$unique_values" > "$save_filename"
                dialog --msgbox "Result saved to '$save_filename'" 10 50
            else
                dialog --msgbox "Result not saved." 10 50
            fi
            # Clean up temporary files
            rm -f /tmp/column_name.txt /tmp/save_filename.txt
            ;;
        3) # Display column names (header)            
            # Extract the header row from the CSV file
            header=$(head -n 1 "$csv_file")

            # Display the column names using dialog
            dialog --title "Column Names" --msgbox "$header" 20 80
            dialog --yesno "Do you want to save the column names to a file?" 10 50
            response=$?
            if [ $response -eq 0 ]; then
                dialog --inputbox "Enter the filename to save the column names:" 10 50 2> /tmp/save_filename.txt
                save_filename=$(cat /tmp/save_filename.txt)
                echo "$header" > "$save_filename"
                dialog --msgbox "Column names saved to '$save_filename'" 10 50
            else
                dialog --msgbox "Column names not saved." 10 50
            fi
            # Clean up temporary files
            rm -f /tmp/save_filename.txt
            ;;
        4) # Min and max values for numeric columns
            dialog --inputbox "Enter the name of the numeric column:" 10 50 2> /tmp/numeric_column.txt
            numeric_column=$(cat /tmp/numeric_column.txt)
            
            # Extract the specified numeric column
            numeric_data=$(awk -F "$delimiter" -v colname="$numeric_column" 'NR==1 { for (i=1; i<=NF; i++) if ($i == colname) colnum=i } NR>1 { if (colnum) print $colnum }' "$csv_file")

            # Check if numeric data is empty
            if [ -z "$numeric_data" ]; then
                dialog --msgbox "No data found for the specified numeric column '$numeric_column'." 10 50
                return
            fi

            # Calculate the minimum and maximum values
            min_value=$(echo "$numeric_data" | tr '\n' ' ' | awk -v RS=' ' 'NR == 1 || $1 < min { min = $1 } END { print min }')
            max_value=$(echo "$numeric_data" | tr '\n' ' ' | awk -v RS=' ' 'NR == 1 || $1 > max { max = $1 } END { print max }')

            # Display the minimum and maximum values using dialog
            dialog --title "Min/Max Values" --msgbox "Minimum Value: $min_value\nMaximum Value: $max_value" 10 50
            dialog --yesno "Do you want to save the min/max values to a file?" 10 50
            response=$?
            if [ $response -eq 0 ]; then
                dialog --inputbox "Enter the filename to save the min/max values:" 10 50 2> /tmp/save_filename.txt
                save_filename=$(cat /tmp/save_filename.txt)
                echo "Minimum Value: $min_value" > "$save_filename"
                echo "Maximum Value: $max_value" >> "$save_filename"
                dialog --msgbox "Min/Max values saved to '$save_filename'" 10 50
            else
                dialog --msgbox "Min/Max values not saved." 10 50
            fi
            # Clean up temporary files
            rm -f /tmp/numeric_column.txt /tmp/save_filename.txt
            ;;
        5) # Most frequent value for categorical columns
            dialog --inputbox "Enter the name of the categorical column:" 10 50 2> /tmp/categorical_column.txt
            categorical_column=$(cat /tmp/categorical_column.txt)
            
            # Extract the specified categorical column
            categorical_data=$(awk -F "$delimiter" -v colname="$categorical_column" 'NR==1 { for (i=1; i<=NF; i++) if ($i == colname) colnum=i } NR>1 { if (colnum) print $colnum }' "$csv_file")

            # Check if categorical data is empty
            if [ -z "$categorical_data" ]; then
                dialog --msgbox "No data found for the specified categorical column '$categorical_column'." 10 50
                return
            fi

            # Find the most frequent value and its count
            most_frequent=$(echo "$categorical_data" | sort | uniq -c | sort -nr | head -n 1)
            most_frequent_value=$(echo "$most_frequent" | awk '{print $2}')
            most_frequent_count=$(echo "$most_frequent" | awk '{print $1}')

            # Display the most frequent value and its count using dialog
            dialog --title "Most Frequent Value" --msgbox "Most Frequent Value: $most_frequent_value\nCount: $most_frequent_count" 10 50
            dialog --yesno "Do you want to save the most frequent value to a file?" 10 50
            response=$?
            if [ $response -eq 0 ]; then
                dialog --inputbox "Enter the filename to save the most frequent value:" 10 50 2> /tmp/save_filename.txt
                save_filename=$(cat /tmp/save_filename.txt)
                echo "Most Frequent Value: $most_frequent_value" > "$save_filename"
                echo "Count: $most_frequent_count" >> "$save_filename"
                dialog --msgbox "Most frequent value saved to '$save_filename'" 10 50
            else
                dialog --msgbox "Most frequent value not saved." 10 50
            fi
            rm -f /tmp/categorical_column.txt /tmp/save_filename.txt

            ;;
        6) # Calculate summary statistics
            dialog --inputbox "Enter the name of the numeric column:" 10 50 2> /tmp/numeric_column.txt
            numeric_column=$(cat /tmp/numeric_column.txt)

            # Extract the specified numeric column
            numeric_data=$(awk -F "$delimiter" -v colname="$numeric_column" 'NR==1 { for (i=1; i<=NF; i++) if ($i == colname) colnum=i } NR>1 { if (colnum) print $colnum }' "$csv_file")

            # Check if numeric data is empty
            if [ -z "$numeric_data" ]; then
                dialog --msgbox "No data found for the specified numeric column '$numeric_column'." 10 50
                return
            fi

            # Calculate mean, median, and standard deviation
            mean=$(echo "$numeric_data" | awk '{ sum += $1 } END { if (NR > 0) print sum / NR }')
            median=$(echo "$numeric_data" | sort -n | awk '{ a[i++] = $1 } END { if (NR % 2 == 1) print a[int(NR/2)]; else print (a[NR/2-1] + a[NR/2])/2 }')
            std_deviation=$(echo "$numeric_data" | awk -v mean="$mean" '{ sum += ($1 - mean) ** 2 } END { if (NR > 1) print sqrt(sum / (NR-1)) }')

            # Display the summary statistics using dialog
            dialog --title "Summary Statistics" --msgbox "Mean: $mean\nMedian: $median\nStandard Deviation: $std_deviation" 10 50
            dialog --yesno "Do you want to save the summary statistics to a file?" 10 50
            response=$?
            if [ $response -eq 0 ]; then
                dialog --inputbox "Enter the filename to save the summary statistics:" 10 50 2> /tmp/save_filename.txt
                save_filename=$(cat /tmp/save_filename.txt)
                echo "Mean: $mean" > "$save_filename"
                echo "Median: $median" >> "$save_filename"
                echo "Standard Deviation: $std_deviation" >> "$save_filename"
                dialog --msgbox "Summary statistics saved to '$save_filename'" 10 50
            else
                dialog --msgbox "Summary statistics not saved." 10 50
            fi
            # Clean up temporary files
            rm -f /tmp/numeric_column.txt /tmp/save_filename.txt
            ;;
        7) # Filter and extract rows and columns        
            dialog --inputbox "Enter filter conditions (e.g., 'column1=value1;column2=value2'):" 10 50 2> /tmp/filter_conditions.txt
            filter_conditions=$(cat /tmp/filter_conditions.txt)

            # Extract the rows that match the filter conditions
            filtered_rows=$(awk -F "$delimiter" -v conditions="$filter_conditions" 'NR==1 {print} NR>1 {split(conditions, arr, ";"); valid=1; for (i in arr) { split(arr[i], cond, "="); col=cond[1]; val=cond[2]; if ($col != val) valid=0; } if (valid) print }' "$csv_file")

            # Check if any rows matched the filter conditions
            if [ -z "$filtered_rows" ]; then
                dialog --msgbox "No rows matched the filter conditions." 10 50
                return
            fi

            # Ask the user for columns to extract
            dialog --inputbox "Enter column numbers to extract (e.g., '1,3,5'):" 10 50 2> /tmp/column_numbers.txt
            column_numbers=$(cat /tmp/column_numbers.txt)

            # Extract the specified columns
            extracted_data=$(echo "$filtered_rows" | cut -d "$delimiter" -f "$column_numbers")

            # Display the extracted data using dialog
            dialog --title "Filtered and Extracted Data" --msgbox "$extracted_data" 20 80
            dialog --yesno "Do you want to save the filtered and extracted data to a file?" 10 50
            response=$?
            if [ $response -eq 0 ]; then
                dialog --inputbox "Enter the filename to save the filtered and extracted data:" 10 50 2> /tmp/save_filename.txt
                save_filename=$(cat /tmp/save_filename.txt)
                echo "$extracted_data" > "$save_filename"
                dialog --msgbox "Filtered and extracted data saved to '$save_filename'" 10 50
            else
                dialog --msgbox "Filtered and extracted data not saved." 10 50
            fi
            # Clean up temporary files
            rm -f /tmp/filter_conditions.txt /tmp/column_numbers.txt /tmp/save_filename.txt
            ;;
        8) # Sort the CSV file
            header=$(head -n 1 "$csv_file")

            # Prompt the user to select a column for sorting using dialog
            sort_column=$(dialog --menu "Select a column to sort based on:" 20 50 10 $(echo "$header" | tr ',' '\n' | cat -n | awk '{print $1 " " $2}' ) 2>&1 >/dev/tty)

            # Calculate the column number based on the user's choice
            sort_column_number=$(echo "$sort_column" | awk '{print $1}')

            # Check if the user canceled the selection
            if [ -z "$sort_column_number" ]; then
                dialog --msgbox "No column selected for sorting. Exiting." 10 50
                exit 1
            fi
            # Sort the CSV file based on the specified column
            sorted_csv=$(sort -t "$delimiter" -k "$sort_column_number,$sort_column_number" "$csv_file")

            # Display the first 5 rows of the sorted CSV using dialog
            first_5_rows=$(echo "$sorted_csv" | head -n 5)

            dialog --title "First 5 Rows (Sorted)" --msgbox "$first_5_rows" 20 80

            # Ask the user for a filename to save the sorted CSV
            dialog --inputbox "Enter the filename to save the sorted CSV:" 10 50 2> /tmp/save_filename.txt
            save_filename=$(cat /tmp/save_filename.txt)
            
            # Save the sorted CSV to the specified file
            echo "$header" > "$save_filename"
            echo "$sorted_csv" >> "$save_filename"

            dialog --msgbox "Sorted CSV saved to '$save_filename'" 10 50
            # Clean up temporary files
            rm -f /tmp/save_filename.txt

            ;;
        9) # Exit
            clear
            exit 0
            ;;
        *) # Invalid choice
            dialog --msgbox "Invalid choice. Please try again." 10 40
            ;;
    esac
done
