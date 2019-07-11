/* 1 The sum of sales of the most purchased Genre */

-- 1.1 Most popular genre

SELECT g.Name AS genre_name, COUNT(l.InvoiceLineId)
FROM Genre g
JOIN Track t
ON g.GenreId = t.GenreId
JOIN InvoiceLine l
ON l.TrackId = t.TrackId
GROUP BY 1
ORDER BY 2 DESC
LIMIT 1;

-- 1.2 amount purchased

SELECT g.Name AS genre_name,
       STRFTIME('%Y/%m', i.InvoiceDate) AS invoice_date,
       SUM(l.UnitPrice) AS usd_purchase
FROM Genre g
JOIN Track t
ON g.GenreId = t.GenreId
JOIN InvoiceLine l
ON l.TrackId = t.TrackId
JOIN Invoice i
ON i.InvoiceId = l.InvoiceId
GROUP BY 1,2;


--1.3 Final Query

SELECT g.Name AS genre_name,
       STRFTIME('%m', i.InvoiceDate) AS invoice_date,
       SUM(l.UnitPrice) AS usd_purchases
FROM Genre g
JOIN Track t
ON g.GenreId = t.GenreId
JOIN InvoiceLine l
ON l.TrackId = t.TrackId
JOIN Invoice i
ON i.InvoiceId = l.InvoiceId
GROUP BY 1,2
HAVING g.Name = (SELECT genre_name
                 FROM(SELECT g.Name AS genre_name, COUNT(l.InvoiceLineId)
                      FROM Genre g
                      JOIN Track t
                      ON g.GenreId = t.GenreId
                      JOIN InvoiceLine l
                      ON l.TrackId = t.TrackId
                      JOIN Invoice i
                      ON i.InvoiceId = l.InvoiceId
                      GROUP BY 1
                      ORDER BY 2 DESC
                      LIMIT 1))
ORDER BY 1;

/* 2 How Much of each Genre the most effective Sales Support sold */

-- 2.1 The Employee that sold the most

SELECT e.EmployeeId AS employee_id,
       e.FirstName,
       e.LastName,
       COUNT(l.InvoiceLineId)
FROM Employee e
JOIN Customer c
ON c.SupportRepId = e.EmployeeId
JOIN Invoice i
ON i.CustomerId = c.CustomerId
JOIN InvoiceLine l
ON l.InvoiceId = i.InvoiceId
GROUP BY 1,2,3
ORDER BY 3 DESC
LIMIT 1;

-- 2.2 The Amount of sales for each Genre

SELECT g.Name AS genre_name, SUM(l.UnitPrice) AS amt_sold
FROM Genre g
JOIN Track t
ON g.GenreId = t.GenreId
JOIN InvoiceLine l
ON t.TrackId = l.TrackId
GROUP BY 1
ORDER BY 2;

-- 2.3 SalesRep per Genre

SELECT g.Name AS genre_name,
       e.FirstName,
       SUM(l.UnitPrice) AS amt_sold
FROM Genre g
JOIN Track t
ON g.GenreId = t.GenreId
JOIN InvoiceLine l
ON t.TrackId = l.TrackId
JOIN Invoice i
ON l.InvoiceId = i.InvoiceId
JOIN Customer c
ON i.CustomerId = c.CustomerId
JOIN Employee e
ON c.SupportRepId = e.EmployeeId
GROUP BY 1,2;


-- 2.4 Final Query

SELECT e.EmployeeId,
	     g.Name AS genre_name,
       SUM(l.UnitPrice) AS amt_sold,
       e.FirstName || ' ' || e.LastName AS employee_name
FROM Genre g
JOIN Track t
ON g.GenreId = t.GenreId
JOIN InvoiceLine l
ON t.TrackId = l.TrackId
JOIN Invoice i
ON l.InvoiceId = i.InvoiceId
JOIN Customer c
ON i.CustomerId = c.CustomerId
JOIN Employee e
ON c.SupportRepId = e.EmployeeId
GROUP BY 2,1,4
  HAVING e.EmployeeId = (SELECT employee_id AS best_sales_id
                         FROM(SELECT e.EmployeeId AS employee_id,
                                     COUNT(l.InvoiceLineId)
                              FROM Employee e
                              JOIN Customer c
                              ON c.SupportRepId = e.EmployeeId
                              JOIN Invoice i
                              ON i.CustomerId = c.CustomerId
                              JOIN InvoiceLine l
                              ON l.InvoiceId = i.InvoiceId
                              GROUP BY 1
                              ORDER BY 2 DESC
                              LIMIT 1
                              )
                         )
ORDER BY 3;

/* 3 - Number of repurchase by Track */

SELECT COUNT(number_sold),
	   number_sold
	   FROM(
			SELECT t.Name track_name,
				   COUNT(l.InvoiceLineId) number_sold
			FROM Genre g
			JOIN Track t
			ON t.GenreId = g.GenreId
			JOIN InvoiceLine l
			ON t.TrackId = l.TrackId
			GROUP BY 1
			ORDER BY 2)
GROUP BY 2;

/* 4 - Download size per Customer */

SELECT c.CustomerId,
       c.FirstName || ' ' || c.LastName AS name,
       (SUM(t.Bytes)/1000000) AS download_size_MB,
	   CASE WHEN (SUM(t.Bytes)/1000000) >= 500 AND (SUM(t.Bytes)/1000000) > 200 THEN "Median"
			    WHEN (SUM(t.Bytes)/1000000) <= 200 THEN "Small"
			    ELSE "Large" END AS size
FROM Customer c
JOIN Invoice i
ON i.CustomerId = c.CustomerId
JOIN InvoiceLine l
ON l.InvoiceId = i.InvoiceId
JOIN Track t
ON t.TrackId = l.TrackId
GROUP BY 1,2
ORDER BY 3 DESC;
