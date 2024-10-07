# frozen_string_literal: true
class Webpage < ApplicationRecord

  include DynamicRoute
  # associations
  belongs_to :folder
  # has_and_belongs_to_many :hojas_de_estilo,
  #   class_name: 'HojaDeEstilo',
  #   foreign_key: 'pagina_id',
  #   association_foreign_key: 'estilo_id',
  #   join_table: 'paginas_estilos'
  # method delegation
  delegate :website, to: :folder
  # delegate :available_stylesheets, to: :folder
  # # accessors
  # attr_accessor :rendered_body
  # validations
  validates :name, presence: true
  validates :name, uniqueness: { scope: :folder_id }

  # callbacks
  before_create :add_sample_body
  # after_save :reload_routes

  # def reload_routes
  #   DynamicRouter.reload if name_changed?
  # end

  def add_sample_body
    self.body ||= <<~HTML
      <div class="container">
        Página web #{clean_name}
      </div>
    HTML
  end

  def render
    @rendered_body = body.to_s
    @rendered_body = @rendered_body.gsub(%r{<\s*/?script.*>}i, '')
    # render forms
    render_images
    @rendered_body
  end

  # def procesar_formularios
  #   exp = %r{<form\s+src=("|')//([a-z0-9/_\.\-]+)\1(\s+cols=("|')(\d)\4)?>}i
  #   while exp =~ @rendered_body
  #     form_name = ::Regexp.last_match(2)
  #     form = sitio.obtener_archivo(form_name)
  #     cols = ::Regexp.last_match(5) || 3
  #     @rendered_body = @rendered_body.sub(exp, form.try(:imprimir, cols.to_i).to_s)
  #   end
  # end

  def render_images
    exp = %r{<img\s(.*)src=("|')//([a-z0-9/\._\-]+)\2(.*)>}i
    while exp =~ @rendered_body
      image_name = ::Regexp.last_match(3)
      img_path = sitio.obtener_archivo(image_name).try(:tmp_file).try(:url)
      @rendered_body = @rendered_body.sub(exp,
        "<img #{::Regexp.last_match(1)}src=\"#{img_path}\"#{::Regexp.last_match(4)}>")
    end
  end

  # def imprimir_hojas_de_estilo
  #   hojas_de_estilo.map(&:imprimir).join("\n")
  # end

  # def ruta_completa
  #   carpeta.ruta_completa + "/#{nombre}"
  # end

end
