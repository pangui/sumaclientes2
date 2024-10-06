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
5.times do
  break if Folder.where(website_id: nil).count.zero?

  Folder.where(website_id: nil).find_each(&:save)
end
# users
ApplicationRecord.connection.execute(<<~SQL)
  insert into users (
    merchant_id,
    admin,
    first_name,
    last_name,
    phone,
    active,
    email,
    encrypted_password,
    reset_password_token,
    reset_password_sent_at,
    remember_created_at,
    sign_in_count,
    current_sign_in_at,
    last_sign_in_at,
    last_sign_in_ip,
    confirmation_token,
    confirmed_at,
    confirmation_sent_at,
    unconfirmed_email,
    old_table,
    old_id,
    created_at,
    updated_at
  )
  select
    m.id,
    coalesce(u.admin, false),
    u.nombre,
    u.apellidos,
    u.telefono,
    not(u.deleted),
    u.email,
    u.encrypted_password,
    u.reset_password_token,
    u.reset_password_sent_at,
    u.remember_created_at,
    u.sign_in_count,
    u.current_sign_in_at,
    u.last_sign_in_at,
    u.last_sign_in_ip,
    u.confirmation_token,
    u.confirmed_at,
    u.confirmation_sent_at,
    u.unconfirmed_email,
    'usuarios',
    u.id,
    u.created_at,
    u.updated_at
  from
    tmp_usuarios u
    left join merchants m on m.old_id = u.comercio_id
  order by
    u.id
SQL
# permissions
ApplicationRecord.connection.execute(<<~SQL)
  insert into permissions (
    user_id,
    key,
    created_at,
    updated_at,
    old_table,
    old_id
  )
  select
    u.id,
    p.key,
    p.created_at,
    p.updated_at,
    'permissions',
    p.id
  from
    tmp_permissions p
    left join users u on u.old_id = p.user_id
  order by
    p.id
SQL
# offerings
ApplicationRecord.connection.execute(<<~SQL)
  insert into offerings (
    merchant_id,
    website_id,
    name,
    keyword,
    budget,
    lead_value,
    notify_to,
    analytics_view,
    leads_per_page,
    customer_type,
    active,
    created_at,
    updated_at,
    old_table,
    old_id
  )
  select
    m.id,
    w.id,
    o.titulo,
    o.nombre_clave,
    o.presupuesto,
    o.valor_cliente,
    o.notificar_a,
    o.vista_analytics,
    o.prospectos_por_pagina,
    o.tipo_cliente,
    o.status = 'active',
    o.created_at,
    o.updated_at,
    'productos',
    o.id
  from
    tmp_productos o
    left join merchants m on m.old_id = o.comercio_id
    left join websites w on w.old_id = o.sitio_id
  order by
    o.id
SQL
# offering statuses
ApplicationRecord.connection.execute(<<~SQL)
  insert into lead_status_groups (
    offering_id,
    contacted,
    name,
    color,
    sort_index,
    created_at,
    updated_at,
    old_table,
    old_id
  )
  select
    o.id,
    ep.contactado,
    ep.nombre,
    lower(ep.color),
    ep.orden,
    ep.created_at,
    ep.updated_at,
    'productos',
    ep.id
  from
    tmp_estados_prospecto ep
    left join offerings o on o.old_id = ep.producto_id
  order by
    ep.id
SQL
# initial offering statuses
ApplicationRecord.connection.execute(<<~SQL)
  update
    offerings o
  set
    initial_status_id = i.offering_status_id
  from (
    select
      o2.id as offering_id,
      os.id as offering_status_id
    from
      tmp_productos p
      join tmp_estados_prospecto ep on ep.id = p.estado_inicial_id
      join lead_status_groups os on os.old_id = ep.id
      join offerings o2 on o2.old_id = p.id
    ) i
  where
    i.offering_id = o.id
SQL
# successfull offering statuses
ApplicationRecord.connection.execute(<<~SQL)
  update
    lead_status_groups
  set
    successfull = old_id in (
      select  estado_exitoso_id
      from    tmp_productos
    )
SQL
# webpages
ApplicationRecord.connection.execute(<<~SQL)
  insert into webpages (
    folder_id,
    name,
    title,
    body,
    google_font,
    created_at,
    updated_at,
    old_table,
    old_id
  )
  select
    f.id,
    w.nombre,
    w.titulo,
    trim(w.body),
    w.google_font,
    w.created_at,
    w.updated_at,
    'paginas_web',
    w.id
  from
    tmp_paginas_web w
    left join folders f on f.old_id = w.carpeta_id
  order by
    w.id
SQL
