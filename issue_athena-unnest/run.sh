#!/bin/bash

awslocal s3 rm s3://bucket1/ --recursive
awslocal s3 mb s3://bucket1/

# use commands below if PARTITION is used in CREATE TABLE definition:
# awslocal s3 cp Invoices_1.json s3://bucket1/invoices/source=file/company_id=99999999/api_key_id=11/account=main/Invoices_1.json
# awslocal s3 cp Invoices_1.json s3://bucket1/invoices/source=file/company_id=99999999/api_key_id=11/account=main/Invoices_2.json
# use command below if no PARTITION definition is used:
awslocal s3 cp Invoices_1.json s3://bucket1/invoices/Invoices_1.json

awslocal athena start-query-execution --query-string "CREATE DATABASE revenue"
sleep 7

awslocal athena start-query-execution --query-string "DROP TABLE revenue.invoices"
sleep 10

awslocal athena start-query-execution --query-string "$(cat create-table.sql)"
sleep 20

awslocal athena start-query-execution --query-string "$(cat select-data.sql)"
sleep 5
