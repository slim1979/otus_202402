create database otus_test

select * from pg_database

set search_path to otus_test

create role admin

alter default privileges grant all on tables to admin

create user vasya with role admin password '1234'

create role manager

alter default privileges grant select on tables to admin

create user oleg with role manager password '4567'

create role dev

select * from pg_catalog.pg_roles


create schema if not exists location

create schema if not exists trade

create schema if not exists vitrine

create schema if not exists tech

create schema if not exists personal


create table location.regions (
  id serial primary key not null,
  guid uuid not null unique,
  created_at timestamp default now(),
  updated_at timestamp default now()
)

select * from location.regions

insert into location.regions(guid) values(gen_random_uuid())


create table location.shops (
  id serial primary key not null,
  guid uuid not null unique,
  region_guid uuid references location.regions(guid) on delete set null,
  longitude decimal(16, 14) not null,
  latitude decimal(16, 14) not null,
  created_at timestamp default now(),
  updated_at timestamp default now()
)

with shops_attrs as (
select gen_random_uuid() guid,
	r.guid region_guid,
	round((random() * 25 + 30)::decimal, 14) longitude,
	round((random() * 25 + 30)::decimal, 14) latitude
from location.regions r limit 1
)
insert into location.shops(guid,
						   region_guid,
						   longitude,
					       latitude)
select * from shops_attrs

select * from location.shops

create table vitrine.categories (
	id serial primary key not null,
	guid uuid not null unique,
	ancestry text not null default '',
	image_url text not null default '',
	created_at timestamp default now(),
    updated_at timestamp default now()
)

insert into vitrine.categories(guid, ancestry, image_url)
values(gen_random_uuid(), '', '')

select * from vitrine.categories

create table vitrine.products (
	id serial primary key not null,
	guid uuid not null unique,
	category_guid uuid references vitrine.categories(guid) on delete cascade,
	name text not null default '',
	image_url text not null default '',
	created_at timestamp default now(),
    updated_at timestamp default now()
)

with products_attrs as (
select gen_random_uuid() guid,
	c.guid category_guid,
	'some_product' name,
	'' image_url
from vitrine.categories c limit 1
)
insert into vitrine.products(guid,
						     category_guid,
						     name,
					         image_url)
select * from products_attrs

select * from vitrine.products

create table tech.prices_datasets (
	data_set uuid not null unique,
	active boolean not null default false,
	created_at timestamp default now(),
    updated_at timestamp default now()
)

insert into tech.prices_datasets(data_set, active)
values(gen_random_uuid(), true)

create table tech.stocks_datasets (
	data_set uuid not null unique,
	active boolean not null default false,
	created_at timestamp default now(),
    updated_at timestamp default now()
)

insert into tech.stocks_datasets(data_set, active)
values(gen_random_uuid(), true)

create table tech.prices (
	data_set uuid references tech.prices_datasets(data_set) on delete cascade,
	shop_guid uuid references location.shops(guid) on delete cascade,
	product_guid uuid references vitrine.products(guid) on delete cascade,
	base_price decimal(16,2) not null,
	promo_price decimal(16,2),
	discount integer,
	final_price decimal(16,2) not null,
	created_at timestamp default now(),
    updated_at timestamp default now()
)

with prices_attrs as (
	select pds.data_set data_set,
	(select guid from location.shops limit 1) shop_guid,
	(select guid from vitrine.products limit 1) product_guid,
	10.0 base_price,
	10.0 final_price
	from tech.prices_datasets pds
)
insert into tech.prices(data_set, shop_guid, product_guid, base_price, final_price)
select * from prices_attrs

select * from tech.prices

create table tech.stocks (
	data_set uuid references tech.stocks_datasets(data_set) on delete cascade,
	shop_guid uuid references location.shops(guid) on delete cascade,
	product_guid uuid references vitrine.products(guid) on delete cascade,
	value decimal(16, 2) not null,
	created_at timestamp default now(),
    updated_at timestamp default now()
)

with stocks_attrs as (
	select sds.data_set data_set,
	(select guid from location.shops limit 1) shop_guid,
	(select guid from vitrine.products limit 1) product_guid,
	10 value
	from tech.stocks_datasets sds
)
insert into tech.stocks(data_set, shop_guid, product_guid, value)
select * from stocks_attrs

select * from tech.stocks

create table personal.users (
	id serial primary key not null,
	guid uuid not null unique,
	shop_guid uuid references location.shops(guid) on delete set null,
	region_guid uuid references location.regions(guid) on delete set null,
	name text not null default '',
	avatar_url text,
	created_at timestamp default now(),
    updated_at timestamp default now(),
    deleted_at timestamp
)


with user_attrs as (
	select gen_random_uuid() guid,
	(select guid from location.shops limit 1) shop_guid,
	(select guid from location.regions limit 1) region_guid,
	'name' name,
	'' avatar_url
)
insert into personal.users(guid, shop_guid, region_guid, name, avatar_url)
select * from user_attrs


create type order_state as enum('draft', 'checkout', 'paid', 'delivered', 'cancelled')

create table trade.orders (
	id serial primary key not null,
	guid uuid not null unique,
	shop_guid uuid references location.shops(guid) on delete set null,
	user_guid uuid references personal.users(guid) on delete set null,
	state order_state not null default 'draft',
	sum decimal(16,2) not null default 0.0,
	created_at timestamp default now(),
    updated_at timestamp default now()
)


with order_attr as (
	select gen_random_uuid() guid,
	(select guid from location.shops limit 1) shop_guid,
	(select guid from personal.users limit 1) user_guid
)
insert into trade.orders(guid, shop_guid, user_guid)
select * from order_attr

create table trade.order_items (
	id serial primary key not null,
	order_guid uuid references trade.orders(guid) on delete cascade,
	product_guid uuid references vitrine.products(guid) on delete cascade,
	count decimal(16,2) not null
)

with order_item_attr as (
	select 10 count,
	(select guid from trade.orders limit 1) order_guid,
	(select guid from vitrine.products limit 1) product_guid
)
insert into trade.order_items(count, order_guid, product_guid)
select * from order_item_attr


