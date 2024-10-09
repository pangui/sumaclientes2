# frozen_string_literal: true
class SelectedProperty < ApplicationRecord

  # associations
  belongs_to :offering
  belongs_to :dynamic_property
  # constants
  STATIC_TYPES = {
    'sexo' => { label: 'Sexo', type: 'list', options: %w[masculino femenino] },
    'fecha_de_nacimiento' => { label: 'Fecha de nacimiento', type: 'date' },
    'edad' => { label: 'Edad', type: 'number' },
    'telefono_movil' => { label: 'Teléfono móvil', type: 'string' },
    'telefono_particular' => { label: 'Teléfono particular', type: 'string' },
    'telefono_comercial' => { label: 'Teléfono comercial', type: 'string' },
    'direccion_particular' => { label: 'Dirección particular', type: 'string' },
    'direccion_comercial' => { label: 'Dirección comercial', type: 'string' },
    'last_state_change_date' => { label: 'Último cambio de estado', type: 'date' },
    'canal' => { label: 'Canal', type: 'string' },
    'utm_source' => { label: 'Fuente', type: 'string' }
  }.freeze
  STATIC = STATIC_TYPES.map{|k, v| [v[:label], k] }
  # scopes
  default_scope ->{ order(:sort_index) }

  class << self

    def options(offering)
      STATIC + offering.merchant.dynamic_properties.map{|a| [a.title, a.id] }
    end

  end

  def property_keyword
    if static?
      static_property
    else
      dynamic_property_id
    end
  end

  def static?
    static_property.present?
  end

  def property_keyword=(property)
    if STATIC.map{|a| a[1].to_s }.include? property.to_s
      self.static_property = property
      self.dynamic_property_id = nil
    else
      self.dynamic_property_id = property
      self.static_property = nil
    end
  end

  def nombre
    if static?
      STATIC.detect{|a| a[1] == static_property }.first
    else
      dynamic_property.title
    end
  end

  def type_for_filter
    if static?
      tipo = STATIC_TYPES[static_property]
      tipo[:static] = true
      tipo[:name] = static_property
    else
      tipo = dynamic_property.type_for_filter
      tipo[:static] = false
    end
    tipo
  end

  def evaluate_in_lead(lead)
    if static?
      lead.send(static_property.to_sym)
    else
      lead.valor(dynamic_property)
    end
  end

end
