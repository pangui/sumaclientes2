# frozen_string_literal: true
class DynamicPropertyOption < ApplicationRecord

  # associations
  belongs_to :property, class_name: 'DynamicProperty'
  # scopes
  default_scope ->{ order(:sort_index) }

end
