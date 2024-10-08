# frozen_string_literal: true
class DynamicProperty < ApplicationRecord

  # associations
  belongs_to :merchant
  belongs_to :offering
  # constants
  INPUT_TYPES = {
    text: 'Campo de texto (una línea)',
    textarea: 'Campo de texto (varias líneas)',
    select: 'Lista desplegable',
    date: 'Fecha',
    commune: 'Comunas de Chile'
  }.freeze
  VALIDATIONS = {
    type_number: 'Sólo números',
    custom_rut: 'Rut chileno (12.345.678-9)',
    pattern: 'Expresión regular (avanzado)'
  }.freeze
  # scopes
  default_scope ->{ order(:sort_index) }
  TIPOS_FILTROS = {
    'texto' => { type: 'string' },
    'textarea' => { type: 'string' },
    'lista' => { type: 'list' },
    'fecha' => { type: 'date' },
    'comuna' => { type: 'commune' }
  }.freeze

  # # callbacks
  # before_create :asignar_orden

  # # alias methods for english translation
  # alias_attribute :title, :titulo

  # def asignar_orden
  #   return nil if producto.nil?

  #   self.orden = producto.atributos_dinamicos.count + 1
  # end

  # def subir
  #   return false if primero?

  #   ant = anterior
  #   ant.orden = ant.orden.to_i + 1
  #   ant.save
  #   self.orden = [0, orden.to_i - 1].max
  #   save
  # end

  # def bajar
  #   return false if ultimo?

  #   sig = siguiente
  #   sig.orden = sig.orden.to_i - 1
  #   sig.save
  #   self.orden = [producto.atributos_dinamicos.count, orden.to_i + 1].min
  #   save
  # end

  # def primero?
  #   orden.to_i == 1
  # end

  # def ultimo?
  #   orden.to_i == producto.atributos_dinamicos.count
  # end

  # def siguiente
  #   producto.atributos_dinamicos.where(orden: orden.to_i + 1).first
  # end

  # def anterior
  #   producto.atributos_dinamicos.where(orden: orden.to_i - 1).first
  # end

  # def demo_opciones
  #   case tipo
  #   when 'texto'
  #     '{Valor libre}'
  #   when 'textarea'
  #     '{Valor libre}'
  #   when 'lista'
  #     "#{opciones.limit(3).map(&:valor).join(', ')}..."
  #   when 'comuna'
  #     "#{Comuna.limit(3).map(&:nombre).join(', ')}..."
  #   when 'fecha'
  #     '{dd/mm/yyyy}'
  #   end
  # end

  # def tipo_para_filtro
  #   tipo_filtro = TIPOS_FILTROS[tipo]
  #   tipo_filtro[:label] = titulo
  #   tipo_filtro[:name] = id.to_s
  #   tipo_filtro[:options] = opciones.map(&:valor) if tipo_filtro[:type] == 'list'
  #   tipo_filtro[:options] = Comuna.order(:nombre).pluck(:id, :nombre) if tipo == 'comuna'
  #   tipo_filtro
  # end

end
