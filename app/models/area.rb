# frozen_string_literal: true
class Area < ApplicationRecord

  # associations
  belongs_to :area, optional: true
  has_many :areas, dependent: :destroy
  # scopes
  scope :chilean_communes, ->{ where(country_code: 'cl', level: 4) }

end
