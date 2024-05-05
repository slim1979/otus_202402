1. Напишите запрос по своей базе с регулярным выражением, добавьте пояснение,
что вы хотите найти.

--  ищем все товары, которые НЕ содержат в наименовании "нас"
--  не особо осмысленно, но лень было придумывать другие)

select id,
  name
from vitrine.products

-- 1 Налёт астрономии.
-- 2 Например более сильное таким никак.
-- 3 Как пылевая многочисленная содержащей тема тех источником твёрдой.
-- 4 Сильное остатками нас оптическое будет никак невелика действующие галактик.

select *
from vitrine.products
where name !~ 'нас'
-- 1 Налёт астрономии.
-- 2 Например более сильное таким никак.
-- 3 Как пылевая многочисленная содержащей тема тех источником твёрдой.

---

-- и наоборот...
--  ищем все товары, которые содержат в наименовании "нас"

select id,
  name
from vitrine.products
where name ~ 'нас'
-- 4 Сильное остатками нас оптическое будет никак невелика действующие галактик.

------------------------------
2. Напишите запрос по своей базе с использованием
LEFT JOIN и INNER JOIN

--  ищем всех пользователей с заказами и без
select u.id,
  name,
  o.id order_id
from personal.users u
  left join trade.orders o on o.user_guid = u.guid

-- id | name       | order_id |
--  --+-----------+--+
-- 1 | user 1 name        | 1 |
-- 2 | user 2 name | |

-- выбираем только тех пользователей, кто делал заказ
select u.id,
  name,
  o.id order_id
from personal.users u
  join trade.orders o on o.user_guid = u.guid

-- id | name | order_id |
--  --+----+--+
-- 1 | user 1 name | 1 |

------------------------------------------
вопрос
- как порядок соединений в FROM влияет на результат ? Почему ?

ответ
- в случае с inner join разницы не будет никакой, так как нас интересует пересечение
в случае с left join разница будет, так как левая таблица будет выведена полностью,
правая по совпадению, что не совпало будет выведено как NULL
альтернатива изменению порядка - right join

-----------------------------------------
3. Напишите запрос на добавление данных с выводом информации о добавленных строках.

with user_attrs as (
  select gen_random_uuid() guid,
    (
      select guid
      from location.shops
      limit 1
    ) shop_guid, (
      select guid
      from location.regions
      limit 1
    ) region_guid, 'some@email.com' email, 'name' name, '' avatar_url
)
insert into personal.users(
    guid,
    shop_guid,
    region_guid,
    email,
    name,
    avatar_url
  )
select *
from user_attrs
returning id,
  guid,
  email

-- id | guid | email |
--  --+------------------------------------+--------------+
-- 3 | c2c2df03-f482-44b0-9b24-cc89221bc243 | some @email.com |


-----------------------------------------
4. Напишите запрос с обновлением данные используя
UPDATE FROM

для написания такого запроса пришлось создать дополнительную таблицу trade.revenue.
она будет хранить данные по пользователям, их заказам и суммам заказов. иначе - выручка.


create table if not exists trade.revenue (
  id serial,
  user_guid uuid,
  order_guid uuid,
  sum decimal(16, 2) not null default 0.0
)

insert into trade.revenue(user_guid, order_guid, sum)
values(gen_random_uuid(), gen_random_uuid(), 0),
      (gen_random_uuid(), gen_random_uuid(), 0)

update trade.revenue
set user_guid = uwo.user_guid,
  order_guid = uwo.order_guid,
  sum = uwo.sum
from (
    select u.id user_id,
      u.guid user_guid,
      o.guid order_guid,
      sum
    from personal.users u
      join trade.orders o on u.guid = o.user_guid
  ) uwo
where uwo.user_id = id -- <-- натянуто, понятно, но се ля ви)
returning uwo.user_guid,
  uwo.order_guid,
  uwo.sum

-- user_guid | order_guid | sum |
-- ------------------------------------+------------------------------------+------+
-- fd1bbe3e-5198-47d8-8c8a-266865174096 | 38aa6998-0953-4e89-942f-857ca5a675ec | 110.00 |
-- 6dd35d17-af53-4914-a768-362e9e6b275b | e1b44baa-8bc4-490a-87ed-72e1efab7d72 | 120.00 |


-----------------------------------------
5. Напишите запрос для удаления данных с оператором DELETE используя
join с другой таблицей с помощью using.


delete from trade.revenue r using personal.users u
where r.user_guid = u.guid
  and u.id = 2
returning r.id,
  user_guid

-- id | user_guid |
-- --+------------------------------------+
-- 2 | 6dd35d17-af53-4914-a768-362e9e6b275b |

select *
from trade.revenue

-- id | user_guid | order_guid | sum |
 --+------------------------------------+------------------------------------+------+
--  1 | fd1bbe3e-5198-47d8-8c8a-266865174096 | 38aa6998-0953-4e89-942f-857ca5a675ec | 110.00 |


-----------------------------------------
Задание со *: Приведите пример использования утилиты COPY

создаём csv файл где-то для дальшейшей загрузки в нашу БД

\ copy (
  select *
  from trade.revenue
) to '/app/files/revenuess.csv' csv header;

после загружаем в нашу БД
\ copy trade.revenue
from '/app/files/revenue.csv' csv header;

утилита используется для загрузки одной пачкой больших объёмов данных.
время работа значительно отличается от обычного добавления.
так же, поддерживается копирование налету - одна база через \copy выгружает в stdout,
другая база налету вставляет через \copy from stdin




