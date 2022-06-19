CREATE EXTERNAL TABLE revenue.invoices(
  `id` STRING,
  `companyid` INT ,
  `invoicenumber` STRING ,
  `accountid` STRING ,
  `customerid` STRING ,
  `issuedate` DATE ,
  `duedate` DATE ,
  `paidondate` DATE ,
  `originalcurrency` STRING ,
  `currencyrate` DOUBLE ,
  `invoiceitems` array<struct<productid:STRING,unitamount:DOUBLE,quantity:INT,subtotal:DOUBLE,taxamount:DOUBLE,totalamount:DOUBLE,discountamount:DOUBLE,discountpercentage:DOUBLE>> ,
  `subtotal` DOUBLE ,
  `totaltaxamount` DOUBLE ,
  `totalamount` DOUBLE ,
  `amountdue` DOUBLE ,
  `totaldiscount` DOUBLE ,
  `discountpercentage` DOUBLE ,
  `status` STRING ,
  `customfields` array<struct<fieldname:STRING,fieldvalue:STRING>> ,
  `sourcemodifieddate` DATE ,
  `modifieddate` DATE )
--PARTITIONED BY (
--  `source` STRING,
--  `company_id` INT,
--  `api_key_id` STRING,
--  `account` STRING
--)
ROW FORMAT SERDE
  'org.apache.hive.hcatalog.data.JsonSerDe'
WITH SERDEPROPERTIES (
  'paths'='accountId,amountDue,companyId,currencyRate,customFields,customerId,discountPercentage,dueDate,id,invoiceItems,invoiceNumber,issueDate,modifiedDate,originalCurrency,paidOnDate,sourceModifiedDate,status,subTotal,totalAmount,totalDiscount,totalTaxAmount')
STORED AS INPUTFORMAT
  'org.apache.hadoop.mapred.TextInputFormat'
OUTPUTFORMAT
  'org.apache.hadoop.hive.ql.io.HiveIgnoreKeyTextOutputFormat'
LOCATION
  's3://bucket1/invoices/'
TBLPROPERTIES (
  'classification'='json',
  'compressionType'='none',
  'typeOfData'='file'
)
