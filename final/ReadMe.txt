CSV Data Analysis Bash Script

Prerequisites:
   - Bash shell
   - The `dialog` utility for creating the menu-driven interface.

Usage:
   Make the script executable with the following command:
      $> chmod +x csv_analysis.sh

   To run the program:
      $> ./main.sh <csv_file> "<delimiter>"
   Example:
      $> ./main.sh test.csv ","


Functionality:
   The script provides a menu-driven interface to perform various operations on a CSV file:

      Display number of rows and columns:
      Shows the number of rows and columns in the CSV file.

      List unique values in a column:
      Allows you to specify a column and lists its unique values.

      Display column names (header):
      Displays the column names (header) of the CSV file.

      Minimum and maximum values for numeric columns:
      Computes the minimum and maximum values for a specified numeric column.

      Most frequent value for categorical columns:
      Finds the most frequent value and its count in a specified categorical column.

      Calculate summary statistics for numeric columns:
      Calculates the mean, median, and standard deviation for a specified numeric column.

      Filter and extract rows and columns:
      Lets you filter rows based on conditions and extract specific columns.

      Sort the CSV file based on a column:
      Sorts the CSV file based on a chosen column.

      Exit:
      Exits the script.
