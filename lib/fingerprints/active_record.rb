module ActiveRecord
  module ConnectionAdapters
    class TableDefinition
      # Appends <tt>:integer</tt> columns <tt>:created_by</tt> and
      # <tt>:updated_by</tt> to the table.
      def fingerprints(*args)
        options = args.extract_options!
        column(:created_by, :integer, options)
        column(:updated_by, :integer, options)
      end
    end

    class Table
      # Adds fingerprints (created_by and updated_by) columns to the table. See SchemaStatements#add_fingerprints
      # ===== Example
      #  t.fingerprints
      def fingerprints
        @base.add_fingerprints(@table_name)
      end


      # Removes the fingerprint columns (created_by and updated_by) from the table.
      # ===== Example
      #  t.remove_fingerprints
      def remove_fingerprints
        @base.remove_fingerprints(@table_name)
      end
    end
  end

  module SchemaStatements
    # Adds fingerprints (created_by and updated_by) columns to the named table.
    # ===== Examples
    #  add_fingerprints(:suppliers)
    def add_fingerprints(table_name)
      add_column table_name, :created_by, :integer
      add_column table_name, :updated_by, :integer
    end

    # Removes the fingerprint columns (created_by and updated_by) from the table definition.
    # ===== Examples
    #  remove_fingerprints(:suppliers)
    def remove_fingerprints(table_name)
      remove_column table_name, :updated_by
      remove_column table_name, :created_by
    end
  end
end

