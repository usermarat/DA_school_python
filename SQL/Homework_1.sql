-- ������� 1: ������� name, class �� ��������, ���������� ����� 1920

select name, class from ships
where launched > 1920

-- ������� 2: ������� name, class �� ��������, ���������� ����� 1920, �� �� ������� 1942

select name, class from ships
where launched > 1920 and 
launched <= 1942

-- ������� 3: ����� ���������� �������� � ������ ������. ������� ���������� � class

select class, count(*) from ships
group by class

-- ������� 4: ��� ������� ��������, ������ ������ ������� �� ����� 16, ������� ����� � ������. (������� classes)

select class, country from classes
where bore >= 16

-- ������� 5: ������� �������, ����������� � ��������� � �������� ��������� (������� Outcomes, North Atlantic). �����: ship.

select ship from outcomes
where battle = 'North Atlantic' and
result = 'sunk'

-- ������� 6: ������� �������� (ship) ���������� ������������ �������

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
	
-- ������� 7: ������� �������� ������� (ship) � ����� (class) ���������� ������������ �������
	
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
		
-- ������� 8: ������� ��� ����������� �������, � ������� ������ ������ �� ����� 16, � ������� ���������. �����: ship, class
		
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

-- ������� 9: ������� ��� ������ ��������, ���������� ��� (������� classes, country = 'USA'). �����: class

select class from classes
where country = 'USA'

-- ������� 10: ������� ��� �������, ���������� ��� (������� classes & ships, country = 'USA'). �����: name, class

select name, c.class from ships s 
join classes c on
s.class = c.class
where country = 'USA'