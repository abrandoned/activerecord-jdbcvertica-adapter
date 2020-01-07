require_relative '../spec_helper.rb'

class TableKing < ::ActiveRecord::Migration[5.1]
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

describe ::TableKing do
  def connection
    ::ActiveRecord::Base.connection
  end

  before do
    ::TableKing.drop_kings
  end

  describe "#create_table" do
    it "creates a table in the schema with create_table" do
      connection.tables.wont_include("kings")
      ::TableKing.up
      connection.tables.must_include("kings")
      ::TableKing.down
      connection.tables.wont_include("kings")
    end
  end

  describe "#drop_table" do
    it "drops a table in the schema with drop_table" do
      connection.tables.wont_include("kings")
      ::TableKing.up
      connection.tables.must_include("kings")
      ::TableKing.down
      connection.tables.wont_include("kings")
    end
  end

  describe "#rename_table" do
    it "renames a table" do
      -> {
        connection.rename_table("kings", "king_slayers")
      }.must_raise(NotImplementedError)
    end
  end

  describe "#table_exists?" do
    it "returns false if table not present" do
      connection.table_exists?("kings").must_equal(false)
    end

    it "returns true if table is present" do
      connection.table_exists?("kings").must_equal(false)
      ::TableKing.up
      connection.table_exists?("kings").must_equal(true)
      ::TableKing.down
      connection.table_exists?("kings").must_equal(false)
    end
  end
end
