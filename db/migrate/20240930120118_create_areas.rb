# frozen_string_literal: true
class CreateAreas < ActiveRecord::Migration[7.1]

  def up
    enable_extension 'unaccent'
    if ApplicationRecord.non_tmp_tables.any?{|t| t == 'prospectos' }
      ApplicationRecord.non_tmp_tables.each do |t|
        execute("alter table #{t} rename to tmp_#{t}")
      end
    end
    create_table :areas do |t|
      t.references :area, foreign_key: true
      t.string :country_code
      t.integer :level
      t.string :name
      t.string :code
      t.integer :sort_index
      t.decimal :lft
      t.decimal :rgt
      t.timestamps
    end
    add_index :areas, %i[code area_id], unique: true
  end

  def down
    ApplicationRecord.non_tmp_tables.each{|t| drop_table t }
    begin
      disable_extension 'unaccent'
    rescue StandardError
      nil
    end
  end

end
