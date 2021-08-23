--task10 (lesson4)
-- ������������ �����: �� ���� products_price_categories_with_makers �� ������� �� ������� ������������� ������ (X: category_price, Y: count)

-- ��. jupyter notebook


--task11 (lesson4)
-- ������������ �����: �� ���� products_price_categories_with_makers �� ������� �� A & D ������ (X: category_price, Y: count)

-- ��. jupyter notebook

--task12 (lesson4)
-- �������: ������� ����� ������� ships, �� � �������� ������� �� ������ ���������� � ����� N (ships_without_n)

create table ships_without_n as
	select * from ships
	where name 
	not like 'N%'
	
--task13 (lesson3)
--������������ �����: ������� ������ ���� ��������� � ������������� � ��������� ���� �������� (pc, printer, laptop). 
--�������: model, maker, type
	
select * from product

--task14 (lesson3)
--������������ �����: ��� ������ ���� �������� �� ������� printer ������������� ������� ��� ���, 
--� ���� ���� ����� ������� PC - "1", � ��������� - "0"

select *,
case 
	when price > (select avg(price) from pc)
	then 1
	else 0
end flag
from printer 

--task15 (lesson3)
--�������: ������� ������ ��������, � ������� class ����������� (IS NULL)

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
--�������: ������� ��������, ������� ��������� � ����, �� ����������� �� � ����� �� ����� ������ �������� �� ����.

select name from battles
where EXTRACT(YEAR from date) not in 
(select launched from ships)

--task17 (lesson3)
--�������: ������� ��������, � ������� ����������� ������� ������ Kongo �� ������� Ships.

select battle from ships s
join outcomes o
on s.name = o.ship
where class = 'Kongo'

--task1  (lesson4)
-- ������������ �����: ������� view (�������� all_products_flag_300) ��� ���� ������� (pc, printer, laptop)
-- � ������, ���� ��������� ������ > 300. �� view ��� �������: model, price, flag

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
-- ������������ �����: ������� view (�������� all_products_flag_avg_price) ��� ���� ������� (pc, printer, laptop) 
-- � ������, ���� ��������� ������ c������ . �� view ��� �������: model, price, flag

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
-- ������������ �����: ������� ��� �������� ������������� = 'A' �� ���������� ���� ������� �� ��������� ������������� = 'D' � 'C'.
-- ������� model

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
-- ������������ �����: ������� ��� ������ ������������� = 'A' �� ���������� ���� ������� �� ��������� ������������� = 'D' � 'C'. 
-- ������� model

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
-- ������������ �����: ����� ������� ���� ����� ���������� ��������� ������������� = 'A' (printer & laptop & pc)

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
-- ������������ �����: ������� view � ����������� ������� (�������� count_products_by_makers) �� ������� �������������.
-- �� view: maker, count

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
-- �� ����������� view (count_products_by_makers) ������� ������ � colab (X: maker, y: count)

-- ��. jupyter notebook

--task8 (lesson4)
-- ������������ �����: ������� ����� ������� printer (�������� printer_updated) � ������� �� ��� ��� �������� ������������� 'D'

create table printer_updated as
	select code, pr.model, color, 
	pr.type, price from printer pr
	join product p on
	p.model = pr.model
	where maker != 'D'

--task9 (lesson4)
-- ������������ �����: ������� �� ���� ������� (printer_updated) view � �������������� �������� ������������� 
-- (�������� printer_updated_with_makers)

create view printer_updated_with_makers as
	select code, pr.model, color, 
	pr.type, price, maker from 
	printer_updated pr
	join product p on
	pr.model = p.model
	

