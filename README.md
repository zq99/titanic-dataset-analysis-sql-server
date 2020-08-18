# Titanic dataset analysis using SQL Server

This is a repository for the queries I have been using to explore the Titanic dataset from Kaggle using SQL Server.

## How to run

Create a new database called 'titanic':
```
  drop database if exists titanic;
  create database titanic;
```
Next, create the core database objects for the analysis by running the following script:
```
  sql_initialize_titanic_database;
```
This will create all the base tables, stored procs, and scalar functions.


## Import the data

Once all the database objects have been setup, download the import files from this repository into a location.

The files are from Kaggle, however they have the headers removed because the 'bulk insert' process in SQL server was having issues with these.

Import the data using the following statements:
```
  exec [dbo].[sp_import_train_csv] 'C:\Users\work\Downloads\train.csv'
  exec [dbo].[sp_import_test_csv] 'C:\Users\work\Downloads\test.csv'
```

## Database objects

The data for analysis is found in the tables:
```
  train
  test
```
The tables with suffix 'bcp' are staging tables for the import process and should not be used for creating queries.

The following view can be used to look at information across both the main tables:
```
  vw_train_and_test_combined
```
This view has a column called 'dataset' which allows you to distinguish between the data in the two tables if necessary.


