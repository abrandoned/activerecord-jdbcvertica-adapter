require 'spec_helper'

class IndexKing < ::ActiveRecord::Migration
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

# Vertica does not support "indexing" it uses Projections
# and those must be created differently
#
describe IndexKing do
  def connection
    ::ActiveRecord::Base.connection
  end

  before do
    IndexKing.drop_kings
  end

  describe "#add_index" do
    it "throws an error .... always" do
      -> {
        connection.add_index(:kings, "id")
      }.must_raise(ActiveRecord::StatementInvalid)
    end
  end

  describe "#index_exists?" do
    it "always says false" do
      connection.index_exists?(:kings, :id).must_equal(false)
      connection.index_exists?(:kings, [ :id, :not_id ]).must_equal(false)
    end
  end

  describe "#remove_index" do
    it "throws an error .... always" do
      -> {
        connection.remove_index(:kings, "id")
      }.must_raise(ArgumentError)
    end
  end

  describe "#rename_index" do
    it "throws an error .... always" do
      -> {
        connection.rename_index(:kings, "id", "derp")
      }.must_raise(ArgumentError)
    end
  end
end
