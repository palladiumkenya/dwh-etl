This folder contains the logic of cleaning the staging area of the Data Warehouse. We utilize look-up tables that we use to clean the staging tables by joining to them and updating with the correct, cleaned values.

## Look-up tables scripts
The look-up tables scripts are stored in this folder **look_up_tables**. The look-up tables scripts comprise of a **create statement** and **insert statement**. The look-up tables contain 3 columns:
- source_name: this the value in the source extract that needs to be cleaned
- target_name: this is the cleaned value that is going to replace the value from the source
- date_created: this is the date when the mapping was created

The format of naming the look-up table scripts is: lkp_*name_of_variable_in_snake_case*.sql

## Cleaning table scripts
The cleaning scripts for the different tables are stored in the root folder. The scripts contain **update statements** for updating the different staging tables to clean them. Some of the statements may contain joins with the look-up tables while others might not depending on the use case.

The format of naming the cleaning scripts is: clean_*name_of_table_name*.sql


