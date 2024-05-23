3) написать запрос суммы очков с группировкой и сортировкой по годам

select sum(points),
  year_game
from statistic s
group by year_game
order by year_game

sum | year_game |
 ------+---------+
92.00 | 2018 |
98.00 | 2019 |
110.00 | 2020 |

4) написать cte показывающее тоже самое

with years as(
  select distinct year_game
  from statistic s
),
points as (
  select year_game,
    sum(points)
  from statistic s
  group by year_game
)
select *
from years y
  join points p using(year_game)
order by y.year_game

year_game | sum |
 ---------+------+
2018 | 92.00 |
2019 | 98.00 |
2020 | 110.00 |

5) используя функцию LAG вывести кол - во очков по всем игрокам за текущий код и за предыдущий.

with years as(
  select distinct year_game
  from statistic s
),
points as (
  select year_game,
    sum(points)
  from statistic s
  group by year_game
)
select y.year_game,
  sum,
  lag(sum) over(
    order by y.year_game
  )
from years y
  join points p using(year_game)
order by y.year_game

year_game | sum | lag |
 ---------+------+-----+
2018 | 92.00 | |
2019 | 98.00 | 92.00 |
2020 | 110.00 | 98.00 |
