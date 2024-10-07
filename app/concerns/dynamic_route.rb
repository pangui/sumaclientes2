# frozen_string_literal: true
module DynamicRoute

  extend ActiveSupport::Concern

  included do
    # callback
    before_save :clean_name

    def clean_name
      self.name = name.downcase
        .gsub(/\s/, '_')
        .gsub(/[^a-z0-9\._\-]/, '')
      if is_a? Webpage
        self.name = name.gsub(/\.html$/, '').gsub(/$/, '.html')
      elsif is_a?(Asset) && (kind == 'sylesheet')
        self.name = name.gsub(/\.css$/, '').gsub(/$/, '.css')
      elsif is_a?(Asset) && (kind == 'javascript')
        self.name = name.gsub(/\.css$/, '').gsub(/$/, '.js')
      end
    end

    def full_path
      "#{folder.full_path}/#{name}"
    end
  end

end
