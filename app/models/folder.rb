# frozen_string_literal: true
class Folder < ApplicationRecord

  # associations
  belongs_to :folder, optional: true
  belongs_to :website, optional: true
  has_many :folders, dependent: :restrict_with_exception
  # callbacks
  before_save :inherit_website

  def inherit_website
    return if folder.nil?

    self.website = folder.website
  end

end
