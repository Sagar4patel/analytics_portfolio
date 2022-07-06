select * from dbo.airline_passenger_satisfaction

DROP TABLE IF EXISTS #temp1
select 
	ID, Gender, Age, Customer_Type, Type_of_Travel, Class, Departure_Delay, Arrival_Delay, Satisfaction
into #temp1
from dbo.airline_passenger_satisfaction

select * 
from #temp1


-- what is the percent allocation by flight class
;with cte as
(
	select Class, COUNT(*) as total
	from #temp1
	group by Class
)
select 
	Class, total, total / sum(total * 1.0) over() * 100 as percent_by_class 
from cte

-- how many males and females were satisfied
select 
	Gender, count(*) as count_of_gender
from #temp1
where 
	Satisfaction = 'Satisfied'
group by 
	Gender

--which customer type was the most dissastisfied / neutral
select 
	Type_of_Travel, Customer_Type, COUNT(*) as count_of_dissastified
from #temp1
where 
	Satisfaction = 'Neutral or Dissatisfied'
group by 
	Type_of_Travel, Customer_Type



DROP TABLE IF EXISTS #temp2
select 
	ID,Gender,Age,Customer_Type,Type_of_Travel,Class,(Departure_Delay+Arrival_Delay) as total_delay, Satisfaction
into #temp2
from #temp1

-- Average delay time by each class

select 
	*,
	avg(total_delay) OVER(PARTITION BY Class) average_delay
from #temp2
order by average_delay desc

-- How many males and females took personal and business trips
select 
	Gender, Type_of_Travel, count(*) count_of_trip
from #temp2
group by 
	Gender, Type_of_Travel
order by 
	count_of_trip desc

--select * from #temp2

-- Average age and age buckets
;with r as
(
	select 
		Gender, Age, avg(age) OVER(PARTITION BY GENDER) average_age
	from #temp2
) 
select r.*,
	   NTILE(4) OVER (order by Age) as bucket
from r


-- what is the average flight distance for each type of travel and class?

select 
	Type_of_Travel, Class, avg(Flight_Distance) as avg_distance
from dbo.airline_passenger_satisfaction
group by 
	Type_of_Travel, Class
order by 
	avg_distance desc


-- what is the average customer satisfaction rating?
DROP TABLE if exists #temp3
select ID, Gender, Age, Customer_Type, Type_of_Travel, Class, Flight_Distance, Departure_Delay, Arrival_Delay,
		(Departure_and_Arrival_Time_Convenience + Ease_of_Online_Booking + Check_in_Service + Online_Boarding + Gate_Location + On_board_Service + Seat_Comfort +
		Leg_Room_Service + Cleanliness + Food_and_Drink + In_flight_Service + In_flight_Wifi_Service + In_flight_Entertainment + Baggage_Handling) / 14 as average_rating,
		Satisfaction
into #temp3
from dbo.airline_passenger_satisfaction

--select * from #temp3

;with t as
(
	select 
		Customer_Type, Type_of_Travel, Class, avg(average_rating) as avg_rating_per_type
	from #temp3
	group by 
		Customer_Type, Type_of_Travel, Class
)

select *,
	case when avg_rating_per_type < 3 then 'Neutral or Dissastisfied'
	else 'satisfied'
	end as satisfaction_by_class
from t





