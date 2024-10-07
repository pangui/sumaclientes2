# frozen_string_literal: true
require 'open-uri'
class Asset < ApplicationRecord

  include DynamicRoute
  # associations
  belongs_to :folder
  # constants
  TYPES = %w[
    stylesheet
    javascript
    image
  ].freeze
  # method delegation
  delegate :website, to: :folder
  # validations
  validates :name, presence: true
  validates :name, uniqueness: { scope: :folder_id }
  # scopes
  scope :stylesheets, ->{ where(kind: 'stylesheet') }
  # storage
  has_one_attached :file
  # accessors
  attr_writer :code

  class << self

    def migrate
      errors = []
      Asset.find_each do |asset|
        url = "https://sumaclientes.com#{asset.old_path}"
        ap url
        destination_path = "/tmp/#{asset.name}"
        URI.open(url){|f| File.binwrite(destination_path, f.read) }
        asset.file.attach(
          io: File.open(destination_path),
          key: asset.attachment_url,
          filename: asset.name,
          content_type: asset.content_type
        )
      rescue OpenURI::HTTPError => e
        if Rails.env.development?
          Rails.logger.ap e.message
          errors << url
        end
        next
      end
      errors
    end

  end

  def stylesheet?
    kind == 'stylesheet'
  end

  def image?
    kind == 'image'
  end

  # def render_call
  #   <<~HTML
  #     <link href="#{rails_blob_url(file)}" rel="stylesheet" type="text/css">
  #   HTML
  # end

  def attachment_url
    "cms/#{kind.pluralize}/#{name}".gsub(/(\..{3,4})$/, "-#{SecureRandom.uuid}\\1")
  end

  def code
    return @code if @code.present?
    return nil unless stylesheet?

    tmp_file = Tempfile.new('asset')
    URI.open(file.url){|f| File.binwrite(tmp_file.path, f.read) }
    @code ||= tmp_file.read
  end

  def render
    return unless stylesheet?

    all_assets = website.all_assets
    matcher =  %r{url\(("|')?((/[a-z0-9/_\.\-]+)(\?[0-9]+)?)\1?\)}i
    while code =~ matcher
      asset = all_assets.detect{|a| a.old_path == ::Regexp.last_match(3) }
      next if asset.nil?

      self.code = code.sub(matcher, %(url("#{asset.file.url}")))
    end
  end

end
