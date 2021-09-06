--task1  (lesson8)
-- oracle: https://leetcode.com/problems/department-top-three-salaries/

select d.Name as "Department", t.Name as "Employee", Salary from
(
    select Name, Salary, DepartmentId,  dense_rank () 
    over (partition by DepartmentId order by Salary desc) "N"
    from Employee 
) t 
join Department d on
t.DepartmentId = d.Id
where N <= 3


--task2  (lesson8)
-- https://sql-academy.org/ru/trainer/tasks/17

select member_name, status, sum(cost) as costs
FROM 
(
    select member_name, status, 
    amount * unit_price as cost
    from Payments p join FamilyMembers f
    on p.family_member = f.member_id
    where YEAR(date) = 2005
) t
group by member_name

--task3  (lesson8)
-- https://sql-academy.org/ru/trainer/tasks/13

select distinct name from
(
    select *, row_number () 
    over (partition by name) rn
    from Passenger
) t
where rn >= 2

ИЛИ ТАК

select name from
(
    select name, count(*) rn
    from Passenger
    group by name
) t
where rn >= 2

--task4  (lesson8)
-- https://sql-academy.org/ru/trainer/tasks/38

select count(first_name) as count
from Student 
where first_name = 'Anna'
group by first_name

--task5  (lesson8)
-- https://sql-academy.org/ru/trainer/tasks/35

select count(*) as count from
(
    select distinct classroom from Schedule
    where date = '2019-09-02'
) t

--task6  (lesson8)
-- https://sql-academy.org/ru/trainer/tasks/38

select count(first_name) as count
from Student 
where first_name = 'Anna'
group by first_name

--task7  (lesson8)
-- https://sql-academy.org/ru/trainer/tasks/32

select floor(avg(age)) as age from
(
    select datediff(now(), birthday) / 365 as age
    from FamilyMembers
) t

--task8  (lesson8)
-- https://sql-academy.org/ru/trainer/tasks/27

with t1 as
(
    select good_type_name, good_id from GoodTypes gt
    join Goods g on gt.good_type_id = g.type
)
select good_type_name, sum(costs) as costs from
(
    select YEAR(date) y, good, sum(amount * unit_price) as costs
    from Payments group by y, good having y = 2005 
) t2
join t1 on t1.good_id = t2.good
group by good_type_name

--task9  (lesson8)
-- https://sql-academy.org/ru/trainer/tasks/37

select floor(min(datediff(now(), birthday) / 365))
as year from Student

--task10  (lesson8)
-- https://sql-academy.org/ru/trainer/tasks/44

with t as
(
    select student, class from Class c join Student_in_class sc
    on c.id = sc.class where name like '10%'
)
select floor(max(datediff(now(), birthday) / 365))
as max_year from Student s join t
on s.id = t.student

--task11 (lesson8)
-- https://sql-academy.org/ru/trainer/tasks/20

select status, member_name, costs from 
(
    select good_type_name, status, member_name, sum(costs) as "costs"from
    (
        select status, member_name, good,
        amount * unit_price as "costs"from FamilyMembers f
        join Payments p on f.member_id = p.family_member
    ) t1
    join 
    (
        select good_id, good_type_name from Goods g
        join GoodTypes gt on g.type = gt.good_type_id
    ) t2
    on t1.good = t2.good_id
    group by good_type_name, member_name
) a
where good_type_name = 'entertainment'

--task12  (lesson8)
-- https://sql-academy.org/ru/trainer/tasks/55

with t as
(
    select company, count(*) c from Trip
    group by company
)
delete from company where id in
(
    select company from t where c in
    (select min(c) from t)
)

--task13  (lesson8)
-- https://sql-academy.org/ru/trainer/tasks/45

with t as
(
    select classroom, count(*) c
    from Schedule GROUP BY classroom
)
select classroom from t
where c in (select max(c) from t)

--task14  (lesson8)
-- https://sql-academy.org/ru/trainer/tasks/43

select last_name from
(
    select last_name, subject from Schedule s
    join Teacher t on s.teacher = t.id
) t1
join Subject t2 on t1.subject = t2.id
where t2.name = 'Physical Culture'
order by last_name 

--task15  (lesson8)
-- https://sql-academy.org/ru/trainer/tasks/63

select concat(last_name, '.', LEFT(first_name, 1),
              '.', LEFT(middle_name, 1), '.') name
from Student order by name
