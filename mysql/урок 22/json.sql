create table if not exists tech.settings(feature_flags jsonb)

create index if not exists idx_settings_feature_flags on tech.settings using gin(feature_flags)

insert into tech.settings(feature_flags)
values(
    '{"setting1": {"setting2_1": {"val":1}, "setting2_2": {"val":2}}}'
  )

insert into tech.settings(feature_flags)
values(
    '{"setting2": {"setting2_1": {"val":5}, "setting2_2": {"val":6}}}'
  )

insert into tech.settings(feature_flags)
values(
    '{"setting3": {"setting2_1": {"val":15}, "setting2_2": {"val":16}}}'
  )

select *
from tech.settings
where feature_flags::jsonb @ ? '$.**.val ? (@ > 10)'

feature_flags | --------------------------------------------------------------------+
{ "setting3": { "setting2_1": { "val": 15 },"setting2_2": { "val": 16 } } } |
