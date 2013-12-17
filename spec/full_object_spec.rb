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

class FullObject < ::ActiveRecord::Base;
  self.primary_key = "id"
end

describe ::FullObject do
  subject { FullObject.new }

  before do
    CreateFullObject.down
    CreateFullObject.up
  end

  describe "API" do 
    specify { subject.must_respond_to(:string) }
    specify { subject.must_respond_to(:text) }
    specify { subject.must_respond_to(:integer) }
    specify { subject.must_respond_to(:float) }
    specify { subject.must_respond_to(:decimal) }
    specify { subject.must_respond_to(:datetime) }
    specify { subject.must_respond_to(:time) }
    specify { subject.must_respond_to(:date) }
    specify { subject.must_respond_to(:boolean) }
  end

  describe "store and retrieve" do
    it "string" do 
      subject.string = "string"
      subject.save

      retrieved = FullObject.find(subject.id)
      retrieved.string.must_equal(subject.string)
    end

    it "text" do 
      subject.text = "text"
      subject.save

      retrieved = FullObject.find(subject.id)
      retrieved.text.must_equal(subject.text)
    end

    it "integer" do 
      subject.integer = 1234
      subject.save

      retrieved = FullObject.find(subject.id)
      retrieved.integer.must_equal(subject.integer)
    end

    it "float" do 
      subject.float = 1234.4321
      subject.save

      retrieved = FullObject.find(subject.id)
      retrieved.float.must_equal(subject.float)
    end

    it "decimal" do 
      subject.decimal = 1234.4321
      subject.save

      retrieved = FullObject.find(subject.id)
      retrieved.decimal.must_equal(subject.decimal)
    end

    it "datetime" do 
      subject.datetime = Time.current.utc
      subject.save

      retrieved = FullObject.find(subject.id)
      retrieved.datetime.to_s.must_equal(subject.datetime.to_s)
    end

    it "time" do 
      subject.time = Time.current.utc
      subject.save

      retrieved = FullObject.find(subject.id)
      retrieved.time.strftime("%H%M%S").must_equal(subject.time.strftime("%H%M%S"))
    end

    it "date" do 
      subject.date = Time.current
      subject.save

      retrieved = FullObject.find(subject.id)
      retrieved.date.must_equal(subject.date)
    end

    it "boolean (false)" do 
      subject.boolean = false
      subject.save

      retrieved = FullObject.find(subject.id)
      retrieved.boolean.must_equal(subject.boolean)
    end

    it "boolean (true)" do 
      subject.boolean = true
      subject.save

      retrieved = FullObject.find(subject.id)
      retrieved.boolean.must_equal(subject.boolean)
    end
  end
end
