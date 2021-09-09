--task6 (lesson9)
-- Компьютерная фирма: Получить количество ПК и среднюю цену для каждой модели, средняя цена которой менее 800

with t1 as 
(
select model, avg from 
	(
		select distinct model, avg(price) 
		over (partition by model)
		from pc
	) a
	where avg < 800
)
select t1.model, count, avg from
(
	select model, count(*)
	from pc group by model having model in
	(select model from t1) 
) t2
join t1 on t1.model = t2.model

БОЛЕЕ ОПТИМАЛЬНО

select distinct *, count(*) 
over (partition by model) 
from 
(
	select model, avg from 
	(
		select  model, avg(price) 
		over (partition by model)
		from pc
	) a
		where avg < 800
) b

--task1  (lesson9)
-- oracle: https://www.hackerrank.com/challenges/the-report/problem

select case
    when Grades < 8
    then null
    else Name
    end Name,
Grades, Marks from 
(
    select Name, case
        when floor(Marks / 10) != 10
        then floor(Marks / 10) + 1 
        else 10
        end Grades, 
    Marks from Students
) t 
order by Grades desc, Name, Marks;

--task2  (lesson9)
-- oracle: https://www.hackerrank.com/challenges/occupations/problem

select * from
(
    select Name, Occupation, row_number () over (partition by Occupation order by Name) rn 
    from occupations
) t1
pivot
(min(Name) for Occupation in ('Doctor', 'Professor', 'Singer', 'Actor')) 
order by rn;

--task3  (lesson9)
-- oracle: https://www.hackerrank.com/challenges/weather-observation-station-9/problem

select distinct city from station
where substr(city, 1, 1) not in ('A', 'E', 'I', 'O', 'U');

--task4  (lesson9)
-- oracle: https://www.hackerrank.com/challenges/weather-observation-station-10/problem

select distinct city from station
where substr(city, -1, 1) not in ('a', 'e', 'i', 'o', 'u');

--task5  (lesson9)
-- oracle: https://www.hackerrank.com/challenges/weather-observation-station-11/problem

select distinct city from station
where lower(substr(city, -1, 1)) not in ('a', 'e', 'i', 'o', 'u')
or lower(substr(city, 1, 1)) not in ('a', 'e', 'i', 'o', 'u');

--task6  (lesson9)
-- oracle: https://www.hackerrank.com/challenges/weather-observation-station-12/problem

select distinct city from station
where lower(substr(city, -1, 1)) not in ('a', 'e', 'i', 'o', 'u')
and lower(substr(city, 1, 1)) not in ('a', 'e', 'i', 'o', 'u');

--task7  (lesson9)
-- oracle: https://www.hackerrank.com/challenges/salary-of-employees/problem

select name from Employee 
where salary > 2000 and months < 10
order by employee_id;

--task8  (lesson9)
-- oracle: https://www.hackerrank.com/challenges/the-report/problem

select case
    when Grades < 8
    then null
    else Name
    end Name,
Grades, Marks from 
(
    select Name, case
        when floor(Marks / 10) != 10
        then floor(Marks / 10) + 1 
        else 10
        end Grades, 
    Marks from Students
) t 
order by Grades desc, Name, Marks;

