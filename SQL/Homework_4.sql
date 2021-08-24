--task11 (lesson5)
-- Компьютерная фирма: Построить график с со средней и максимальной ценами на базе products_with_lowest_price
-- (X: maker, Y1: max_price, Y2: avg)price

-- См. jupyter notebook

--task12 (lesson5)
-- Компьютерная фирма: Сделать view, в которой будет постраничная разбивка всех laptop 
-- (не более двух продуктов на одной странице). Вывод: все данные из laptop, номер страницы, список всех страниц

create view laptop_pages as
select *, row_number ()
over (partition by page)
item from
(
	select *, ntile (3)
	over () page
	from laptop
) a 

--task1 (lesson5)
-- Компьютерная фирма: Сделать view (pages_all_products), в которой будет постраничная разбивка всех продуктов
-- (не более двух продуктов на одной странице). Вывод: все данные из laptop, номер страницы, список всех страниц


create or replace view pages_all_products as
select *, row_number ()
over (partition by page) item from 
(
	select *, ntile(12)
	over (order by code) page from 
	(
		select code, p.model, price, p.type from pc
		join product p on p.model = pc.model
		union all
		select code, p.model, price, p.type from printer pr
		join product p on p.model = pr.model
		union all
		select code, p.model, price, p.type from laptop l
		join product p on p.model = l.model
	) a
) b

--task2 (lesson5)
-- Компьютерная фирма: Сделать view (distribution_by_type), в рамках которого будет процентное соотношение 
-- всех товаров по типу устройства. Вывод: производитель,

-- Простой перебор всех производителей:

create or replace view distribution_by_type as

select distinct maker, type, 
count(*) over (partition by type) * 100 / 
(select count(*) from product where maker = 'A' group by maker)
as total_share_percent
from product
where maker = 'A'
	union
select distinct maker, type, 
count(*) over (partition by type) * 100 / 
(select count(*) from product where maker = 'B' group by maker)
from product
where maker = 'B'
	union
select distinct maker, type, 
count(*) over (partition by type) * 100 / 
(select count(*) from product where maker = 'C' group by maker)
from product
where maker = 'C'
	union
select distinct maker, type, 
count(*) over (partition by type) * 100 / 
(select count(*) from product where maker = 'D' group by maker)
from product
where maker = 'D'
	union
select distinct maker, type, 
count(*) over (partition by type) * 100 / 
(select count(*) from product where maker = 'E' group by maker)
from product
where maker = 'E'
order by maker

-- Попытка проитерироваться по всем имеющимся производителям:

declare @LoopCounter INT = 1, 
@MaxMaker INT = select count(*) from
				(select distinct maker 
				from product) t , 
@Maker NVARCHAR(10)

WHILE(@LoopCounter <= @MaxMaker)
BEGIN
   SELECT @Maker = maker
   FROM (select maker, row_number () over () rn
		 from (
		 	   select distinct maker 
			   from product
			   ) a
		) b
	WHERE rn = @LoopCounter
 
   create or replace view distribution_by_type as
   select * from distribution_by_type
   union
   select distinct maker, type, 
   count(*) over (partition by type) * 100 / 
   (select count(*) from product where maker = @Maker group by maker)
   as total_share_percent
   from product
   where maker = @Maker
   
   SET @LoopCounter  = @LoopCounter  + 1        

END

--task3 (lesson5)
-- Компьютерная фирма: Сделать на базе предыдущенр view график - круговую диаграмму

-- См. jupyter notebook

--task4 (lesson5)
-- Корабли: Сделать копию таблицы ships (ships_two_words), но у название корабля должно состоять из двух слов

create table ships_two_words as
select * from ships
where name like '% %'

--task5 (lesson5)
-- Корабли: Вывести список кораблей, у которых class отсутствует (IS NULL) и название начинается с буквы "S"

select name from
(
	with a as
		(
		select name from ships
		union 
		select ship from outcomes
		)
	select a.name, class from a 
	left join ships s
	on a.name = s.name
) b 
left join classes c
on b.class = c.class
where c.class is null
and name like 'S%'


--task6 (lesson5)
-- Компьютерная фирма: Вывести все принтеры производителя = 'A' со стоимостью выше средней по принтерам производителя = 'C'
-- и три самых дорогих (через оконные функции). Вывести model

with a as
(
	select *, avg(price)
	over (partition by maker),
	rank () over (partition by maker order by price desc) rn
	from printer pr
	join product p on
	p.model = pr.model
)
select * from a
where maker = 'A'
and (price > (select avg from a where maker = 'C' limit 1)
or rn <= 3)


