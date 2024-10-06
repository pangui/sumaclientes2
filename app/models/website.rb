# frozen_string_literal: true
class Website < ApplicationRecord

  # associations
  belongs_to :merchant
  has_one \
    :folder,
    ->{ where(folder: nil) },
    dependent: :restrict_with_exception,
    inverse_of: :website
  has_many :offerings, dependent: :restrict_with_exception

end
