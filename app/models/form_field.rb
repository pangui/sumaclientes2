# frozen_string_literal: true
class FormField < ApplicationRecord

  # associations
  belongs_to :form
  belongs_to :dynamic_property, optional: true
  # scopes
  default_scope ->{ order(:sort_index) }
  # constants
  STATIC = [
    ['Nombres', 'nombres'],
    ['Apellido paterno', 'apellido_paterno'],
    ['Apellido materno', 'apellido_materno'],
    ['Correo electrónico', 'correo_electronico'],
    ['Sexo', 'sexo'],
    ['Fecha de nacimiento', 'fecha_de_nacimiento'],
    ['Teléfono móvil', 'telefono_movil'],
    ['Teléfono particular', 'telefono_particular'],
    ['Teléfono comercial', 'telefono_comercial'],
    ['Dirección particular', 'direccion_particular'],
    ['Dirección comercial', 'direccion_comercial']
  ].freeze
  SPECIAL_TYPES = {
    correo_electronico: 'email',
    sexo: 'sex',
    fecha_de_nacimiento: 'birthday'
  }.freeze
  VALIDATIONS = {
    correo_electronico: 'email',
    telefono_movil: 'number',
    telefono_particular: 'number',
    telefono_comercial: 'number'
  }.freeze
  # attributes & accessors
  attribute :property
  attr_reader :field_counter

  class << self

    def dynamic(merchant)
      merchant.dynamic_properties.map do |at|
        [at.title, at.id]
      end
    end

  end

  def property=(at)
    if STATIC.map{|a| a[1].to_s }.include? at.to_s
      self.static_property = at
      self.dynamic_property_id = nil
    else
      self.dynamic_property_id = at
      self.static_property = nil
    end
  end

  def property
    static_property.presence || dynamic_property_id
  end

  def static?
    static_property.present?
  end

  def property_name
    if static?
      STATIC.detect{|e| e[1] == static_property }&.first
    else
      dynamic_property.title
    end
  end

  def property_keyword
    if static?
      STATIC.detect{|e| e[1] == static_property }.last.to_sym
    else
      dynamic_property_id.to_sym
    end
  end

  def special_field?
    property_keyword.in?(SPECIAL_TYPES.keys)
  end

  def render_as_text
    validation = ''
    if VALIDATIONS.key?(property_keyword)
      validation = <<~HTML
        data-parsley-type="#{VALIDATIONS[property_keyword]}"
      HTML
    end
    <<~HTML
      <input
        type="text"
        class="form-control"
        name="lead[#{property_keyword}]"
        placeholder="#{property_name}"
        required data-parsley-errors-container="#field_#{field_counter}"
        #{validation}
      >
    HTML
  end

  def render_as_email
    <<~HTML
      <input
        type="text"
        class="form-control"
        name="lead[#{property_keyword}]"
        placeholder="#{property_name}"
        required data-parsley-type="email"
        data-parsley-errors-container="#field_#{field_counter}"
      >
    HTML
  end

  def render_as_sex
    <<~HTML
      <select name="lead[sexo]" class="form-control" required data-parsley-errors-container="#field_#{field_counter}">
        <option value="">Sexo</option>
        <option value="masculino">Masculino</option>
        <option value="femenino">Femenino</option>
      </select>
    HTML
  end

  def render_as_birthday
    <<~HTML
      <div class="input-group date">
        <input type="hidden" name="lead[#{property_keyword}]"/>
        <input type="text" class="form-control" name="aux_lead_#{property_keyword}" placeholder="#{property_name}" required data-parsley-errors-container="#field_#{field_counter}"/>
        <span class="input-group-addon"><i class="glyphicon glyphicon-th"></i></span>
      </div>
    HTML
  end

  def render(form)
    @field_counter = form.field_counter
    if static?
      input = special_field? ? send("render_as_#{SPECIAL_TYPES[property_keyword]}") : render_as_text
    else
      index = form.dynamic_field_counter
      hidden = <<~HTML
        <input name="lead[property_values][#{index}][atributo_id]" type="hidden" value="#{dynamic_property_id}">
      HTML
      case dynamic_property.input_type
      when 'text'
        input = <<~HTML
          <input
            type="text"
            class="form-control"
            name="lead[property_values][#{index}][string_value]"
            required data-parsley-errors-container="#field_#{field_counter}"
          >
        HTML
        input = add_placeholder(input)
        input = validate_dynamic_property(input)
      when 'textarea'
        input = <<~HTML
          <textarea
            class="form-control"
            name="lead[property_values][#{index}][string_value]"
            required data-parsley-errors-container="#field_#{field_counter}"
            rows="4"
          ></textarea>
        HTML
        input = add_placeholder(input)
        input = validate_dynamic_property(input)
      when 'select'
        options = dynamic_property.options.order(:sort_index).inject('') do |acc, o|
          acc + <<~HTML
            <option value="#{o.valor}">#{o.valor}</option>
          HTML
        end
        input = <<~HTML
          <select class="form-control" name="lead[property_values][#{index}][string_value]" required data-parsley-errors-container="#field_#{field_counter}">
            <option value="">#{property_name}</option>
            #{options}
          </select>
        HTML
      when 'date'
        input = <<~HTML
          <div class="input-group date">
            <input type="hidden" name="lead[property_values][#{index}][datetime_value]"/>
            <input
              type="text"
              class="form-control"
              name="lead_property_values_#{index}_datetime_value"
              placeholder="#{property_name}"
              required data-parsley-errors-container="#field_#{field_counter}"
            >
            <span class="input-group-addon"><i class="glyphicon glyphicon-th"></i></span>
          </div>
        HTML
      when 'commune'
        options = Area.chilean_communes.order(:name).all.inject('') do |acc, commune|
          acc + <<~HTML
            <option value="#{commune.id}">#{commune.name}</option>
          HTML
        end
        input = <<~HTML
          <select class="form-control" name="lead[property_values][#{index}][integer_value]" required data-parsley-errors-container="#field_#{field_counter}">
            <option value="">#{property_name}</option>
            #{options}
          </select>
        HTML
      end
      input = "#{hidden}#{input}"
    end
    cols = (12.0 / form.span.to_f).to_i
    clearfix = '<div class="clearfix"></div>' if (field_counter % cols) == (cols - 1)
    <<~HTML
      <div class="form-group col-xs-12 col-sm-#{form.span}">
        #{input}
        <div id="field_#{field_counter}"></div>
      </div>
      #{clearfix}
    HTML
  end

  def validate_dynamic_property(input)
    validation = dynamic_property.validation
    return input if validation.blank?

    case validation
    when /^type_(.*)$/
      validator = 'type'
      params = ::Regexp.last_match(1)
    when /^custom_(.*)$/
      validator = ::Regexp.last_match(1)
      params = ''
    else
      validator = validation
      params = dynamic_property.validation_params
    end
    input.strip.gsub(/>$/, " data-parsley-#{validator}=\"#{params}\">")
  end

  def add_placeholder(input)
    placeholder = dynamic_property.placeholder || property_name
    input.strip.gsub(/>$/, " placeholder=\"#{placeholder}\">")
  end

end
