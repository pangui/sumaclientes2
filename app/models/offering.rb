# frozen_string_literal: true
class Offering < ApplicationRecord

  # associations
  belongs_to :merchant
  belongs_to :website
  has_many :status_groups, class_name: 'LeadStatusGroup', dependent: :restrict_with_exception

end
