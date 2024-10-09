# frozen_string_literal: true
class Customer < ApplicationRecord

  # associations
  belongs_to :merchant
  # has_many :leads
  # constants
  TYPES = %w[
    cliente
    alumno
    inscrito
    postulante
  ].freeze
  STATIC_ATTRIBUTES = {
    'first_name' => 'Nombres',
    'father_family_name' => 'Apellido paterno',
    'mother_family_name' => 'Apellido materno',
    'email' => 'Correo electrónico',
    'sex' => 'Sexo',
    'birthdate' => 'Fecha de nacimiento',
    'mobile_phone' => 'Teléfono móvil',
    'home_phone' => 'Teléfono particular',
    'work_phone' => 'Teléfono comercial',
    'home_address' => 'Dirección particular',
    'work_address' => 'Dirección comercial'
  }.freeze
  CALCULATED_ATTRIBUTES = {
    'age' => 'Edad',
    'received_at_wday' => 'Día de semana de recepción',
    'received_at_hour' => 'Hora de recepción'
  }.freeze

end
