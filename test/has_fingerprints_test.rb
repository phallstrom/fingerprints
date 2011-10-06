require 'test_helper'

ActiveRecord::Base.establish_connection(:adapter => "sqlite3", :database => ":memory:")

def setup_db
  silence_stream(STDOUT) do
    ActiveRecord::Schema.define(:version => 1) do
      create_table :widgets do |t|
        t.column :name, :string
        t.fingerprints
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

class User
  cattr_accessor :fingerprint
end

class Widget < ActiveRecord::Base
  has_fingerprints :class_name => 'User', :method => :fingerprint
  def self.table_name() "widgets" end
end

class InvalidWidget < ActiveRecord::Base
  has_fingerprints :class_name => 'User', :method => :invalid_method
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

__END__
require 'test_helper'



################################################################################

class HasWysiwygContentTest < ActiveSupport::TestCase

  def test_responds_to_parsed_content_en
    assert_respond_to @widget, :parsed_content_en
  end

  def test_responds_to_parsed_content_es
    assert_respond_to @widget, :parsed_content_es
  end

  def test_responds_to_parsed_content
    assert_respond_to @widget, :parsed_content
  end

  def test_parsed_content_encodes_emails
    assert_no_match /philip@pjkh.com/, @widget.parsed_content_en
  end

  def test_parsed_content_converts_valid_substitutions
    @my_var = Object.new
    def @my_var.foo; "VALUE_OF_MY_VAR"; end
    assert_no_match /\{\{some_var.foo\}\}/, @widget.parsed_content_en(:some_var => @my_var)
    assert_match /VALUE_OF_MY_VAR/, @widget.parsed_content_en(:some_var => @my_var)
  end

  def test_parsed_content_does_not_convert_nonexistent_substitutions
    assert_match /\{\{invalid.foo\}\}/, @widget.parsed_content_en
  end

  def test_saved_content_en_is_cleansed
    @widget.save!
    assert_no_match %r!http://(www|en).nourishinteractive(.pjkh)?.com!, @widget.content_en
    assert_match %r!http://es.nourishinteractive(.pjkh)?.com!, @widget.content_en
  end

  def test_saved_content_es_is_cleansed
    @widget.save!
    assert_no_match %r!http://es.nourishinteractive(.pjkh)?.com!, @widget.content_es
    assert_match %r!http://www.nourishinteractive(.pjkh)?.com!, @widget.content_es
    assert_match %r!http://en.nourishinteractive(.pjkh)?.com!, @widget.content_es
  end

  def test_wysiwyg_fields_only_contains_table_fields
    assert %w[content_en content_es], Widget.wysiwyg_attributes
  end

end
