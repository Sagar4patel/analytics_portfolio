--
drop table if exists #original
select distinct *
into #original
from dbo.hospital_wait



-- Cleaning Data
ALTER TABLE dbo.hospital_wait
ALTER COLUMN Date date

-- adding more detailed columns
DROP TABLE IF EXISTS #hours
(
	SELECT
		DISTINCT Patient_ID,
		DATEDIFF(minute, [Entry_Time], [Completion_Time]) as wait_time_minutes,
		DATENAME(dw, Date) as week_day,
		DATEPART(hour, Entry_Time) as hour,
		DATEDIFF(minute, [Entry_Time], [Post_Consultation_Time]) as consultation_period,
		DATEDIFF(minute, [Post_Consultation_Time], [Completion_Time]) as process_period
	INTO #hours
	from dbo.hospital_wait
)

drop table if exists #added_columns
;with cte as
(
	select 
		*,
		(1.0 *consultation_period / wait_time_minutes) * 100  as consultation_pcnt,
		ROUND((1 - (1.0 * consultation_period / wait_time_minutes)),2) * 100 as process_pcnt
	from #hours
)

select 
	Patient_ID,
	wait_time_minutes,
	week_day,
	hour,
	consultation_period,
	process_period,
	CONVERT(int,consultation_pcnt) as consultation_pcnt,
	CONVERT(int,process_pcnt) as process_pcnt
into #added_columns
from cte

-- updating original data
drop table if exists #updated_data
select
	o.*,
	wait_time_minutes,
	week_day,
	hour,
	consultation_period,
	process_period,
	consultation_pcnt,
	process_pcnt
into #updated_data
from #original o
inner join #added_columns ac
	on o.Patient_ID = ac.Patient_ID

-- select * from #updated_data

-- is Financial class a possible factor as in to why wait times are high?
;with cte2 as
(
	select 
		Financial_Class,
		COUNT(*) as cnt_of_patient_id,
		AVG(wait_time_minutes) as average_wait_min,
		(select AVG(wait_time_minutes) from #updated_data) as total_average_wait
	from #updated_data
	group by
		Financial_Class
)

select 
	Financial_Class,
	cnt_of_patient_id / SUM(cnt_of_patient_id * 1.0) over () * 100 patient_pcnt, 
	average_wait_min,
	total_average_wait
from cte2


-- is weekday a possible factor as to why wait times have been high
select 
	week_day,
	COUNT(*) as cnt_of_patient_id,
	AVG(wait_time_minutes) as average_wait_min,
	(select AVG(wait_time_minutes) from #updated_data) as total_average_wait
from #updated_data
group by
	week_day

-- is a specific hour a factor as to why wait times have been high

select 
	hour,
	week_day,
	AVG(wait_time_minutes) as average_wait_min
from #updated_data
group by
	hour, week_day
order by
	1 



