# frozen_string_literal: true
class Permission < ApplicationRecord

  # associations
  belongs_to :user
  # constants
  FOR_BUSINESS_USERS = {
    'Usuarios y permisos' => {
      'users/manage_all' => 'Administración completa',
      'users/permissions' => 'Reasignar permisos'
    },
    'Leads' => {
      'leads/manage_all' => 'Administrar todos',
      'leads/view_assigned' => 'Administrar sólo leads asignados'
    },
    'Sitio' => {
      'sites/manage' => 'Administrar landings'
    }
  }.freeze
  FOR_ADMINS = {
    'Usuarios' => {
      'users/impersonate' => 'Impersonar usuarios'
    }
  }.freeze

end
