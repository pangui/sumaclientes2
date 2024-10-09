# frozen_string_literal: true
class DynamicProperty < ApplicationRecord

  # associations
  belongs_to :merchant
  belongs_to :offering
  has_many \
    :options,
    class_name: 'DynamicPropertyOption',
    dependent: :restrict_with_exception,
    foreign_key: :property_id,
    inverse_of: :property
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
  FILTER_TYPES = {
    'text' => { type: 'string' },
    'textarea' => { type: 'string' },
    'select' => { type: 'list' },
    'date' => { type: 'date' },
    'commune' => { type: 'commune' }
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

  def type_for_filter
    filter_type = FILTER_TYPES[input_type]
    filter_type[:label] = title
    filter_type[:name] = id.to_s
    filter_type[:options] = options.map(&:value) if filter_type[:type] == 'list'
    filter_type[:options] = Area.chilean_communes.order(:name).pluck(:id, :name) if input_type == 'commune'
    filter_type
  end

end
