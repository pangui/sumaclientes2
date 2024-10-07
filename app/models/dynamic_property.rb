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

end
