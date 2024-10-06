# frozen_string_literal: true
class Merchant < ApplicationRecord

  # associations
  has_many :websites, dependent: :restrict_with_exception
  has_many :users, dependent: :restrict_with_exception
  has_many :offerings, ->{ where(active: true) }, dependent: :restrict_with_exception, inverse_of: :merchant
  # has_many :all_products, class_name: 'Producto'
  # has_many :clientes
  # has_many :prospectos
  # has_many :atributos_dinamicos, class_name: 'AtributoDinamico'
  # callbacks
  after_create :create_website
  # nested attributes
  accepts_nested_attributes_for :websites, reject_if: ->(w){ w[:domain].blank? }, allow_destroy: true

  def create_website
    website = Website.create(domain: "#{name.parameterize}.sumaclientes.com")
    websites << website
    offerings << Offering.create(title: 'Mi producto', website:)
  end

  # def export_leads
  #   productos
  #     .includes({ prospectos: [{ valores: :atributo }, :estado_dinamico] })
  #     .map(&:prospectos)
  #     .flatten
  #     .sort_by(&:created_at)
  # end

  # def borrar_vistas_analytics
  #   vistas_analytics.each(&:destroy)
  # end

  # def buscar_cliente(correo_electronico)
  #   correo = correo_electronico.to_s.downcase
  #   c = clientes.where(correo_electronico: correo).first
  #   c ||= Cliente.create(correo_electronico: correo, comercio_id: id)
  #   c
  # end

end
