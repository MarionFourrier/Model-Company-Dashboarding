select 
count(com.orderNumber) as nombre_de_commande,
detail.quantityOrdered,
com.shippedDate,
clients.country,
SUM(detail.quantityOrdered*detail.priceEach)AS chiffreaffaire
FROM customers AS clients
inner JOIN orders AS com ON com.customerNumber = clients.customerNumber
inner JOIN orderdetails AS detail ON detail.orderNumber = com.orderNumber
WHERE com.shippedDate IN (
SELECT com.shippedDate FROM orders AS com
WHERE com.shippedDate IS NOT NULL AND com.shippedDate BETWEEN (select date_sub(max(orderDate), interval 2 month) from orders) AND (select max(orderDate) from orders)
AND com.status = 'Shipped' OR com.status = 'Resolve'
)
GROUP BY  country
ORDER BY  chiffreaffaire DESC;
