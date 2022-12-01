
# Dashboard full : 

set @dmax = (select max(orderDate) from orders);
set @dmin = (select date_sub(max(orderDate), interval 23 month) from orders);

select p.productLine, o.orderDate, year(o.orderDate) as Annee, od.quantityOrdered * od.priceEach as total, o.status
from orderdetails as od
inner join orders as o on o.orderNumber = od.orderNumber
inner join products as p on p.productCode = od.productCode
where orderDate between @dmin and @dmax and o.status="Shipped" or o.status="Resolved" 
group by p.productLine, year(o.orderDate), month(o.orderDate)

########

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

###################

WITH Order_Price_Clients AS ( 
	# On crée une sélection "Order_Price_Clients" qui nous donne Le numéro de commande, 
    #Le num client / prix de la commande, Le prix de la commande, le nom du client
	SELECT ord_D.orderNumber, 
	concat(ord.customerNumber, " / ", SUM(ord_D.priceEach * ord_D.quantityOrdered)) as clientCommande,
    SUM(ord_D.priceEach * ord_D.quantityOrdered) AS prix,
    cst.customerName
	FROM orders  AS ord
    INNER JOIN orderdetails as ord_D ON ord.orderNumber = ord_D.orderNumber
    LEFT JOIN customers as cst on cst.customerNumber = ord.customerNumber
    WHERE ord.status = 'Shipped' or  ord.status = 'Resolved'
	GROUP BY ord_D.orderNumber
),	Payement_Price_Client1 as (
	# On crée une sélection Payement_Price_Client1 qui donne Le num client / prix de la facture, Le nom du client
    # 
    SELECT concat(customers.customerNumber, " / ", payments.amount) as clientFacture, customers.customerName as client
	FROM customers 
	RIGHT JOIN payments on customers.customerNumber = payments.customerNumber
	
),	clientCommandeCount AS (
	# On crée une sélection à partir de Order_Price_Clients ( 1ere sélection) qui donne Le numéro du client qui commande, Le nb de fois qu'il a commandé au même prix,
    # Le numéro de la commande, le prix de la commande, le nom du client
	SELECT clientCommande, count(clientCommande) as rep, orderNumber as `No commande`,
    prix, customerName as `Client`
	from Order_Price_Clients 
	group by orderNumber
), clientFactureCount AS (
	# On crée une sélection à partir de Payement_Price_Client1 ( 2eme sélection) qui donne Le num client / prix de la facture, le nombre de répétition 
	SELECT clientFacture, count(*) as rep
	from Payement_Price_Client1
	group by clientFacture
)
SELECT *
FROM clientFactureCount as cfc
RIGHT OUTER JOIN clientCommandeCount as ccc on  cfc.clientFacture = ccc.clientCommande
where ccc.rep != cfc.rep or  cfc.clientFacture is null
order by prix DESC;

##############

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

####################################”


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
