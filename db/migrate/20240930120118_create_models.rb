# frozen_string_literal: true
class CreateModels < ActiveRecord::Migration[7.1]

  def up # rubocop:disable Metrics/MethodLength
    # Use Active Record's configured type for primary and foreign keys
    primary_key_type, foreign_key_type = primary_and_foreign_key_types

    create_table :active_storage_blobs, id: primary_key_type do |t|
      t.string   :key,          null: false
      t.string   :filename,     null: false
      t.string   :content_type
      t.text     :metadata
      t.string   :service_name, null: false
      t.bigint   :byte_size,    null: false
      t.string   :checksum
      if connection.supports_datetime_with_precision?
        t.datetime :created_at, precision: 6, null: false
      else
        t.datetime :created_at, null: false
      end
      t.index [:key], unique: true
    end
    create_table :active_storage_attachments, id: primary_key_type do |t|
      t.string     :name,     null: false
      t.references :record,   null: false, polymorphic: true, index: false, type: foreign_key_type
      t.references :blob,     null: false, type: foreign_key_type
      if connection.supports_datetime_with_precision?
        t.datetime :created_at, precision: 6, null: false
      else
        t.datetime :created_at, null: false
      end
      t.index %i[record_type record_id name blob_id], name: :index_active_storage_attachments_uniqueness,
        unique: true
      t.foreign_key :active_storage_blobs, column: :blob_id
    end

    create_table :active_storage_variant_records, id: primary_key_type do |t| # rubocop:disable Rails/CreateTableWithTimestamps
      t.belongs_to :blob, null: false, index: false, type: foreign_key_type
      t.string :variation_digest, null: false
      t.index %i[blob_id variation_digest], name: :index_active_storage_variant_records_uniqueness, unique: true
      t.foreign_key :active_storage_blobs, column: :blob_id
    end
    enable_extension 'unaccent'
    if ApplicationRecord.non_tmp_tables.any?{|t| t == 'prospectos' }
      ApplicationRecord.non_tmp_tables.each do |t|
        execute("alter table #{t} rename to tmp_#{t}")
      end
    end
    drop_table :tmp_facturas, if_exists: true
    recreate_table :areas do |t|
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
    recreate_table :merchants do |t|
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
    recreate_table :websites do |t|
      t.references :merchant, foreign_key: true
      t.string :domain
      t.string :google_tag_manager
      t.string :analytics_view
    end
    recreate_table :folders do |t|
      t.references :website, foreign_key: true
      t.references :folder, foreign_key: true
      t.string :name
    end
    add_index :folders, %i[name folder_id], unique: true
  end

  def recreate_table(name)
    create_table name do |t|
      yield (t)
      t.timestamps
      t.string :old_table
      t.integer :old_id
    end
  end

  def primary_and_foreign_key_types
    config = Rails.configuration.generators
    setting = config.options[config.orm][:primary_key_type]
    primary_key_type = setting || :primary_key
    foreign_key_type = setting || :bigint
    [primary_key_type, foreign_key_type]
  end

  def down
    ApplicationRecord.non_tmp_tables.each{|t| drop_table t, force: :cascade }
    begin
      disable_extension 'unaccent'
    rescue StandardError
      nil
    end
  end

end
