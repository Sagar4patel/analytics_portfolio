

--What is the total number of parts per theme

--create view dbo.analytics_main as

select s.set_num, s.name, s.year, s.theme_id, CAST(s.num_parts as numeric) num_parts, t.name as theme_name, t.parent_id, p.name as parent_theme_name
from dbo.sets s
left join dbo.themes t
	on s.theme_id = t.id
left join dbo.themes p
	on t.parent_id = p.id

select theme_name, sum(num_parts) as total_num_parts
from dbo.analytics_main
--where parent_theme_name is not null
group by theme_name
order by 2 desc

-- What is the total number of parts per year
select year, sum(num_parts) as total_num_parts
from dbo.analytics_main
where parent_theme_name is not null
group by year
order by 2 desc

--How many sets were created in each Century
select Century, count(set_num) as total_set_num
from dbo.analytics_main
where parent_theme_name is not null
group by Century
--order by 2 desc


--What percentage of sets released in the 21st_Century were Star wars themed

;with cte as
(
	select Century, theme_name, count(set_num) total_set_num
	from dbo.analytics_main
	where Century = '21st_Century'
	group by Century, theme_name
)
select SUM(total_set_num), sum(Percentage)
from(
	select Century, theme_name, total_set_num, sum(total_set_num) OVER() as total, cast((1.0 * total_set_num / sum(total_set_num) OVER()) as decimal(5,4)) * 100 Percentage
	from cte
	)m
where theme_name like '%Disney%'
	--order by 3 desc

-- What was the most popular theme by year in terms of sets released in the 21st_Century
select year, theme_name, total_set_num
from (
	select year,theme_name,count(set_num) total_set_num, ROW_NUMBER() OVER(partition by year order by count(set_num) desc)  rn
	from analytics_main
	where Century = '21st_Century'
	group by year, theme_name
)m
where rn = 1
order by year desc

-- What is the most produced color of lego over in terms of quantity of parts

select color_name, sum(quantity) as quantity_of_parts
from
	(
		select 
			inv.color_id, inv.inventory_id, CAST(inv.quantity as numeric) quantity, inv.is_spare, c.name as color_name, c.rgb, p.name as part_name, p.part_material, pc.name as category_name 
		from dbo.inventory_parts inv
		inner join colors c
			on inv.color_id = c.id
		inner join dbo.parts p 
			on inv.part_num = p.part_num
		inner join dbo.part_categories pc
			on part_cat_id = pc.id
	) main
group by color_name
order by 2 desc