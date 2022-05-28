

select * from dbo.jeff_data
-- What is the summary of all approved SBA 7a Loans ---
select
	year(ApprovalDate) year_approved,
	count(distinct LenderName) OriginatingLender,
	count(*) Number_of_Approved,
	sum(CAST(GrossApproval as bigint)) Approved_Amount,
	avg(cast(GrossApproval as bigint)) Average_Loan_Size
FROM dbo.jeff_data
where
	year(ApprovalDate) = 2020
group by
	year(ApprovalDate)

union
	
select
	year(ApprovalDate) year_approved,
	count(distinct LenderName) OriginatingLender,
	count(*) Number_of_Approved,
	sum(CAST(GrossApproval as bigint)) Approved_Amount,
	avg(cast(GrossApproval as bigint)) Average_Loan_Size
FROM dbo.jeff_data
where
	year(ApprovalDate) = 2021
group by
	year(ApprovalDate)

-- TOP 15 Originating Lenders by loan count, total amount and average in 2020 and 2021

select top 15
	LenderName,
	count(*) Number_of_Approved,
	sum(CAST(GrossApproval as bigint)) Approved_Amount,
	avg(cast(GrossApproval as bigint)) Average_Loan_Size
FROM dbo.jeff_data
where
	year(ApprovalDate) = 2021
group by
	LenderName
order by 3 desc


select top 15
	LenderName,
	count(*) Number_of_Approved,
	sum(CAST(GrossApproval as bigint)) Approved_Amount,
	avg(cast(GrossApproval as bigint)) Average_Loan_Size
FROM dbo.jeff_data
where
	year(ApprovalDate) = 2020
group by
	LenderName
order by 3 desc

-- top 20 industries that recieved SBA 7a in 2021 and 2020
select top 20
	NaicsDescription,
	count(*) Number_of_Approved,
	sum(CAST(GrossApproval as bigint)) Approved_Amount,
	avg(cast(GrossApproval as bigint)) Average_Loan_Size
FROM dbo.jeff_data
WHERE
	year(ApprovalDate) = 2020
group by
	NaicsDescription
order by 3 desc

-- percent allocation of loans given out by each industry
;with cte as
(
select top 20
	NaicsDescription,
	count(*) Number_of_Approved,
	sum(CAST(GrossApproval as bigint)) Approved_Amount,
	avg(cast(GrossApproval as bigint)) Average_Loan_Size
FROM dbo.jeff_data
WHERE
	year(ApprovalDate) = 2020
group by
	NaicsDescription
order by 3 desc
)
select NaicsDescription, Number_of_Approved, Approved_Amount, Average_Loan_Size,
Approved_Amount / sum(Approved_Amount * 1.0) over() * 100 as percent_by_amt
from cte
order by 5 desc

-- top 20 industries that supported the most jobs 
select top 20 NaicsDescription,
	   sum(cast(GrossApproval as bigint)) as Approved_Amount,
	   sum(JobsSupported) as JobsSupported
from dbo.jeff_data
where 
	YEAR(ApprovalDate) = 2021
group by 
	NaicsDescription
order by 
	JobsSupported desc

	-- the allocation percent of jobs supported by each industry
;with cte as
	(select top 20 NaicsDescription,
		   sum(cast(GrossApproval as bigint)) as Approved_Amount,
		   sum(JobsSupported) as JobsSupported
	from dbo.jeff_data
	where 
		YEAR(ApprovalDate) = 2021
	group by 
		NaicsDescription
	order by 
		JobsSupported desc
)

select NaicsDescription,
	   Approved_Amount,
	   JobsSupported,
	   JobsSupported / sum(JobsSupported * 1.0) over() * 100 as percent_by_job
from cte

-- top 10 lenders with the most approved of loans for 2020  for hotels and motels
select top 10
	LenderName,
	NaicsDescription,
	count(*) Number_of_Approved,
	sum(CAST(GrossApproval as bigint)) Approved_Amount,
	avg(cast(GrossApproval as bigint)) Average_Loan_Size
FROM dbo.jeff_data
where
	YEAR(ApprovalDate) = 2021 and
	NaicsDescription like '%motel%'
group by
	LenderName,
	NaicsDescription
order by Number_of_Approved desc

-- top 15 franchise hotels  with the most amount of loans given out.
select top 15
	FranchiseName,
	COUNT(*) as Number_of_Approved,
	SUM(GrossApproval) as total_approved_amount,
	AVG(GrossApproval) as average_approved_amount
from dbo.jeff_data
where
	--year(ApprovalDate) = 2019 and
	NaicsDescription like '%motel%' and
	FranchiseCode is null 
group by 
	FranchiseName
order by total_approved_amount desc







