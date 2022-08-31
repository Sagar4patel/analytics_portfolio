--select * from dbo.insurance_data

-- Building Average Customer Profile
-- sex
;with cte as
(
	select
		sex,
		count(*) as count_of_sex
	from dbo.insurance_data
	group by
		sex
)

select 
	sex,
	count_of_sex / SUM(count_of_sex * 1.0) over() * 100 as pcnt_of_sex
from cte

-- allocation of region
;with cte as
(
	select
		region,
		COUNT(region) as cnt_of_region
	from dbo.insurance_data
	group by
		region
)

select
	region,
	cnt_of_region / sum(cnt_of_region * 1.0) over() * 100 as pcnt_of_region
from cte

-- allocation of children count
;with cte as
(
	select
		children,
		count(*) as cnt_of_children
	from dbo.insurance_data
	group by
		children
)

select
	children,
	cnt_of_children / SUM(cnt_of_children * 1.0) over() * 100 as pcnt_of_children 
from cte

-- smoker vs nonsmoker allocation
;with cte as
(
	select
		smoker,
		COUNT(*) as cnt_of_smoker
	from dbo.insurance_data
	group by
		smoker
)

select
	smoker,
	cnt_of_smoker / sum(cnt_of_smoker * 1.0) over() * 100 as pcnt_of_smoker 
from cte

-- average charges by gender
select
	sex,
	avg(Charges) as av_charge_gender
from dbo.insurance_data
group by
	sex

-- average charges for smokers and nonsmokers
select
	smoker,
	avg(Charges) as avg_charge_smoker
from dbo.insurance_data
group by
	smoker

-- averages charges for smokers and nonsmokers
select
	region,
	avg(Charges) as avg_charge_region
from dbo.insurance_data
group by
	region

-- calculating age and bmi correlation with charges
select
	(AVG(age * Charges) - (AVG(age) * AVG(Charges))) / (STDEVP(Age) * STDEVP(charges)) as age_correlation
from dbo.insurance_data

select
	(AVG(bmi * Charges) - (AVG(bmi) * AVG(Charges))) / (STDEVP(bmi) * STDEVP(charges)) as bmi_correlation
from dbo.insurance_data

-- Linear reggression 
DROP TABLE IF EXISTS #causation
select
	age,
	bmi,
	children,
	case when sex = 'female' then 1 else 0 end as female,
	case when region = 'southeast' then 1 else 0 end as Southeast,
	case when region = 'southwest' then 1 else 0 end as Southwest,
	case when region = 'northeast' then 1 else 0 end as Northeast,
	case when smoker = 'yes' then 1 else 0 end as Smoker,
	charges
into #causation
from dbo.insurance_data

-- calculating the age slope
select sum((age - age_bar) * (charges - charges_bar)) / sum((age - age_bar) * (age - age_bar)) as slope
from (
		select
			age,
			avg(age) over() as age_bar,
			charges,
			AVG(charges) over() as charges_bar
		from #causation
	) age_slope

-- bmi slope
select sum((bmi - bmi_bar) * (charges - charges_bar)) / sum((bmi - bmi_bar) * (bmi - bmi_bar)) as slope
from (
		select
			bmi,
			avg(bmi) over() as bmi_bar,
			charges,
			AVG(charges) over() as charges_bar
		from #causation
	) bmi_slope

-- children slope
select sum((children - children_bar) * (charges - charges_bar)) / sum((children - children_bar) * (children - children_bar)) as slope
from (
		select
			children,
			avg(children) over() as children_bar,
			charges,
			AVG(charges) over() as charges_bar
		from #causation
	) children_slope

-- smoker slope
select sum((smoker - smoker_bar) * (charges - charges_bar)) / sum((Smoker - smoker_bar) * (Smoker - smoker_bar)) as slope
from (
		select
			Smoker,
			avg(Smoker) over() as smoker_bar,
			charges,
			AVG(charges) over() as charges_bar
		from #causation
	) smoker_slope