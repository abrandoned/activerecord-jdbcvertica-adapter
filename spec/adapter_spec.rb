require_relative './spec_helper.rb'

class CreateTestObject < ActiveRecord::Migration[5.1]
  def self.up
    create_table :test_objects, :id => :bigserial do |t|
      t.string :string, limit: 40
      t.string :limit_40_string
      t.text :text
      t.integer :integer
      t.bigint :big_integer
      t.float :float
      t.decimal :decimal
      t.datetime :datetime
      t.time :time
      t.date :date
      t.boolean :boolean
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
      model = TestObject
      id_column = TestObject.columns.first
      _(id_column.name).must_equal("id")
      _(id_column.table_name).must_equal(model.table_name)
      _(id_column.null).must_equal(false)

      int_columns.each do |int_column|
        _(int_column.sql_type_metadata.limit).must_equal(8)
        _(int_column.sql_type_metadata.sql_type).must_equal("bigint")
        _(int_column.sql_type_metadata.type).must_equal(:integer)
      end

    end

    it "correctly assigns non integer column data" do
      model = TestObject
      id_column = TestObject.columns.second
      _(id_column.table_name).must_equal(model.table_name)
      _(id_column.name).must_equal("string")
      _(id_column.sql_type_metadata.limit).must_equal(40)
      _(id_column.sql_type_metadata.sql_type).must_equal("varchar(40)")
      _(id_column.sql_type_metadata.type).must_equal(:string)
      _(id_column.null).must_equal(true)
    end
  end
end
