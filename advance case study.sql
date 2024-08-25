--SQL Advance Case Study


--Q1--BEGIN 
	
	SELECT State,Date FROM FACT_TRANSACTIONS AS T1
	INNER JOIN DIM_LOCATION AS T2 
	ON T1.IDLocation = T2.IDLocation
	INNER JOIN DIM_MODEL AS T3
	ON T1.IDModel = T3.IDModel
	WHERE Date BETWEEN '01-01-2005' AND GETDATE()
	order by State

--Q1--END
	

	
--Q2--BEGIN

select top 1 Country,State,sum(Quantity) as total_qnty
from DIM_LOCATION as l
inner join FACT_TRANSACTIONS as t
on l.IDLocation=t.IDLocation
inner join DIM_MODEL as m
on t.IDModel=m.IDModel
inner join DIM_MANUFACTURER as dm
on m.IDManufacturer=dm.IDManufacturer
where Country = 'us' and Manufacturer_Name = 'samsung'
group by Country,State
order by sum(Quantity) desc

--Q2--END

--Q3--BEGIN      


select Model_Name,ZipCode,State,count(IDCustomer) as transactions
from DIM_LOCATION as l
inner join FACT_TRANSACTIONS as t
on l.IDLocation=t.IDLocation
inner join DIM_MODEL as m
on t.IDModel=m.IDModel
group by Model_Name,ZipCode,State
order by COUNT(IDCustomer) desc


--Q3--END

--Q4--BEGIN

select top 1 Model_Name,Unit_price
from DIM_MODEL
group by Model_Name,Unit_price
order by Unit_price

--Q4--END

--Q5--BEGIN

select top 5 Model_Name,avg(TotalPrice) as average_price,sum(Quantity) as qty
from FACT_TRANSACTIONS as t
inner join DIM_MODEL as m
on t.IDModel=m.IDModel
inner join DIM_MANUFACTURER as dm
on m.IDManufacturer=dm.IDManufacturer
group by Model_Name
order by average_price desc


--Q5--END

--Q6--BEGIN

select Customer_Name,avg(TotalPrice) as avg_spend,Date
from DIM_CUSTOMER as c
inner join FACT_TRANSACTIONS as t
on c.IDCustomer=t.IDCustomer
where year(Date)=2009
group by Customer_Name,Date
having avg(TotalPrice)>500


--Q6--END
	
--Q7--BEGIN  
	
select distinct top 5 Model_Name,SUM(Quantity) as qty,Date
from DIM_MODEL as m
inner join FACT_TRANSACTIONS as t
on m.IDModel=t.IDModel
where year(date) in (2008,2009,2010)
group by Model_Name,Date
order by qty desc


--Q7--END	



--Q8--BEGIN

SELECT top 1  MANUFACTURER_NAME
FROM DIM_MANUFACTURER T1
INNER JOIN DIM_MODEL T2 ON T1.IDMANUFACTURER= T2.IDMANUFACTURER
INNER JOIN FACT_TRANSACTIONS T3 ON T2.IDMODEL= T3.IDMODEL
GROUP BY MANUFACTURER_NAME
ORDER BY SUM(TOTALPRICE) DESC


--Q8--END


--Q9--BEGIN

SELECT MANUFACTURER_NAME FROM DIM_MANUFACTURER T1
INNER JOIN DIM_MODEL T2 ON T1.IDMANUFACTURER= T2.IDMANUFACTURER
INNER JOIN FACT_TRANSACTIONs T3 ON T2.IDMODEL= T3.IDMODEL
WHERE YEAR(Date) = 2010
EXCEPT
SELECT MANUFACTURER_NAME FROM DIM_MANUFACTURER t1
INNER JOIN DIM_MODEL T2 ON T1.IDMANUFACTURER= T2.IDMANUFACTURER
INNER JOIN FACT_TRANSACTIONs T3 ON T2.IDMODEL= T3.IDMODEL
WHERE YEAR(Date) = 2009
	

--Q9--END

--Q10--BEGIN


with top_100
as(
select top 100 IDCustomer,sum(TotalPrice) as avg_spend, avg(Quantity) avg_quantity
from FACT_TRANSACTIONS
group by IDCustomer
order by avg_spend
 ),

yearly_spend
 as(
select x1.IDCustomer,year(date) years,avg(TotalPrice) as spend ,avg(Quantity) as avg_quantity
from FACT_TRANSACTIONS as x1 inner join DIM_CUSTOMER  as x2
on x1.IDCustomer=x2.IDCustomer
where  x1.IDCustomer in(select IDCustomer from top_100 )
group by x1.IDCustomer,year(Date)

),

prev_years_data
as(
select*,lag(spend,1)over(partition by IDCustomer order by years,spend) as prev_sales
from yearly_spend
  )

select*,(spend-prev_sales)/prev_sales*100 as [changein%tage]
from prev_years_data
	

--Q10--END
	