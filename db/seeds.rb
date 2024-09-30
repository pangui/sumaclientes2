# frozen_string_literal: true
exit(0) unless Rails.env.development?
ApplicationRecord.non_tmp_tables.each do |table|
  ApplicationRecord.connection.execute("truncate #{table} restart identity")
end
old_communes = ApplicationRecord.connection.execute(<<~SQL)
  select
    r.nombre as region_name,
    r.codigo_ine as region_code,
    r.posicion as region_sort_index,
    p.nombre as province_name,
    p.codigo_ine as province_code,
    p.codigo_ine::int as province_sort_index,
    c.nombre as commune_name,
    c.codigo_ine as commune_code,
    c.codigo_ine::int as commune_sort_index
  from
    tmp_regiones r
    join tmp_provincias p on p.region_id = r.id
    join tmp_comunas c on c.provincia_id = p.id
  order by
    r.posicion,
    p.codigo_ine::int,
    c.codigo_ine::int
SQL
chile = Area.create(
  name: 'Chile',
  country_code: 'cl',
  level: 1,
  code: 'cl'
)
regions = {}
provinces = {}
old_communes.each do |row| # rubocop:disable Metrics/BlockLength
  region_data = {
    area_id: chile.id,
    country_code: chile.code,
    level: 2,
    name: row['region_name'],
    code: row['region_code'],
    sort_index: row['region_sort_index']
  }
  regions[region_data[:code]] ||= Area.create(region_data)
  region = regions[region_data[:code]]
  province_data = {
    area_id: region.id,
    country_code: chile.code,
    level: 3,
    name: row['province_name'],
    code: row['province_code'],
    sort_index: row['province_sort_index']
  }
  provinces[province_data[:code]] ||= Area.create(province_data)
  province = provinces[province_data[:code]]
  Area.create({
    area_id: province.id,
    country_code: chile.code,
    level: 4,
    name: row['commune_name'],
    code: row['commune_code'],
    sort_index: row['commune_sort_index']
  })
end
