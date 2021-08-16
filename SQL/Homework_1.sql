-- Задание 1: Вывести name, class по кораблям, выпущенным после 1920

select name, class from ships
where launched > 1920

-- Задание 2: Вывести name, class по кораблям, выпущенным после 1920, но не позднее 1942

select name, class from ships
where launched > 1920 and 
launched <= 1942

-- Задание 3: Какое количество кораблей в каждом классе. Вывести количество и class

select class, count(*) from ships
group by class

-- Задание 4: Для классов кораблей, калибр орудий которых не менее 16, укажите класс и страну. (таблица classes)

select class, country from classes
where bore >= 16

-- Задание 5: Укажите корабли, потопленные в сражениях в Северной Атлантике (таблица Outcomes, North Atlantic). Вывод: ship.

select ship from outcomes
where battle = 'North Atlantic' and
result = 'sunk'

-- Задание 6: Вывести название (ship) последнего потопленного корабля

select ship from outcomes o
inner join battles b on
o.battle = b.name
where result = 'sunk'
and date in
	(
	select max(date) from outcomes o
	inner join battles b on
	o.battle = b.name
	where result = 'sunk')
	
-- Задание 7: Вывести название корабля (ship) и класс (class) последнего потопленного корабля
	
select ship, class from outcomes o
full outer join ships s
on o.ship = s.name
where ship in 
	(select ship from outcomes o
	inner join battles b on
	o.battle = b.name
	where result = 'sunk'
	and date in
		(select max(date) from outcomes o
		inner join battles b on
		o.battle = b.name
		where result = 'sunk'))
		
-- Задание 8: Вывести все потопленные корабли, у которых калибр орудий не менее 16, и которые потоплены. Вывод: ship, class
		
select ship, class from outcomes o
join 
(
select * from ships where 
class in 
	(select class from classes
	where bore >= 16)
) s
on o.ship = s.name
where result = 'sunk' 

-- Задание 9: Вывести все классы кораблей, выпущенные США (таблица classes, country = 'USA'). Вывод: class

select class from classes
where country = 'USA'

-- Задание 10: Вывести все корабли, выпущенные США (таблица classes & ships, country = 'USA'). Вывод: name, class

select name, c.class from ships s 
join classes c on
s.class = c.class
where country = 'USA'