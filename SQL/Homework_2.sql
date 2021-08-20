--task16
--Корабли: Укажите сражения, которые произошли в годы, не совпадающие ни с одним из годов спуска кораблей на воду. (через with)

with y as 
(select * from ships)
select name from battles
where EXTRACT(YEAR from date) not in 
(select launched from y)

--task17
--Корабли: Найдите сражения, в которых участвовали корабли класса Kongo из таблицы Ships.

select battle from ships s
join outcomes o
on s.name = o.ship
where class = 'Kongo'

--task1
--Корабли: Для каждого класса определите число кораблей этого класса, потопленных в сражениях. Вывести: класс и число потопленных кораблей.

with t1 as
(
	with t2 as
	(
		select s.name, c.class from ships s
		full outer join classes c
		on s.class = c.class
	)
	select class,  
	case 
		when name is null
		then class
		else name
	end ship_name
	from t2
)
select class, count(*) as sunk from t1
full outer join
outcomes o
on o.ship = t1.ship_name
where result = 'sunk'
group by class

--task2
--Корабли: Для каждого класса определите год, когда был спущен на воду первый корабль этого класса. 
--Если год спуска на воду головного корабля неизвестен, определите минимальный год спуска на воду кораблей этого класса. Вывести: класс, год.

-- Вариант без класса Бисмарк:
with t1 as
(
	select class, name,
	case 
		when class = name
		then launched
	end d
	from ships
)
select distinct t1.class,
case 
	when d is null
	then min
	else d
end date
from 
(
	select class, min(launched) 
	from ships
	group by class
) t2
join t1
on t1.class = t2.class

-- Вариант с классом Бисмарк, по которому отсутствует дата спуска (null)
with t1 as
(
	select c.class, name, launched,
	case 
		when c.class = name
		then launched
	end d
	from ships s
	full outer join 
	classes c
	on s.class = c.class
)
select distinct t1.class,
case 
	when d is null
	then min
	else d
end date
from 
(
	select class, min(launched) 
	from t1
	group by class
) t2
join t1
on t1.class = t2.class

--task3
--Корабли: Для классов, имеющих потери в виде потопленных кораблей и не менее 3 кораблей в базе данных, вывести имя класса и число потопленных кораблей.

with t3 as
(
	with t1 as
	(
		with t2 as
		(
			select s.name, c.class from ships s
			full outer join classes c
			on s.class = c.class
		)
		select class,  
		case 
			when name is null
			then class
			else name
		end ship_name
		from t2
	)
	select class, count(*) as sunk from t1
	full outer join
	outcomes o
	on o.ship = t1.ship_name
	where result = 'sunk'
	group by class
)
select * from t3
where class in
	(
	select class from
		(select class, count(*)
		from ships
		group by class) t
	where  count >= 3
	)

--task4
--Корабли: Найдите названия кораблей, имеющих наибольшее число орудий среди всех кораблей такого же водоизмещения (учесть корабли из таблицы Outcomes).

with res as 
(
	with tab as	
	(	
		select name, c.class, numguns, displacement from 
		(
		with t1 as
			(select name from ships 
			union 
			select ship from outcomes)
		select t1.name, class from t1
		left join ships s on
		t1.name = s.name
		) t
		full outer join classes c on
		t.class = c.class
	)
	select t.displacement, numguns, name, 
	case 
		when numguns = max
		then 1
		end flag 
	from
		(
		select displacement, max(numguns) from 
			(
			with t1 as
				(select name from ships 
				union 
				select ship from outcomes)
			select t1.name, class from t1
			left join ships s on
			t1.name = s.name
			) t
		full outer join classes c on
		t.class = c.class
		group by displacement
		) t
	join tab 
	on t.displacement = tab.displacement
)
select name, displacement, numguns
from res
where flag = 1
	
	
--task5
--Компьютерная фирма: Найдите производителей принтеров, которые производят ПК с наименьшим объемом RAM
--и с самым быстрым процессором среди всех ПК, имеющих наименьший объем RAM. Вывести: Maker

with t as
(
	select * from pc
	join product p
	on pc.model = p.model
	where ram = (select min(ram) from pc)
)
select maker from t
where speed = (select max(speed) from t)
and maker in (select maker from printer)

