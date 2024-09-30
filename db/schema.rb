# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.1].define(version: 2024_09_30_120118) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "unaccent"

  create_table "areas", force: :cascade do |t|
    t.bigint "area_id"
    t.string "country_code"
    t.integer "level"
    t.string "name"
    t.string "code"
    t.decimal "lft"
    t.decimal "rgt"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["area_id"], name: "index_areas_on_area_id"
  end

  create_table "tmp_adjuntos_web", id: :integer, default: -> { "nextval('adjuntos_web_id_seq'::regclass)" }, force: :cascade do |t|
    t.integer "carpeta_id"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.string "archivo_file_name", limit: 255
    t.string "archivo_content_type", limit: 255
    t.integer "archivo_file_size"
    t.datetime "archivo_updated_at", precision: nil
    t.integer "sitio_id"
    t.index ["carpeta_id"], name: "index_adjuntos_web_on_carpeta_id"
    t.index ["sitio_id"], name: "index_adjuntos_web_on_sitio_id"
  end

  create_table "tmp_atributos_destacados", id: :integer, default: -> { "nextval('atributos_destacados_id_seq'::regclass)" }, force: :cascade do |t|
    t.integer "producto_id"
    t.integer "atributo_id"
    t.string "atributo_estatico", limit: 255
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.integer "orden"
    t.index ["atributo_id"], name: "index_atributos_destacados_on_atributo_id"
    t.index ["producto_id"], name: "index_atributos_destacados_on_producto_id"
  end

  create_table "tmp_atributos_dinamicos", id: :integer, default: -> { "nextval('atributos_dinamicos_id_seq'::regclass)" }, force: :cascade do |t|
    t.integer "producto_id"
    t.string "titulo", limit: 255
    t.string "nombre_clave", limit: 255
    t.string "tipo", limit: 255
    t.integer "orden"
    t.boolean "activo"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.integer "comercio_id"
    t.string "tipo_validacion", limit: 255
    t.string "parametro_validacion", limit: 255
    t.string "placeholder", limit: 255
    t.index ["comercio_id"], name: "index_atributos_dinamicos_on_comercio_id"
    t.index ["producto_id"], name: "index_atributos_dinamicos_on_producto_id"
  end

  create_table "tmp_campos_formulario", id: :integer, default: -> { "nextval('campos_formulario_id_seq'::regclass)" }, force: :cascade do |t|
    t.integer "formulario_id"
    t.string "atributo_estatico", limit: 255
    t.integer "atributo_dinamico_id"
    t.integer "orden"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.index ["atributo_dinamico_id"], name: "index_campos_formulario_on_atributo_dinamico_id"
    t.index ["formulario_id"], name: "index_campos_formulario_on_formulario_id"
  end

  create_table "tmp_carpetas", id: :integer, default: -> { "nextval('carpetas_id_seq'::regclass)" }, force: :cascade do |t|
    t.string "nombre", limit: 255
    t.integer "carpeta_padre_id"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.integer "sitio_id"
    t.index ["carpeta_padre_id"], name: "index_carpetas_on_carpeta_padre_id"
    t.index ["sitio_id"], name: "index_carpetas_on_sitio_id"
  end

  create_table "tmp_clientes", id: :integer, default: -> { "nextval('clientes_id_seq'::regclass)" }, force: :cascade do |t|
    t.string "nombres", limit: 255
    t.string "apellido_paterno", limit: 255
    t.string "apellido_materno", limit: 255
    t.string "sexo", limit: 255
    t.date "fecha_de_nacimiento"
    t.string "correo_electronico", limit: 255
    t.string "telefono_movil", limit: 255
    t.string "telefono_particular", limit: 255
    t.string "telefono_comercial", limit: 255
    t.string "direccion_particular", limit: 255
    t.string "direccion_comercial", limit: 255
    t.string "utm_source", limit: 255
    t.string "utm_medium", limit: 255
    t.string "utm_term", limit: 255
    t.string "utm_content", limit: 255
    t.string "utm_campaign", limit: 255
    t.string "canal", limit: 255
    t.integer "comercio_id"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.index ["comercio_id"], name: "index_clientes_on_comercio_id"
  end

  create_table "tmp_comercios", id: :integer, default: -> { "nextval('comercios_id_seq'::regclass)" }, force: :cascade do |t|
    t.string "nombre", limit: 255
    t.string "cuenta_analytics", limit: 255
    t.string "cuenta_adwords", limit: 255
    t.string "timezone", limit: 255
    t.boolean "verificacion_cname"
    t.string "nombre_facturacion", limit: 255
    t.string "direccion_facturacion", limit: 255
    t.string "telefono_facturacion", limit: 255
    t.string "codigo_moneda", limit: 255
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.string "sitio_web", limit: 255
    t.string "correo_analytics", limit: 255
    t.integer "acceso_analytics_id"
  end

  create_table "tmp_comunas", id: :integer, default: -> { "nextval('comunas_id_seq'::regclass)" }, force: :cascade do |t|
    t.integer "provincia_id"
    t.integer "ciudad_id"
    t.string "codigo_ine", limit: 255
    t.string "nombre", limit: 255
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.index ["ciudad_id"], name: "index_comunas_on_ciudad_id"
    t.index ["provincia_id"], name: "index_comunas_on_provincia_id"
  end

  create_table "tmp_custom_filter_schedules", id: :integer, default: -> { "nextval('custom_filter_schedules_id_seq'::regclass)" }, force: :cascade do |t|
    t.integer "custom_filter_id"
    t.integer "day"
    t.string "start_hour", limit: 255
    t.string "start_minute", limit: 255
    t.string "end_hour", limit: 255
    t.string "end_minute", limit: 255
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.index ["custom_filter_id"], name: "index_custom_filter_schedules_on_custom_filter_id"
  end

  create_table "tmp_custom_filters", id: :integer, default: -> { "nextval('custom_filters_id_seq'::regclass)" }, force: :cascade do |t|
    t.integer "producto_id"
    t.string "action", limit: 255
    t.string "modifier", limit: 255
    t.string "trigger", limit: 255
    t.string "variable", limit: 255
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.index ["producto_id"], name: "index_custom_filters_on_producto_id"
  end

  create_table "tmp_distribution_rules", id: :integer, default: -> { "nextval('distribution_rules_id_seq'::regclass)" }, force: :cascade do |t|
    t.integer "product_id"
    t.integer "priority"
    t.string "static_attribute", limit: 255
    t.integer "dynamic_attribute_id"
    t.string "comparison_operator", limit: 255
    t.string "distribution_value", limit: 255
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.integer "receiver_id"
    t.index ["dynamic_attribute_id"], name: "index_distribution_rules_on_dynamic_attribute_id"
    t.index ["product_id"], name: "index_distribution_rules_on_product_id"
    t.index ["receiver_id"], name: "index_distribution_rules_on_receiver_id"
  end

  create_table "tmp_estados_prospecto", id: :integer, default: -> { "nextval('estados_prospecto_id_seq'::regclass)" }, force: :cascade do |t|
    t.integer "producto_id"
    t.integer "formulario_id"
    t.boolean "contactado"
    t.string "nombre", limit: 255
    t.string "color", limit: 255
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.integer "orden"
    t.index ["formulario_id"], name: "index_estados_prospecto_on_formulario_id"
    t.index ["producto_id"], name: "index_estados_prospecto_on_producto_id"
  end

  create_table "tmp_facturas", id: :integer, default: -> { "nextval('facturas_id_seq'::regclass)" }, force: :cascade do |t|
    t.integer "comercio_id"
    t.string "correlativo", limit: 255
    t.decimal "monto"
    t.string "estado", limit: 255
    t.datetime "fecha_de_envio", precision: nil
    t.datetime "fecha_de_pago", precision: nil
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.index ["comercio_id"], name: "index_facturas_on_comercio_id"
  end

  create_table "tmp_formularios_web", id: :integer, default: -> { "nextval('formularios_web_id_seq'::regclass)" }, force: :cascade do |t|
    t.string "nombre", limit: 255
    t.string "nombre_envio", limit: 255
    t.integer "carpeta_id"
    t.string "titulo", limit: 255
    t.integer "producto_id"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.integer "sitio_id"
    t.integer "thankyou_id"
    t.index ["carpeta_id"], name: "index_formularios_web_on_carpeta_id"
    t.index ["producto_id"], name: "index_formularios_web_on_producto_id"
    t.index ["sitio_id"], name: "index_formularios_web_on_sitio_id"
    t.index ["thankyou_id"], name: "index_formularios_web_on_thankyou_id"
  end

  create_table "tmp_hojas_de_estilo", id: :integer, default: -> { "nextval('hojas_de_estilo_id_seq'::regclass)" }, force: :cascade do |t|
    t.text "codigo"
    t.integer "carpeta_id"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.string "nombre", limit: 255
    t.integer "sitio_id"
    t.index ["carpeta_id"], name: "index_hojas_de_estilo_on_carpeta_id"
    t.index ["sitio_id"], name: "index_hojas_de_estilo_on_sitio_id"
  end

  create_table "tmp_javascripts", id: :integer, default: -> { "nextval('javascripts_id_seq'::regclass)" }, force: :cascade do |t|
    t.text "codigo"
    t.integer "carpeta_id"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.string "nombre", limit: 255
    t.integer "sitio_id"
    t.index ["carpeta_id"], name: "index_javascripts_on_carpeta_id"
    t.index ["sitio_id"], name: "index_javascripts_on_sitio_id"
  end

  create_table "tmp_notas", id: :integer, default: -> { "nextval('notas_id_seq'::regclass)" }, force: :cascade do |t|
    t.integer "creador_id"
    t.integer "prospecto_id"
    t.text "contenido"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.index ["creador_id"], name: "index_notas_on_creador_id"
    t.index ["prospecto_id"], name: "index_notas_on_prospecto_id"
  end

  create_table "tmp_opciones_atributo_dinamico", id: :integer, default: -> { "nextval('opciones_atributo_dinamico_id_seq'::regclass)" }, force: :cascade do |t|
    t.integer "atributo_id"
    t.string "valor", limit: 255
    t.integer "orden"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.index ["atributo_id"], name: "index_opciones_atributo_dinamico_on_atributo_id"
  end

  create_table "tmp_paginas_estilos", id: false, force: :cascade do |t|
    t.integer "pagina_id"
    t.integer "estilo_id"
  end

  create_table "tmp_paginas_web", id: :integer, default: -> { "nextval('paginas_web_id_seq'::regclass)" }, force: :cascade do |t|
    t.string "titulo", limit: 255
    t.text "body"
    t.integer "carpeta_id"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.string "nombre", limit: 255
    t.string "google_font", limit: 255
    t.boolean "responsive"
    t.integer "sitio_id"
    t.index ["carpeta_id"], name: "index_paginas_web_on_carpeta_id"
    t.index ["sitio_id"], name: "index_paginas_web_on_sitio_id"
  end

  create_table "tmp_permissions", id: :integer, default: -> { "nextval('permissions_id_seq'::regclass)" }, force: :cascade do |t|
    t.integer "user_id"
    t.string "key", limit: 255
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.index ["user_id"], name: "index_permissions_on_user_id"
  end

  create_table "tmp_product_attributes", id: :integer, default: -> { "nextval('product_attributes_id_seq'::regclass)" }, force: :cascade do |t|
    t.integer "product_id"
    t.integer "dynamic_attribute_id"
    t.boolean "private"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
  end

  create_table "tmp_productos", id: :integer, default: -> { "nextval('productos_id_seq'::regclass)" }, force: :cascade do |t|
    t.integer "comercio_id"
    t.string "objetivo_analytics", limit: 255
    t.string "titulo", limit: 255
    t.string "nombre_clave", limit: 255
    t.decimal "presupuesto"
    t.decimal "valor_cliente"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.text "notificar_a"
    t.string "frecuencia_notificacion", limit: 255
    t.string "vista_analytics", limit: 255
    t.integer "sitio_id"
    t.integer "prospectos_por_pagina", default: 10
    t.integer "estado_inicial_id"
    t.integer "estado_exitoso_id"
    t.string "tipo_cliente", limit: 255, default: "cliente"
    t.string "status", limit: 255, default: "active"
    t.index ["comercio_id"], name: "index_productos_on_comercio_id"
    t.index ["estado_exitoso_id"], name: "index_productos_on_estado_exitoso_id"
    t.index ["estado_inicial_id"], name: "index_productos_on_estado_inicial_id"
    t.index ["sitio_id"], name: "index_productos_on_sitio_id"
  end

  create_table "tmp_prospectos", id: :integer, default: -> { "nextval('prospectos_id_seq'::regclass)" }, force: :cascade do |t|
    t.integer "producto_id"
    t.string "estado", limit: 255
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.string "nombres", limit: 255
    t.string "apellido_paterno", limit: 255
    t.string "apellido_materno", limit: 255
    t.string "sexo", limit: 255
    t.date "fecha_de_nacimiento"
    t.string "correo_electronico", limit: 255
    t.string "telefono_movil", limit: 255
    t.string "telefono_particular", limit: 255
    t.string "telefono_comercial", limit: 255
    t.string "direccion_particular", limit: 255
    t.string "direccion_comercial", limit: 255
    t.integer "comercio_id"
    t.string "utm_source", limit: 255
    t.string "utm_medium", limit: 255
    t.string "utm_term", limit: 255
    t.string "utm_content", limit: 255
    t.string "utm_campaign", limit: 255
    t.string "canal", limit: 255
    t.integer "cliente_id"
    t.integer "estado_id"
    t.date "last_state_change_date"
    t.integer "assigned_seller_id"
    t.index ["assigned_seller_id"], name: "index_prospectos_on_assigned_seller_id"
    t.index ["comercio_id"], name: "index_prospectos_on_comercio_id"
    t.index ["estado_id"], name: "index_prospectos_on_estado_id"
    t.index ["producto_id"], name: "index_prospectos_on_producto_id"
  end

  create_table "tmp_provincias", id: :integer, default: -> { "nextval('provincias_id_seq'::regclass)" }, force: :cascade do |t|
    t.integer "region_id"
    t.string "codigo_ine", limit: 255
    t.string "nombre", limit: 255
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.index ["region_id"], name: "index_provincias_on_region_id"
  end

  create_table "tmp_regiones", id: :integer, default: -> { "nextval('regiones_id_seq'::regclass)" }, force: :cascade do |t|
    t.string "codigo_ine", limit: 255
    t.integer "posicion"
    t.string "nombre", limit: 255
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
  end

  create_table "tmp_sitios", id: :integer, default: -> { "nextval('sitios_id_seq'::regclass)" }, force: :cascade do |t|
    t.integer "comercio_id"
    t.integer "carpeta_id"
    t.string "dominio", limit: 255
    t.string "google_tag_manager", limit: 255
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.string "favicon_file_name", limit: 255
    t.string "favicon_content_type", limit: 255
    t.integer "favicon_file_size"
    t.datetime "favicon_updated_at", precision: nil
    t.string "vista_analytics", limit: 255
    t.index ["carpeta_id"], name: "index_sitios_on_carpeta_id"
    t.index ["comercio_id"], name: "index_sitios_on_comercio_id"
  end

  create_table "tmp_state_changes", id: :integer, default: -> { "nextval('state_changes_id_seq'::regclass)" }, force: :cascade do |t|
    t.integer "lead_id"
    t.integer "old_state_id"
    t.integer "new_state_id"
    t.datetime "created_at", precision: nil
    t.index ["lead_id"], name: "index_state_changes_on_lead_id"
  end

  create_table "tmp_usuarios", id: :integer, default: -> { "nextval('usuarios_id_seq'::regclass)" }, force: :cascade do |t|
    t.integer "comercio_id"
    t.string "email", limit: 255, default: "", null: false
    t.string "encrypted_password", limit: 255, default: "", null: false
    t.string "reset_password_token", limit: 255
    t.datetime "reset_password_sent_at", precision: nil
    t.datetime "remember_created_at", precision: nil
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at", precision: nil
    t.datetime "last_sign_in_at", precision: nil
    t.string "current_sign_in_ip", limit: 255
    t.string "last_sign_in_ip", limit: 255
    t.string "confirmation_token", limit: 255
    t.datetime "confirmed_at", precision: nil
    t.datetime "confirmation_sent_at", precision: nil
    t.string "unconfirmed_email", limit: 255
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.boolean "admin"
    t.string "nombre", limit: 255
    t.string "apellidos", limit: 255
    t.string "telefono", limit: 255
    t.boolean "deleted", default: false
    t.index ["comercio_id"], name: "index_usuarios_on_comercio_id"
    t.index ["confirmation_token"], name: "index_usuarios_on_confirmation_token", unique: true
    t.index ["email"], name: "index_usuarios_on_email", unique: true
    t.index ["reset_password_token"], name: "index_usuarios_on_reset_password_token", unique: true
  end

  create_table "tmp_valores_atributo_dinamico", id: :integer, default: -> { "nextval('valores_atributo_dinamico_id_seq'::regclass)" }, force: :cascade do |t|
    t.integer "prospecto_id"
    t.integer "atributo_id"
    t.text "valor_string"
    t.integer "valor_integer"
    t.datetime "valor_datetime", precision: nil
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.integer "cliente_id"
    t.index ["atributo_id"], name: "index_valores_atributo_dinamico_on_atributo_id"
    t.index ["cliente_id"], name: "index_valores_atributo_dinamico_on_cliente_id"
    t.index ["prospecto_id"], name: "index_valores_atributo_dinamico_on_prospecto_id"
  end

  create_table "tmp_visitas_analytics", id: :integer, default: -> { "nextval('visitas_analytics_id_seq'::regclass)" }, force: :cascade do |t|
    t.integer "producto_id"
    t.date "dia"
    t.integer "cantidad"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.string "canal", limit: 255
  end

  add_foreign_key "areas", "areas"
end
