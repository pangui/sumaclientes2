# frozen_string_literal: true
class Area < ApplicationRecord

  # associations
  belongs_to :area, optional: true
  has_many :areas, dependent: :destroy

end
