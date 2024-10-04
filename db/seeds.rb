# frozen_string_literal: true
exit(0) unless Rails.env.development?
ApplicationRecord.non_tmp_tables.each do |table|
  ApplicationRecord.connection.execute("truncate #{table} restart identity cascade")
end
chile = Area.create(
  name: 'Chile',
  country_code: 'cl',
  level: 1,
  code: 'cl'
)
# regions
ApplicationRecord.connection.execute(<<~SQL)
  insert into areas (
    name,
    area_id,
    code,
    sort_index,
    level,
    old_id,
    old_table,
    created_at,
    updated_at
  )
  select
    nombre,
    #{chile.id},
    codigo_ine,
    posicion,
    2,
    id,
    'regiones',
    created_at,
    updated_at
  from
    tmp_regiones
  order by
    posicion
SQL
# provinces
ApplicationRecord.connection.execute(<<~SQL)
  insert into areas (
    name,
    area_id,
    code,
    sort_index,
    level,
    old_id,
    old_table,
    created_at,
    updated_at
  )
  select
    p.nombre,
    a.id,
    p.codigo_ine,
    p.codigo_ine::int,
    3,
    p.id,
    'provincias',
    p.created_at,
    p.updated_at
  from
    tmp_provincias p
    join areas a on a.old_id = p.region_id
  order by
    p.codigo_ine::int
SQL
# communes
ApplicationRecord.connection.execute(<<~SQL)
  insert into areas (
    name,
    area_id,
    code,
    sort_index,
    level,
    old_id,
    old_table,
    created_at,
    updated_at
  )
  select
    c.nombre,
    a.id,
    c.codigo_ine,
    c.codigo_ine::int,
    4,
    c.id,
    'comunas',
    c.created_at,
    c.updated_at
  from
    tmp_comunas c
    join areas a on a.old_id = c.provincia_id
  order by
    c.codigo_ine::int
SQL
# merchant
ApplicationRecord.connection.execute(<<~SQL)
  insert into merchants (
    name,
    analytics_account,
    adwords_account,
    timezone,
    cname_verification,
    billing_name,
    billing_address,
    billing_phone,
    currency_code,
    old_id,
    old_table,
    created_at,
    updated_at
  )
  select
    nombre,
    cuenta_analytics,
    cuenta_adwords,
    timezone,
    verificacion_cname,
    nombre_facturacion,
    direccion_facturacion,
    telefono_facturacion,
    codigo_moneda,
    id,
    'comercios',
    created_at,
    updated_at
  from
    tmp_comercios
  order by
    id
SQL
# websites
ApplicationRecord.connection.execute(<<~SQL)
  insert into websites (
    old_table,
    old_id,
    merchant_id,
    domain,
    google_tag_manager,
    analytics_view,
    created_at,
    updated_at
  )
  select
    'sitios',
    s.id,
    m.id,
    s.dominio,
    s.google_tag_manager,
    s.vista_analytics,
    s.created_at,
    s.updated_at
  from
    tmp_sitios s
    join merchants m on m.old_id = s.comercio_id
  order by
    s.id
SQL
# folders
ApplicationRecord.connection.execute(<<~SQL)
  insert into folders (
    old_table,
    old_id,
    name,
    created_at,
    updated_at
  )
  select
    'carpetas',
    id,
    nombre,
    created_at,
    updated_at
  from
    tmp_carpetas
  order by
    id
SQL
ApplicationRecord.connection.execute(<<~SQL)
  update
    folders
  set
    folder_id = f.folder_id
  from (
    select
      ff.id,
      fc.id as folder_id
    from
      folders ff
      join tmp_carpetas c on c.id = ff.old_id
      join tmp_carpetas cp on cp.id = c.carpeta_padre_id
      join folders fc on fc.old_id = cp.id
  ) f
  where
    f.id = folders.id
SQL
ApplicationRecord.connection.execute(<<~SQL)
  update
    folders
  set
    website_id = f.website_id
  from (
    select
      ff.id,
      ws.id as website_id
    from
      tmp_sitios s
      join websites ws on ws.old_id = s.id
      join tmp_carpetas c on c.id = s.carpeta_id
      join folders ff on ff.old_id = c.id
    ) f
  where
    f.id = folders.id
SQL
