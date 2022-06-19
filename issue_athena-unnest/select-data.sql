SELECT
-- account,
--api_key_id,
id,
customerId,
date_trunc('month', issueDate) AS date,
inv1.totalAmount                    AS amount,
items.productId,
items.totalAmount              AS item_amount
FROM revenue.invoices as inv1
CROSS JOIN UNNEST(invoiceItems) t(items)
WHERE issueDate > DATE '1970-01-01'
AND issueDate <= DATE '2021-10-01'
--AND status = 'success'
--AND source = 'file'
--AND company_id = 99999999
