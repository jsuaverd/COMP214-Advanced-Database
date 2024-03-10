
-- 1. List the shipping city and state for the order that had the shortest shipping delay.

select shipcity, shipstate from orders
	    where (shipdate-orderdate)= (select min(shipdate-orderdate) from orders);
        
--2 Determine which author or authors wrote the books least frequently purchased by customers of JustLee Books.
	

	SELECT DISTINCT(a.lname), a.fname 
	FROM author a, bookauthor ba, orderitems oi
	WHERE a.authorid = ba.authorid 
	AND ba.isbn = oi.isbn
	AND (
	    SELECT COUNT(*) 
	    FROM orderitems oi2, bookauthor ba2
	    WHERE oi2.isbn = ba2.isbn
	    AND ba2.authorid = a.authorid
	) = (
	    SELECT Min(authorOrders)
	    FROM (
	        SELECT COUNT(*) as authorOrders
	        FROM orderitems oi3, bookauthor ba3
	        WHERE oi3.isbn = ba3.isbn
	        GROUP BY ba3.authorid
	    )
	);
	
--3 Determine which customers placed orders for the most expensive book (in terms of regular retail price) carried by JustLee Books.	
select distinct lastname, firstname,customers.customer#, books.title from customers,orders,orderitems,books
	    where books.isbn = orderitems.isbn
	    and orderitems.order# = orders.order#
	    and orders.customer# = customers.customer#
	    and books.isbn = (select isbn from books where retail = (select max(retail) from books)) ;
        
--4 List the names of all criminals who have had any of the crime code charges involved in crime ID 10088. 

select last, first from criminals, crimes, crime_charges
	    where criminals.criminal_id = crimes.criminal_id
	    and crimes.crime_id = crime_charges.crime_id
	    and crime_code = (select crime_code from crime_charges where crime_id= 10088);
        
--5 List the information on crime charges for each charge that has had a fine below  average and a sum paid above average. 
	
select * from crime_charges
	    where fine_amount < (select avg(fine_amount) from crime_charges)
	    and amount_paid > (select avg(amount_paid) from crime_charges);

-- Use a correlated subquery to determine which criminals did not have had probation period assigned.
	
select last, first from criminals
where criminal_id in (select criminal_id from sentences where prob_id is null);
