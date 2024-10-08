# frozen_string_literal: true
class Form < ApplicationRecord

  include DynamicRoute
  # associations
  belongs_to :folder
  belongs_to :offering
  belongs_to :redirect_to, class_name: 'Webpage'
  has_many :fields, class_name: 'FormField', dependent: :restrict_with_exception
  # accessors and attributes
  attr_reader :span

  def render(cols = 1)
    @span = (12 / [cols.to_i, 1].max).to_i
    output = <<~HTML
      <div class="form-container">
        <div class="title">#{title}</div>
        <form method="post" class="form-horizontal" action="/leads" data-parsley-validate>
          <input type="hidden" name="lead[utm_source]" value="" id="utm_source">
          <input type="hidden" name="lead[utm_medium]" value="" id="utm_medium">
          <input type="hidden" name="lead[utm_term]" value="" id="utm_term">
          <input type="hidden" name="lead[utm_content]" value="" id="utm_content">
          <input type="hidden" name="lead[utm_campaign]" value="" id="utm_campaign">
          <input type="hidden" name="lead[channel]" value="" id="canal_mkt">
          <input type="hidden" name="form_id" value="#{id}">
          <input type="hidden" name="lead[offering_id]" value="#{offering.id}">
          <input type="hidden" name="lead[merchant_id]" value="#{offering.merchant_id}">
          #{fields.map{|f| f.render(self) }.join("\n")}
    HTML
    submit_span = 12 - ((field_counter % cols.to_i) * @span)
    output += <<~HTML
          <div class="form-group col-xs-12 col-sm-#{submit_span}">
            <div class="pull-right">
              <input type="submit" value="#{submit_label}" class="btn btn-lg btn-primary">
            </div>
          </div>
        </form>
      </div>
    HTML
    output
  end

  def dynamic_field_counter
    @dynamic_field_counter ||= -1
    @dynamic_field_counter += 1
    @dynamic_field_counter
  end

  def field_counter
    @field_counter ||= -1
    @field_counter += 1
    @field_counter
  end

end
