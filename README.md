# otus_202402
курс по базам

// Use DBML to define your database structure
// Docs: https://dbml.dbdiagram.io/docs

Table regions {
  id integer [pk, unique, not null]
  guid uuid [not null, unique]
  created_at timestamp [default: `now()`]
  updated_at timestamp [default: `now()`]
}

Table shops {
  id integer [pk, unique, not null]
  guid uuid [not null, unique]
  region_guid integer
  created_at timestamp [default: `now()`]
  updated_at timestamp [default: `now()`]
}

Table category {
  id integer [pk, unique, not null]
  guid uuid [not null, unique]
  ancestry string [not null, default: '/', note: 'materialized path']
  created_at timestamp [default: `now()`]
  updated_at timestamp [default: `now()`]
}

Table products {
  id integer [pk, unique, not null]
  guid uuid [not null, unique]
  category_guid uuid [not null]
}

Table prices_datasets {
  data_set uuid [unique]
  active boolean [not null, default: false]
  created_at timestamp [default: `now()`]
  updated_at timestamp [default: `now()`]
}

Table stocks_datasets {
  data_set uuid [unique]
  active boolean [not null, default: false]
  created_at timestamp [default: `now()`]
  updated_at timestamp [default: `now()`]
}

Table prices {
  data_set uuid [not null]
  shop_guid uuid [not null]
  product_guid uuid [not null]
  base_price float [not null]
  promo_price float
  discount integer
  final_price float [not null]
}

Table stocks {
  data_set uuid [not null]
  shop_guid uuid [not null]
  product_guid guid [not null]
  value float [not null]
}

Table users {
  id integer [pk, unique, not null]
  guid uuid [unique, not null]
  shop_guid uuid [not null]
  region_guid integer [not null]
  name string
}

Table orders {
  id integer [pk, unique, not null]
  guid uuid [unique, not null]
  user_guid uuid [not null]
  shop_guid uuid [not null]
  state order_state
  sum float
}

Table order_items {
  id integer [pk, unique, not null]
  order_guid uuid [not null]
  product_guid uuid [not null]
  count integer [default: 0, not null]
  sum float [default: 0, not null]
}

Enum order_state {
  draft
  chechout
  paid
  delivered
  cancelled
}

// regions
Ref: regions.guid < users.region_guid [delete: cascade, update: no action] // many-to-one
Ref: regions.guid < shops.region_guid [delete: cascade, update: no action] // many-to-one
Ref: products.guid < prices.product_guid [delete: cascade, update: no action] // many-to-one

// shops
Ref: shops.guid < users.shop_guid

// orders
Ref: orders.user_guid > users.guid
Ref: orders.shop_guid - shops.guid
Ref: orders.guid < order_items.order_guid

// products
Ref: products.guid < order_items.product_guid
Ref: products.category_guid < category.guid [delete: cascade, update: no action] // many-to-one

// prices
Ref: prices_datasets.data_set < prices.data_set [delete: cascade, update: no action] // many-to-one
Ref: shops.guid < prices.shop_guid [delete: cascade, update: no action] // many-to-one

//stocks
Ref: stocks_datasets.data_set < stocks.data_set [delete: cascade, update: no action] // many-to-one
Ref: shops.guid < stocks.shop_guid [delete: cascade, update: no action] // many-to-one

Ref: products.guid < stocks.product_guid [delete: cascade, update: no action] // many-to-one
