# frozen_string_literal: true
class CreateAreas < ActiveRecord::Migration[7.1]

  def up
    enable_extension 'unaccent'
    if non_tmp_tables.any?{|t| t == 'prospectos' }
      non_tmp_tables.each do |t|
        execute("alter table #{t} rename to tmp_#{t}")
      end
    end
    create_table :areas do |t|
      t.references :area, foreign_key: true
      t.string :country_code
      t.integer :level
      t.string :name
      t.string :code
      t.decimal :lft
      t.decimal :rgt
      t.timestamps
    end
  end

  def down
    Rails.logger.ap non_tmp_tables
    non_tmp_tables.each{|t| drop_table t }
    begin
      disable_extension 'unaccent'
    rescue StandardError
      nil
    end
  end

  def non_tmp_tables
    tables = execute(<<~SQL)
      select
        table_name
      from
        information_schema.tables
      where
        table_name !~ E'^tmp_' and
        table_name != 'ar_internal_metadata' and
        table_name != 'schema_migrations' and
        table_schema = 'public' and
        table_type = 'BASE TABLE'
    SQL
    tables.pluck('table_name')
  end

end
