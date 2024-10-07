# frozen_string_literal: true
module DynamicRoute

  extend ActiveSupport::Concern

  included do
    # callback
    before_save :clean_name
    # validations
    validates :name, presence: true
    validates :name, uniqueness: { scope: :folder_id }
    # method delegation
    delegate :website, to: :folder

    def clean_name
      self.name = name.downcase
        .gsub(/\s/, '_')
        .gsub(/[^a-z0-9\._\-]/, '')
      if is_a? Webpage
        ensure_extension('html')
      elsif is_a?(Asset) && stylesheet?
        ensure_extension('css')
      elsif is_a?(Asset) && javascript?
        ensure_extension('js')
      elsif is_a?(Form)
        ensure_extension('form')
      end
    end

    def ensure_extension(ext)
      self.name = name.gsub(/\.#{ext}$/, '').gsub(/$/, ".#{ext}")
    end

    def full_path
      "#{folder.full_path}/#{name}"
    end
  end

end
