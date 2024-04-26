-- все заказы юзера
create index idx_users_orders on orders(user_guid)

explain
select *
from trade.orders
where user_guid = '515f0cda-5ce8-4461-8d99-97da5143b328'

QUERY PLAN | ------------------------------------------------------------------------------+
Index Scan using idx_users_orders on orders (cost = 0.13..8.15 rows = 1 width = 90) | Index Cond: (
  user_guid = '515f0cda-5ce8-4461-8d99-97da5143b328'::uuid
) |

---

-- элементы корзины/заказа, дата для сортировки
create index idx_order_items_orders on trade.order_items(order_guid, cast(created_at as date) desc)

explain
select *
from trade.order_items
where order_guid = '2bff094c-0a0a-4d84-877e-99a9c22d70f8'

QUERY PLAN | -----------------------------------------------------------------------------------------+
Index Scan using idx_order_items_orders on order_items (cost = 0.12..8.14 rows = 1 width = 70) | Index Cond: (
  order_guid = '2bff094c-0a0a-4d84-877e-99a9c22d70f8'::uuid
) |

---

--  для поиска среди активных юзеров по почте
create index idx_active_users on users(lower(email), deleted_at) where deleted_at > '1970-01-01'::date

explain
select *
from personal.users
where lower(email) = 'some@email.ru'
  and deleted_at > '1970-01-01'::date

QUERY PLAN | ------------------------------------------------------------------------------+
Index Scan using idx_active_users on users (cost = 0.12..8.14 rows = 1 width = 172) | Index Cond: (lower(email) = 'some@email.ru'::text) |


--
explain
select
	*
from
	vitrine.products p
where
	name_lexems @@ to_tsquery('shit');QUERY PLAN                                                                  |
----------------------------------------------------------------------------+
Bitmap Heap Scan on products p  (cost=8.77..13.03 rows=1 width=148)         |
  Recheck Cond: (name_lexems @@ to_tsquery('shit'::text))                   |
  ->  Bitmap Index Scan on idx_name_lexems  (cost=0.00..8.77 rows=1 width=0)|
        Index Cond: (name_lexems @@ to_tsquery('shit'::text))               |

  QUERY PLAN                                                                  |
----------------------------------------------------------------------------+
Bitmap Heap Scan on products p  (cost=8.77..13.03 rows=1 width=148)         |
  Recheck Cond: (name_lexems @@ to_tsquery('shit'::text))                   |
  ->  Bitmap Index Scan on idx_name_lexems  (cost=0.00..8.77 rows=1 width=0)|
        Index Cond: (name_lexems @@ to_tsquery('shit'::text))               |
