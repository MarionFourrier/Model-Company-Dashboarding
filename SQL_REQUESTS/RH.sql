

# RH :
 
SELECT CONCAT(e.lastname, ' ', e.firstname) AS fullname, o.orderDate, SUM(od.quantityOrdered * od.priceEach) AS turnover
FROM employees e
INNER JOIN customers c
ON e.employeeNumber=c.salesRepEmployeeNumber
INNER JOIN orders o
ON c.customerNumber=o.customerNumber
INNER JOIN orderdetails od
ON o.orderNumber=od.orderNumber
WHERE (o.status LIKE "Shipped" OR "Resolved") 
GROUP BY o.orderDate, fullname
;

###########

SELECT CONCAT(e.lastname, ' ', e.firstname) AS fullname, SUM(od.quantityOrdered * od.priceEach) AS turnover
FROM employees e
INNER JOIN customers c
ON e.employeeNumber=c.salesRepEmployeeNumber
INNER JOIN orders o #LEFT JOIN pour avoir tous les employés, y compris ceux qui ont un CA null > en fait pas de différence avec le INNER JOIN…
ON c.customerNumber=o.customerNumber
INNER JOIN orderdetails od #LEFT JOIN pour avoir tous les employés, y compris ceux qui ont un CA null
ON o.orderNumber=od.orderNumber
WHERE (MONTH(o.orderDate)=MONTH(CURDATE())-1) AND (YEAR(o.orderDate)=YEAR(CURDATE())) AND (o.status LIKE "Shipped" OR "Resolved") #CURDATE > /!\ à éviter si pas de données depuis un certain temps jusqu'à date de la requête
GROUP BY fullname
ORDER BY turnover DESC
LIMIT 2
;

