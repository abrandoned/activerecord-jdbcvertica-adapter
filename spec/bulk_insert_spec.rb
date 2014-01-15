require 'spec_helper'

class CreateFullObject < ::ActiveRecord::Migration
  def self.up
    create_table :full_objects do |t|
      t.string :string
      t.text :text
      t.integer :integer
      t.float :float
      t.decimal :decimal
      t.datetime :datetime
      t.time :time
      t.date :date
      t.boolean :boolean
    end
  end

  def self.down
    if table_exists?(:full_objects)
      drop_table :full_objects
    end
  end
end

class FullObject < ::ActiveRecord::Base
end

describe ::FullObject do
  before do
    CreateFullObject.down
    CreateFullObject.up
  end

  it "bulk inserts" do
    ::FullObject.count.must_equal(0)
    a = []
    100.times { a << ["derp"] }
    ::FullObject.bulk_insert([:string], a)
    ::FullObject.count.must_equal(100)
  end

  it "records with string" do
    ::FullObject.count.must_equal(0)
    a = []
    100.times { a << FullObject.new(:string => "derp") }
    ::FullObject.bulk_insert_records(a)
    ::FullObject.count.must_equal(100)
  end

  it "records with integer" do
    ::FullObject.count.must_equal(0)
    a = []
    100.times { a << FullObject.new(:integer => 1) }
    ::FullObject.bulk_insert_records(a)
    ::FullObject.count.must_equal(100)
  end

  it "records with DateTime" do
    ::FullObject.count.must_equal(0)
    a = []
    100.times { a << FullObject.new(:datetime => Time.current) }
    ::FullObject.bulk_insert_records(a)
    ::FullObject.count.must_equal(100)
  end
end
