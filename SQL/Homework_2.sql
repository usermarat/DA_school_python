--task16
--�������: ������� ��������, ������� ��������� � ����, �� ����������� �� � ����� �� ����� ������ �������� �� ����. (����� with)

with y as 
(select * from ships)
select name from battles
where EXTRACT(YEAR from date) not in 
(select launched from y)

--task17
--�������: ������� ��������, � ������� ����������� ������� ������ Kongo �� ������� Ships.

select battle from ships s
join outcomes o
on s.name = o.ship
where class = 'Kongo'

--task1
--�������: ��� ������� ������ ���������� ����� �������� ����� ������, ����������� � ���������. �������: ����� � ����� ����������� ��������.

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
--�������: ��� ������� ������ ���������� ���, ����� ��� ������ �� ���� ������ ������� ����� ������. 
--���� ��� ������ �� ���� ��������� ������� ����������, ���������� ����������� ��� ������ �� ���� �������� ����� ������. �������: �����, ���.

-- ������� ��� ������ �������:
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

-- ������� � ������� �������, �� �������� ����������� ���� ������ (null)
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
--�������: ��� �������, ������� ������ � ���� ����������� �������� � �� ����� 3 �������� � ���� ������, ������� ��� ������ � ����� ����������� ��������.

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
--�������: ������� �������� ��������, ������� ���������� ����� ������ ����� ���� �������� ������ �� ������������� (������ ������� �� ������� Outcomes).

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
--������������ �����: ������� �������������� ���������, ������� ���������� �� � ���������� ������� RAM
--� � ����� ������� ����������� ����� ���� ��, ������� ���������� ����� RAM. �������: Maker

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

