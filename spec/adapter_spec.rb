require_relative './spec_helper.rb'

class CreateTestObject < ActiveRecord::Migration[6.1]
  def self.up
    create_table :test_objects do |t|
      t.string :string
      t.string :limit_40_string, limit: 40
      t.text :text
      t.integer :integer
      t.integer :limit_integer, limit: 8
      t.bigint :big_integer
      t.float :float
      t.decimal :decimal
      t.decimal :decimal_with_scale_and_precision, precision: 14, scale: 2
      t.datetime :datetime
      t.time :time
      t.date :date
      t.boolean :boolean
      t.timestamps
    end
  end

  def self.down
    if table_exists?(:test_objects)
      drop_table :test_objects
    end
  end
end

class TestObject < ::ActiveRecord::Base
end

describe ::TestObject do
  subject { TestObject }

  before do
    CreateTestObject.down
    CreateTestObject.up
  end

  describe "respect args in migration" do
    #TODO, test that when a migration is run with various args like :limit, :null, :precision, :scale
  end

  describe "test column data" do
    it "correctly assigns all integers as bigint column data" do
      int_column_names = ["id","integer","biginteger"]
      int_columns = TestObject.columns.select{|column| int_column_names.include?(column.name)}
      id_column = TestObject.columns.first
      _(id_column.name).must_equal("id")
      _(id_column.null).must_equal(false)

      int_columns.each do |int_column|
        _(int_column.sql_type_metadata.limit).must_equal(8)
        _(int_column.sql_type_metadata.sql_type).must_equal("bigint")
        _(int_column.sql_type_metadata.type).must_equal(:integer)
      end

    end

    it "correctly assigns non integer column data" do
      string_column = TestObject.columns.second
      _(string_column.name).must_equal("string")
      _(string_column.sql_type_metadata.limit).must_equal(255)
      _(string_column.sql_type_metadata.sql_type).must_equal("varchar(255)")
      _(string_column.sql_type_metadata.type).must_equal(:string)
      _(string_column.null).must_equal(true)

      string_limited_column = TestObject.columns.third
      _(string_limited_column.name).must_equal("limit_40_string")
      _(string_limited_column.sql_type_metadata.limit).must_equal(40)
      _(string_limited_column.sql_type_metadata.sql_type).must_equal("varchar(40)")
      _(string_limited_column.sql_type_metadata.type).must_equal(:string)
      _(string_limited_column.null).must_equal(true)
    end
  end
end
