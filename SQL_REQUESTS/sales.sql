set @dmax = (select max(orderDate) from orders);
set @dmin = (select date_sub(max(orderDate), interval 23 month) from orders);

select p.productLine, o.orderDate, year(o.orderDate) as Annee, od.quantityOrdered * od.priceEach as total, o.status
from orderdetails as od
inner join orders as o on o.orderNumber = od.orderNumber
inner join products as p on p.productCode = od.productCode
where orderDate between @dmin and @dmax and o.status="Shipped" or o.status="Resolved" 
group by p.productLine, year(o.orderDate), month(o.orderDate)
