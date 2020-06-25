require 'spec_helper'

class ColumnKing < ::ActiveRecord::Migration
  def self.drop_kings
    if table_exists?(:kings)
      drop_table :kings
    end
  end

  def self.up
    create_table :kings do |t|
      t.string :king_name_to_not_have_only_auto_increment_columns
    end
  end

  def self.down
    drop_table :kings
  end
end

describe ColumnKing do
  def columns
    connection.columns(:kings)
  end

  def connection
    ::ActiveRecord::Base.connection
  end

  def has_column?(name)
    columns.any? { |column| column.name == "#{name}" }
  end

  def has_column_typed?(name, type)
    !!(has_column?(name) &&
      columns.find { |column| column.name == "#{name}" }.sql_type =~ type)
  end

  def has_column_limit?(name, type, limit)
    !!(has_column_typed?(name, type) &&
      columns.find { |column| column.name == "#{name}" }.sql_type.to_s.gsub(/\D/, "").to_i == limit)
  end

  before do
    ColumnKing.drop_kings
    ColumnKing.up
  end

  describe "#add_column" do
    it "throws an error if table does not exist" do
      -> {
        connection.add_column(:king2, :queen_id, :integer)
      }.must_raise(ActiveRecord::StatementInvalid)
    end

    it "creates :integer columns" do
      connection.add_column(:kings, :queen_id, :integer)
      has_column?(:queen_id).must_equal(true)
      has_column_typed?(:queen_id, /int/i).must_equal(true)
    end

    it "creates :bigserial columns as :integer" do
      connection.add_column(:kings, :queen_id, :bigserial)
      has_column?(:queen_id).must_equal(true)
      has_column_typed?(:queen_id, /int/i).must_equal(true)
    end

    it "creates :string columns (as varchar)" do
      connection.add_column(:kings, :name, :string)
      has_column?(:name).must_equal(true)
      has_column_typed?(:name, /varchar/i).must_equal(true)
      has_column_limit?(:lineage, /varchar/i, 255).must_equal(true)
    end

    it "creates :text columns (as varchar columns)" do
      connection.add_column(:kings, :lineage, :text)
      has_column?(:lineage).must_equal(true)
      has_column_typed?(:lineage, /varchar/i).must_equal(true)
      has_column_limit?(:lineage, /varchar/i, 15000).must_equal(true)
    end
  end

  describe "#column_exists?" do
    it "is false if column not present" do
      connection.column_exists?(:kings, :name).must_equal(false)
    end

    it "is true when column exists" do
      connection.add_column(:kings, :name, :string)
      connection.column_exists?(:kings, :name).must_equal(true)
    end

    it "is false when column types does not match declared type" do
      connection.add_column(:kings, :name, :string)
      connection.column_exists?(:kings, :name, :integer)
    end

    it "is false when column sql_type matches but declared type does not (like string/text)" do
      connection.add_column(:kings, :name, :string)
      connection.column_exists?(:kings, :name, :text)
    end
  end

  describe "#remove_column" do
    it "removes a column that is present" do
      connection.add_column(:kings, :name, :string)
      connection.column_exists?(:kings, :name).must_equal(true)
      connection.remove_column(:kings, :name)
      connection.column_exists?(:kings, :name).must_equal(false)
    end

    it "raises an error if column not present" do
      -> {
        connection.remove_column(:kings, :name)
      }.must_raise(ActiveRecord::StatementInvalid)
    end
  end

  describe "#rename_column" do
    it "does not rename columns (JDBC)" do 
      connection.add_column(:kings, :name, :string)
      connection.rename_column(:kings, :name, :name2)
      connection.column_exists?(:kings, :name2).must_equal(true)
      connection.column_exists?(:kings, :name).must_equal(false)
      connection.rename_column(:kings, :name2, :name)
      connection.column_exists?(:kings, :name2).must_equal(false)
      connection.column_exists?(:kings, :name).must_equal(true)
    end
  end
end
