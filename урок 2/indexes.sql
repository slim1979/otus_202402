-- поиск магазина в регионе
create index idx_regions_shops on shops(region_guid)
select * from shops where region_guid = ...

-- все заказы магазина
create index idx_shops_orders on orders(shop_guid, created_at::date)
select * from orders where shop_guid = ...
select * from orders
where shop_guid = ...
and created_at::date between ...

-- выбранный юзером магазин
create index idx_user_shop on users(shop_guid)

-- все заказы юзера
create index idx_users_orders on orders(user_guid)

-- элементы корзины/заказа, дата для сортировки
create index idx_order_items_orders order_items(order_guid, created_at::date) order by created_at desc

-- привязка элеиента корзины к товару
create index idx_order_items_products order_items(product_guid)

--ограничения на количество и сумму элемента корзины
alter table order_items add constraint order_items_count (count > 0)
alter table order_items add constraint order_items_sum (sum > 0)


-- структура категорий
create index idx_categories_ancestry on categories(ancestry)

-- привязка товара к категории
create index idx_products_categories on products(category_guid)

-- связь товара с остатками в разрезе магазина и активного набора остатков
create index idx_shop_product_stocks on stocks(product_guid, shop_guid, data_set)
alter table stocks add constraint check(stocks > 0)
select p.*, s.value stock
from products p
join stocks s on p.guid = s.product_guid
join stocks_datasets sd on s.data_set = sd.data_set
where sd.active
and category_guid = ...

-- связь товара с ценами в разрезе магазина и активного набора цен
create index idx_shop_product_prices on prices(product_guid, shop_guid, data_set)
alter table prices add constraint check(base_price > 0)

-- наборы остатков и цен
create index idx_stocks_datasets on stocks_data_sets(data_set)
create index idx_prices_datasets on prices_data_sets(data_set)

