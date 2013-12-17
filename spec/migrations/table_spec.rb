require 'spec_helper'

class TableKing < ::ActiveRecord::Migration
  def self.drop_kings
    if table_exists?(:kings)
      drop_table :kings
    end
  end

  def self.up
    create_table :kings
  end

  def self.down
    drop_table :kings
  end
end

describe ::TableKing do
  before do
    ::TableKing.drop_kings
  end

  describe "#create_table" do
    it "creates a table in the schema with create_table" do
      ::ActiveRecord::Base.connection.tables.wont_include("kings")
      ::TableKing.up
      ::ActiveRecord::Base.connection.tables.must_include("kings")
      ::TableKing.down
      ::ActiveRecord::Base.connection.tables.wont_include("kings")
    end
  end

  describe "#drop_table" do
    it "drops a table in the schema with drop_table" do
      ::ActiveRecord::Base.connection.tables.wont_include("kings")
      ::TableKing.up
      ::ActiveRecord::Base.connection.tables.must_include("kings")
      ::TableKing.down
      ::ActiveRecord::Base.connection.tables.wont_include("kings")
    end
  end

  describe "#table_exists?" do
    it "returns false if table not present" do
      ::ActiveRecord::Base.connection.table_exists?("kings").must_equal(false)
    end

    it "returns true if table is present" do
      ::ActiveRecord::Base.connection.table_exists?("kings").must_equal(false)
      ::TableKing.up
      ::ActiveRecord::Base.connection.table_exists?("kings").must_equal(true)
      ::TableKing.down
      ::ActiveRecord::Base.connection.table_exists?("kings").must_equal(false)
    end
  end
end
