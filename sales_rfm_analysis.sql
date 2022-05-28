

-- Inspecting the Data
select * from dbo.superstore_data

-- checking unique values
select distinct Segment from dbo.superstore_data
select distinct year(Order_Date) year_id from dbo.superstore_data order by year_id
select distinct Category from dbo.superstore_data
select distinct Sub_Category from dbo.superstore_data
select distinct Product_Name from dbo.superstore_data

--Analysis
--Grouping sales by Categories

select Sub_Category, sum(sales) Revenue
from dbo.superstore_data
group by Sub_Category
order by 2 desc

select year(Order_Date) year_id, sum(sales) Revenue
from dbo.superstore_data
group by year(Order_Date)
order by 2 desc

-- sales by state and percentage
DROP TABLE IF EXISTS #sales
;with cte as
(
	select State, sum(sales) Revenue
	from dbo.superstore_data
	where YEAR(Order_Date) = 2017
	group by State
)
select *, Revenue / sum(revenue * 1.0) over() * 100 as percent_by_sales 
into #sales
from cte
order by 3 desc

-- profit by state and percentage
DROP TABLE IF EXISTS #profit
;with cte as
(
	select State, sum(Profit) Profit
	from dbo.superstore_data
	where YEAR(Order_Date) = 2017
	group by State
)
select *, Profit / sum(Profit * 1.0) over() * 100 as percent_by_profit 
into #profit
from cte
order by 3 desc

-- combining Profit and Sales and comparing
select s.State, Revenue, percent_by_sales, Profit, percent_by_profit 
from #sales s
inner join #profit p
	on s.State = p.State
order by 4 desc


-- What was the best month for sales in a specific year? How much was earned that month?
Select month(Order_Date)month_id, sum(sales)Revenue, count(Order_ID) Frequency
from dbo.superstore_data
where YEAR(Order_Date) = 2017
group by month(Order_Date)
order by 2 desc

-- November seems to be best month, what sub category of products sell the most
select month(Order_Date)month_id, Sub_Category, sum(sales)Revenue, count(Order_ID) Frequency
from dbo.superstore_data
where YEAR(Order_Date) = 2017 and month(Order_Date) = 11
group by month(Order_Date), Sub_Category
order by 3 desc

--Who is our best customer RFM Analysis
DROP TABLE IF EXISTS #rfm
;with rfm as
(
	select
		Customer_Name,
		sum(Sales) MonetaryValue,
		avg(Sales) AvgMonetaryValue,
		count(Order_Id) Frequency,
		max(Order_Date) last_order_date,
		(select max(Order_Date) from dbo.superstore_data) max_order_date,
		DATEDIFF(DD, max(Order_Date), (select max(Order_Date) from dbo.superstore_data)) Recency
	from dbo.superstore_data
	group by Customer_Name
),
rfm_calc as
(

	select r.*,
		NTILE(4) OVER (order by Recency Desc) rfm_recency,
		NTILE(4) OVER (order by Frequency) rfm_frequency,
		NTILE(4) OVER (order by MonetaryValue) rfm_monetary
	from rfm r
)
select 
	c.*, rfm_recency + rfm_frequency + rfm_monetary as rfm_cell,
	cast(rfm_recency as varchar) + cast(rfm_frequency as varchar) + cast(rfm_monetary as varchar)rfm_cell_string
into #rfm
from rfm_calc c

select Customer_Name, rfm_recency, rfm_frequency, rfm_monetary,
	case when rfm_cell_string in (111,112,121,122,123,132,211,212,114,141) then 'lost_customers' -- lost customers
		 when rfm_cell_string in (133,134,143,244,334,343,344,144) then 'slipping away' -- slipping away
		 when rfm_cell_string in (311,411,331) then 'new customers'
		 when rfm_cell_string in (222,223,233,322) then 'potential churners'
		 when rfm_cell_string in (323,333,321,422,332,432) then 'active'
		 when rfm_cell_string in (433,434,443,444) then 'loyal'
	end rfm_segment
from #rfm

