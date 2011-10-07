require 'test_helper'

ActiveRecord::Base.establish_connection(:adapter => "sqlite3", :database => ":memory:")

def setup_db
  silence_stream(STDOUT) do
    ActiveRecord::Schema.define(:version => 1) do
      create_table :widgets do |t|
        t.column :name, :string
        t.fingerprints
      end
      create_table :users do |t|
        t.column :login, :string
      end
    end
  end
end

def teardown_db
  silence_stream(STDOUT) do
    ActiveRecord::Base.connection.tables.each do |table|
      ActiveRecord::Base.connection.drop_table(table)
    end
  end
end

class User < ActiveRecord::Base
  has_fingerprints
  def self.table_name() "users" end
end

class InvalidUser < ActiveRecord::Base
  def self.table_name() "users" end
end

class Widget < ActiveRecord::Base
  leaves_fingerprints :class_name => 'User'
  def self.table_name() "widgets" end
end

class InvalidWidget < ActiveRecord::Base
  leaves_fingerprints :class_name => 'InvalidUser'
  def self.table_name() "widgets" end
end

class HasFingerprintsTest < ActiveSupport::TestCase
  def setup
    setup_db
    @widget = Widget.new(:name => 'Spring')
    @invalid_widget = InvalidWidget.new(:name => 'Mobius Strip')
  end

  def teardown
    teardown_db
  end

  def test_fingerprint_columns_exist
    assert Widget.column_names.include? 'created_by'
    assert Widget.column_names.include? 'updated_by'
  end

  def test_fingerprint_associations_exist
    assert_equal :belongs_to, Widget.reflect_on_association(:creator).try(:macro)
    assert_equal :belongs_to, Widget.reflect_on_association(:updater).try(:macro)
  end

  def test_fingerprints_set_on_create
    User.fingerprint = 5
    @widget.save!
    assert_equal 5, @widget.created_by
    assert_nil @widget.updated_by
  end

  def test_fingerprints_set_on_update
    User.fingerprint = 5
    @widget.save!
    User.fingerprint = 6
    @widget.save!
    assert_equal 5, @widget.created_by
    assert_equal 6, @widget.updated_by
  end

  def test_invalid_fingerprint_method_raises_error
    assert_raise NoMethodError do
      @invalid_widget.save
    end
  end

end
