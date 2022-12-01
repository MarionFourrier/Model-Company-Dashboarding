WITH Order_Price_Clients AS ( 
    /* On crée une sélection "Order_Price_Clients" qui nous donne Le numéro de commande, 
    Le num client / prix de la commande, Le prix de la commande, le nom du client */
    SELECT ord_D.orderNumber, 
    concat(ord.customerNumber, " / ", SUM(ord_D.priceEach * ord_D.quantityOrdered)) as clientCommande,
    SUM(ord_D.priceEach * ord_D.quantityOrdered) AS prix,
    cst.customerName
    FROM orders  AS ord
    INNER JOIN orderdetails as ord_D ON ord.orderNumber = ord_D.orderNumber
    LEFT JOIN customers as cst on cst.customerNumber = ord.customerNumber
    WHERE ord.status = 'Shipped' or  ord.status = 'Resolved'
    GROUP BY ord_D.orderNumber
),    Payement_Price_Client1 as (
    /* On crée une sélection Payement_Price_Client1 qui donne Le num client / prix de la facture, Le nom du client */
    # 
    SELECT concat(customers.customerNumber, " / ", payments.amount) as clientFacture, customers.customerName as client
    FROM customers 
    RIGHT JOIN payments on customers.customerNumber = payments.customerNumber
    
),    clientCommandeCount AS (
    /* On crée une sélection à partir de Order_Price_Clients ( 1ere sélection) qui donne Le numéro du client qui commande, Le nb de fois qu'il a commandé au même prix,
    Le numéro de la commande, le prix de la commande, le nom du client */
    SELECT clientCommande, count(clientCommande) as rep, orderNumber as `No commande`,
    prix, customerName as `Client`
    from Order_Price_Clients 
    group by orderNumber
), clientFactureCount AS (
    /* On crée une sélection à partir de Payement_Price_Client1 ( 2eme sélection) qui donne Le num client / prix de la facture, le nombre de répétition */
    SELECT clientFacture, count(*) as rep
    from Payement_Price_Client1
    group by clientFacture
)
SELECT *
FROM clientFactureCount as cfc
RIGHT OUTER JOIN clientCommandeCount as ccc on  cfc.clientFacture = ccc.clientCommande
where ccc.rep != cfc.rep or  cfc.clientFacture is null
order by prix DESC;

##########################

SELECT SUM(ord.prix) as 'Impayés totaux'
    FROM 
    (SELECT ord_D.orderNumber, 
        concat(ord.customerNumber, " / ", SUM(ord_D.priceEach * ord_D.quantityOrdered)) as clientCommande,
        SUM(ord_D.priceEach * ord_D.quantityOrdered) AS prix,
        cst.customerName
        FROM orders  AS ord
        INNER JOIN orderdetails as ord_D ON ord.orderNumber = ord_D.orderNumber
        LEFT JOIN customers as cst on cst.customerNumber = ord.customerNumber
        WHERE ord.status = 'Shipped' or  ord.status = 'Resolved'
        GROUP BY ord_D.orderNumber)
    as ord
    WHERE 
        ord.clientCommande NOT  IN 
        (
        SELECT concat(customers.customerNumber, " / ", payments.amount)
        FROM customers
        right join payments on customers.customerNumber = payments.customerNumber
        ) 
    
;
########
SELECT SUM(od.quantityOrdered*od.priceEach)
FROM orderdetails AS od
JOIN orders AS o ON od.orderNumber = o.orderNumber
WHERE YEAR(orderDate) = (SELECT YEAR(max(orderDate))-1 FROM orders);
