--task10 (lesson4)
-- Компьютерная фирма: На базе products_price_categories_with_makers по строить по каждому производителю график (X: category_price, Y: count)

-- См. jupyter notebook


--task11 (lesson4)
-- Компьютерная фирма: На базе products_price_categories_with_makers по строить по A & D график (X: category_price, Y: count)

-- См. jupyter notebook

--task12 (lesson4)
-- Корабли: Сделать копию таблицы ships, но у название корабля не должно начинаться с буквы N (ships_without_n)

create table ships_without_n as
	select * from ships
	where name 
	not like 'N%'
	
--task13 (lesson3)
--Компьютерная фирма: Вывести список всех продуктов и производителя с указанием типа продукта (pc, printer, laptop). 
--Вывести: model, maker, type
	
select * from product

--task14 (lesson3)
--Компьютерная фирма: При выводе всех значений из таблицы printer дополнительно вывести для тех, 
--у кого цена вышей средней PC - "1", у остальных - "0"

select *,
case 
	when price > (select avg(price) from pc)
	then 1
	else 0
end flag
from printer 

--task15 (lesson3)
--Корабли: Вывести список кораблей, у которых class отсутствует (IS NULL)

with t1 as
(
	select name from ships 
	union 
	select ship from outcomes
)
select distinct t1.name, class
from t1
full outer join 
ships on
t1.name = ships.name
where class is null


--task16 (lesson3)
--Корабли: Укажите сражения, которые произошли в годы, не совпадающие ни с одним из годов спуска кораблей на воду.

select name from battles
where EXTRACT(YEAR from date) not in 
(select launched from ships)

--task17 (lesson3)
--Корабли: Найдите сражения, в которых участвовали корабли класса Kongo из таблицы Ships.

select battle from ships s
join outcomes o
on s.name = o.ship
where class = 'Kongo'

--task1  (lesson4)
-- Компьютерная фирма: Сделать view (название all_products_flag_300) для всех товаров (pc, printer, laptop)
-- с флагом, если стоимость больше > 300. Во view три колонки: model, price, flag

create or replace view all_products_flag_300 as
with t as
(
	select model, price from pc
	union all
	select model, price from printer
	union all
	select model, price from laptop
)
select *, 
case 
	when price > 300
	then 1
	else 0
end flag
from t

select * from all_products_flag_300

--task2  (lesson4)
-- Компьютерная фирма: Сделать view (название all_products_flag_avg_price) для всех товаров (pc, printer, laptop) 
-- с флагом, если стоимость больше cредней . Во view три колонки: model, price, flag

create or replace view all_products_flag_avg_price as
with t as
(
	select model, price from pc
	union all
	select model, price from printer
	union all
	select model, price from laptop
)
select *, 
case 
	when price > (select avg(price) from t)
	then 1
	else 0
end flag
from t

--task3  (lesson4)
-- Компьютерная фирма: Вывести все принтеры производителя = 'A' со стоимостью выше средней по принтерам производителя = 'D' и 'C'.
-- Вывести model

with t as
(
	select p.model, maker, price 
	from printer pr
	join product p on
	pr.model = p.model
)
select model from t
where maker = 'A' and 
price > (select avg(price) from t 
		where maker = 'D' or maker = 'C')
		
--task4 (lesson4)
-- Компьютерная фирма: Вывести все товары производителя = 'A' со стоимостью выше средней по принтерам производителя = 'D' и 'C'. 
-- Вывести model

with t1 as 
(
	select model, price from pc
	union all
	select model, price from printer
	union all
	select model, price from laptop
)
select t1.model from t1
join product p on
t1.model = p.model
where maker = 'A' and
price > (select avg(price) from 
			(
			select p.model, maker, price 
			from printer pr
			join product p on
			pr.model = p.model
			) t2 
		where maker = 'D' or maker = 'C')

		
--task5 (lesson4)
-- Компьютерная фирма: Какая средняя цена среди уникальных продуктов производителя = 'A' (printer & laptop & pc)

select p.model, p.type, avg(price) from pc 
join product p on
p.model = pc.model
where maker = 'A'
group by p.model, p.type
	union all
select p.model, p.type, avg(price) from printer pr 
join product p on
p.model = pr.model
where maker = 'A'
group by p.model, p.type
	union all
select p.model, p.type, avg(price) from laptop l
join product p on
p.model = l.model
where maker = 'A'
group by p.model, p.type

--task6 (lesson4)
-- Компьютерная фирма: Сделать view с количеством товаров (название count_products_by_makers) по каждому производителю.
-- Во view: maker, count

create or replace view count_products_by_makers as
with t as
(
	select maker from pc 
	join product p on
	p.model = pc.model
		union all
	select maker from printer pr 
	join product p on
	p.model = pr.model
		union all
	select maker from laptop l
	join product p on
	p.model = l.model
)
select maker, count(*)
from t group by maker

--task7 (lesson4)
-- По предыдущему view (count_products_by_makers) сделать график в colab (X: maker, y: count)

-- См. jupyter notebook

--task8 (lesson4)
-- Компьютерная фирма: Сделать копию таблицы printer (название printer_updated) и удалить из нее все принтеры производителя 'D'

create table printer_updated as
	select code, pr.model, color, 
	pr.type, price from printer pr
	join product p on
	p.model = pr.model
	where maker != 'D'

--task9 (lesson4)
-- Компьютерная фирма: Сделать на базе таблицы (printer_updated) view с дополнительной колонкой производителя 
-- (название printer_updated_with_makers)

create view printer_updated_with_makers as
	select code, pr.model, color, 
	pr.type, price, maker from 
	printer_updated pr
	join product p on
	pr.model = p.model
	

