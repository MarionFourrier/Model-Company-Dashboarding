# Stocks :

SELECT products.productName AS Produit,
products.quantityInStock AS "Quantité en Stock",
SUM(orderdetails.quantityOrdered) AS "Ventes prévisionnelles des 3 prochains mois" 
FROM orderdetails
INNER JOIN products ON products.productCode = orderdetails.productCode
LEFT JOIN orders ON orders.orderNumber=orderdetails.orderNumber
WHERE (orders.status = "Shipped" OR "Resolved") 
AND (orderDate BETWEEN (SELECT date_sub(max(orderDate), interval 1 YEAR) FROM orders) AND (SELECT date_sub(max(orderDate), interval 9 MONTH) FROM orders))
GROUP BY orderdetails.productCode 
HAVING (quantityInStock) < SUM(quantityOrdered)
ORDER BY quantityInStock DESC;
#######
SELECT SUM(od.quantityOrdered*od.priceEach)
FROM orderdetails AS od
JOIN orders AS o ON od.orderNumber = o.orderNumber
WHERE YEAR(orderDate) = (SELECT YEAR(max(orderDate))-1 FROM orders);
