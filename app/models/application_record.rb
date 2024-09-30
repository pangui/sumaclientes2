# frozen_string_literal: true
class ApplicationRecord < ActiveRecord::Base

  primary_abstract_class

  class << self

    def non_tmp_tables
      tables = connection.execute(<<~SQL)
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

end
