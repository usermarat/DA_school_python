--task5  (lesson6)
-- Компьютерная фирма: Создать таблицу all_products_with_index_task5 как объединение всех данных по ключу code (union all)
-- и сделать флаг (flag) по цене > максимальной по принтеру. Также добавить нумерацию (через оконные функции) 
-- по каждой категории продукта в порядке возрастания цены (price_index). По этому price_index сделать индекс

create table all_products_with_index_task5 as
select *,
row_number () over (partition by type order by price)
price_index
from all_products_with_index_task4

CREATE INDEX price_idx ON all_products_with_index_task5 (price_index)

--task1  (lesson6, дополнительно)
-- SQL: Создайте таблицу с синтетическими данными (10000 строк, 3 колонки, все типы int) и заполните ее случайными данными от 0 до 1 000 000. 
-- Проведите EXPLAIN операции и сравните базовые операции.

drop table synth

create table synth
(
	column1 int,
	column2 int,
	column3 int
)

explain analyze
with t as
(
select cast(random() * 1000000 as int) column1, 
cast(random() * 1000000 as int) column2,
cast(random() * 1000000 as int) column3
from generate_series (1,10000)
)
Insert Into synth 
select * from t

|QUERY PLAN                                                                                                                   |
|-----------------------------------------------------------------------------------------------------------------------------|
|Insert on synth  (cost=32.50..52.50 rows=1000 width=12) (actual time=10.262..10.263 rows=0 loops=1)                          |
|  CTE t                                                                                                                      |
|    ->  Function Scan on generate_series  (cost=0.00..32.50 rows=1000 width=12) (actual time=0.891..2.456 rows=10000 loops=1)|
|  ->  CTE Scan on t  (cost=0.00..20.00 rows=1000 width=12) (actual time=0.892..4.726 rows=10000 loops=1)                     |
|Planning time: 0.061 ms                                                                                                      |
|Execution time: 10.442 ms                                                                                                    |

explain analyze
select count(*) from synth

|QUERY PLAN                                                                                                   |
|-------------------------------------------------------------------------------------------------------------|
|Aggregate  (cost=180.00..180.01 rows=1 width=8) (actual time=1.465..1.466 rows=1 loops=1)                    |
|  ->  Seq Scan on synth  (cost=0.00..155.00 rows=10000 width=0) (actual time=0.009..0.800 rows=10000 loops=1)|
|Planning time: 0.062 ms                                                                                      |
|Execution time: 1.491 ms                                                                                     |

explain analyze
select * from synth

|QUERY PLAN                                                                                              |
|--------------------------------------------------------------------------------------------------------|
|Seq Scan on synth  (cost=0.00..155.00 rows=10000 width=12) (actual time=0.017..1.117 rows=10000 loops=1)|
|Planning time: 0.048 ms                                                                                 |
|Execution time: 1.687 ms                                                                                |


explain analyze
select sum(column1), sum(column2),
sum(column3) from synth

|QUERY PLAN                                                                                                    |
|--------------------------------------------------------------------------------------------------------------|
|Aggregate  (cost=230.00..230.01 rows=1 width=24) (actual time=2.249..2.250 rows=1 loops=1)                    |
|  ->  Seq Scan on synth  (cost=0.00..155.00 rows=10000 width=12) (actual time=0.021..0.869 rows=10000 loops=1)|
|Planning time: 0.073 ms                                                                                       |
|Execution time: 2.299 ms                                                                                      |


explain analyze
select min(column1), max(column2),
avg(column3) from synth

|QUERY PLAN                                                                                                    |
|--------------------------------------------------------------------------------------------------------------|
|Aggregate  (cost=230.00..230.01 rows=1 width=40) (actual time=2.093..2.094 rows=1 loops=1)                    |
|  ->  Seq Scan on synth  (cost=0.00..155.00 rows=10000 width=12) (actual time=0.011..0.807 rows=10000 loops=1)|
|Planning time: 0.046 ms                                                                                       |
|Execution time: 2.130 ms                                                                                      |

explain analyze
select * from synth
where column1 = column2

|QUERY PLAN                                                                                       |
|-------------------------------------------------------------------------------------------------|
|Seq Scan on synth  (cost=0.00..180.00 rows=50 width=12) (actual time=0.784..0.785 rows=0 loops=1)|
|  Filter: (column1 = column2)                                                                    |
|  Rows Removed by Filter: 10000                                                                  |
|Planning time: 0.067 ms                                                                          |
|Execution time: 0.800 ms                                                                         |

explain analyze
select * from synth
where column1 = (select max(column1) from synth)

|QUERY PLAN                                                                                                                   |
|-----------------------------------------------------------------------------------------------------------------------------|
|Seq Scan on synth  (cost=180.01..360.01 rows=1 width=12) (actual time=2.509..2.582 rows=1 loops=1)                           |
|  Filter: (column1 = $0)                                                                                                     |
|  Rows Removed by Filter: 9999                                                                                               |
|  InitPlan 1 (returns $0)                                                                                                    |
|    ->  Aggregate  (cost=180.00..180.01 rows=1 width=4) (actual time=2.004..2.004 rows=1 loops=1)                            |
|          ->  Seq Scan on synth synth_1  (cost=0.00..155.00 rows=10000 width=4) (actual time=0.009..1.078 rows=10000 loops=1)|
|Planning time: 0.159 ms                                                                                                      |
|Execution time: 2.625 ms                                                                                                     |


explain analyze
select column1, avg(column3)
from synth group by column1

|QUERY PLAN                                                                                                   |
|-------------------------------------------------------------------------------------------------------------|
|HashAggregate  (cost=205.00..329.52 rows=9962 width=36) (actual time=4.315..7.773 rows=9962 loops=1)         |
|  Group Key: column1                                                                                         |
|  ->  Seq Scan on synth  (cost=0.00..155.00 rows=10000 width=8) (actual time=0.019..0.882 rows=10000 loops=1)|
|Planning time: 0.083 ms                                                                                      |
|Execution time: 8.562 ms                                                                                     |


explain analyze
select * from synth
order by column1, column2,
column3

|QUERY PLAN                                                                                                    |
|--------------------------------------------------------------------------------------------------------------|
|Sort  (cost=819.39..844.39 rows=10000 width=12) (actual time=3.880..4.589 rows=10000 loops=1)                 |
|  Sort Key: column1, column2, column3                                                                         |
|  Sort Method: quicksort  Memory: 853kB                                                                       |
|  ->  Seq Scan on synth  (cost=0.00..155.00 rows=10000 width=12) (actual time=0.019..0.876 rows=10000 loops=1)|
|Planning time: 0.074 ms                                                                                       |
|Execution time: 5.037 ms                                                                                      |

explain analyze
select * from synth a
join synth b on
a.column1 = b.column2

|QUERY PLAN                                                                                                            |
|----------------------------------------------------------------------------------------------------------------------|
|Hash Join  (cost=280.00..585.38 rows=10038 width=24) (actual time=2.035..4.056 rows=106 loops=1)                      |
|  Hash Cond: (a.column1 = b.column2)                                                                                  |
|  ->  Seq Scan on synth a  (cost=0.00..155.00 rows=10000 width=12) (actual time=0.014..0.827 rows=10000 loops=1)      |
|  ->  Hash  (cost=155.00..155.00 rows=10000 width=12) (actual time=1.990..1.991 rows=10000 loops=1)                   |
|        Buckets: 16384  Batches: 1  Memory Usage: 558kB                                                               |
|        ->  Seq Scan on synth b  (cost=0.00..155.00 rows=10000 width=12) (actual time=0.004..0.893 rows=10000 loops=1)|
|Planning time: 0.137 ms                                                                                               |
|Execution time: 4.084 ms                                                                                              |


explain analyze
select * from synth a
full join synth b on
a.column1 = b.column2

|QUERY PLAN                                                                                                            |
|----------------------------------------------------------------------------------------------------------------------|
|Hash Full Join  (cost=280.00..585.38 rows=10038 width=24) (actual time=2.011..5.475 rows=19895 loops=1)               |
|  Hash Cond: (a.column1 = b.column2)                                                                                  |
|  ->  Seq Scan on synth a  (cost=0.00..155.00 rows=10000 width=12) (actual time=0.006..0.695 rows=10000 loops=1)      |
|  ->  Hash  (cost=155.00..155.00 rows=10000 width=12) (actual time=1.977..1.977 rows=10000 loops=1)                   |
|        Buckets: 16384  Batches: 1  Memory Usage: 558kB                                                               |
|        ->  Seq Scan on synth b  (cost=0.00..155.00 rows=10000 width=12) (actual time=0.011..0.919 rows=10000 loops=1)|
|Planning time: 0.167 ms                                                                                               |
|Execution time: 6.141 ms                                                                                              |


explain analyze
select * from synth
union all
select * from synth

|QUERY PLAN                                                                                                            |
|----------------------------------------------------------------------------------------------------------------------|
|Append  (cost=0.00..310.00 rows=20000 width=12) (actual time=0.018..3.119 rows=20000 loops=1)                         |
|  ->  Seq Scan on synth  (cost=0.00..155.00 rows=10000 width=12) (actual time=0.018..0.897 rows=10000 loops=1)        |
|  ->  Seq Scan on synth synth_1  (cost=0.00..155.00 rows=10000 width=12) (actual time=0.007..0.741 rows=10000 loops=1)|
|Planning time: 0.160 ms                                                                                               |
|Execution time: 3.946 ms                                                                                              |


explain analyze
select *, row_number ()
over (order by column1)
from synth

|QUERY PLAN                                                                                                          |
|--------------------------------------------------------------------------------------------------------------------|
|WindowAgg  (cost=819.39..994.39 rows=10000 width=20) (actual time=3.168..6.440 rows=10000 loops=1)                  |
|  ->  Sort  (cost=819.39..844.39 rows=10000 width=12) (actual time=3.162..3.959 rows=10000 loops=1)                 |
|        Sort Key: column1                                                                                           |
|        Sort Method: quicksort  Memory: 853kB                                                                       |
|        ->  Seq Scan on synth  (cost=0.00..155.00 rows=10000 width=12) (actual time=0.019..0.933 rows=10000 loops=1)|
|Planning time: 0.080 ms                                                                                             |
|Execution time: 6.860 ms                                                                                            |


explain analyze
select *, rank ()
over (partition by column1)
from synth

|QUERY PLAN                                                                                                          |
|--------------------------------------------------------------------------------------------------------------------|
|WindowAgg  (cost=819.39..994.39 rows=10000 width=20) (actual time=3.312..8.979 rows=10000 loops=1)                  |
|  ->  Sort  (cost=819.39..844.39 rows=10000 width=12) (actual time=3.305..4.038 rows=10000 loops=1)                 |
|        Sort Key: column1                                                                                           |
|        Sort Method: quicksort  Memory: 853kB                                                                       |
|        ->  Seq Scan on synth  (cost=0.00..155.00 rows=10000 width=12) (actual time=0.019..1.098 rows=10000 loops=1)|
|Planning time: 0.076 ms                                                                                             |
|Execution time: 9.439 ms                                                                                            |


--task2 (lesson6, дополнительно)
-- GCP (Google Cloud Platform): Через GCP загрузите данные csv в базу PSQL по личным реквизитам (используя только bash и интерфейс bash) 

Текст команд в консоли:

usermarat1@cloudshell:~ (my-project1-324117)$ echo "create table avocado (id int, date timestamp, average_price float, total_vol float, col_4046 float, col_4225 float, col_4770 float, total_bags float, small_bags float, large_bags float, xlarge_bags float, type varchar (20), year int, region varchar (20))" >> t_create.sql
usermarat1@cloudshell:~ (my-project1-324117)$ psql -h 52.157.159.24 -Ustudent3 sql_ex_for_student3 < t_create.sql
Password for user student3:
CREATE TABLE
sql_ex_for_student3=> \copy avocado from '/home/usermarat1/avocado_(1).csv' delimiter ',';
COPY 18249

select * from avocado

