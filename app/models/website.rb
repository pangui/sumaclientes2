# frozen_string_literal: true
class Website < ApplicationRecord

  # associations
  belongs_to :merchant
  has_one :folder, dependent: :restrict_with_exception

end
