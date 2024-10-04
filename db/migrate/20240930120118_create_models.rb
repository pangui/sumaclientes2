# frozen_string_literal: true
class CreateModels < ActiveRecord::Migration[7.1]

  def up
    enable_extension 'unaccent'
    if ApplicationRecord.non_tmp_tables.any?{|t| t == 'prospectos' }
      ApplicationRecord.non_tmp_tables.each do |t|
        execute("alter table #{t} rename to tmp_#{t}")
      end
    end
    drop_table :tmp_facturas, if_exists: true
    recreated_table :areas do |t|
      t.references :area, foreign_key: true
      t.string :country_code
      t.integer :level
      t.string :name
      t.string :code
      t.integer :sort_index
      t.decimal :lft
      t.decimal :rgt
    end
    add_index :areas, %i[code area_id], unique: true
    recreated_table :merchants do |t|
      t.string :name
      t.string :analytics_account
      t.string :adwords_account
      t.string :timezone
      t.boolean :cname_verification, default: false, null: false
      t.string :billing_name
      t.string :billing_address
      t.string :billing_phone
      t.string :currency_code
    end
  end

  def recreated_table(name)
    create_table name do |t|
      yield (t)
      t.string :old_table
      t.integer :old_id
      t.timestamps
    end
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
