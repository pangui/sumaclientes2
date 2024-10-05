# frozen_string_literal: true
class Merchant < ApplicationRecord

  # associations
  has_many :websites, dependent: :restrict_with_exception
  has_many :users, dependent: :restrict_with_exception
  # callbacks
  after_create :create_website
  # nested attributes
  accepts_nested_attributes_for :websites, reject_if: ->(w){ w[:domain].blank? }, allow_destroy: true

  def create_website
    website = Website.create(domain: "#{name.parameterize}.sumaclientes.com")
    websites << website
    # offerings << Offering.create(title: 'Mi producto', website:)
  end

end
