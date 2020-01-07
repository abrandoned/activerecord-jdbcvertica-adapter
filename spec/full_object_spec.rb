require_relative './spec_helper.rb'

class CreateFullObject < ActiveRecord::Migration[5.1]
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
  subject { FullObject.new }

  before do
    CreateFullObject.down
    CreateFullObject.up
  end

  describe "API" do
    it "must respond" do
      _(_(subject).must_respond_to(:string))
      # specify { subject.must_respond_to(:text) }
      # specify { subject.must_respond_to(:integer) }
      # specify { subject.must_respond_to(:float) }
      # specify { subject.must_respond_to(:decimal) }
      # specify { subject.must_respond_to(:datetime) }
      # specify { subject.must_respond_to(:time) }
      # specify { subject.must_respond_to(:date) }
      # specify { subject.must_respond_to(:boolean) }
    end
  end

  describe "#create with id" do
    it "sets the id if given on create" do
      subject.id = 123_456
      subject.string = "string"
      subject.save

      FullObject.find(123_456).must_equal(subject)
    end
  end

  describe "#delete" do
    it "deletes a persisted record" do 
      subject.string = "string"
      subject.save

      FullObject.count.must_equal(1)
      subject.delete
      FullObject.count.must_equal(0)
    end
  end

  describe "#delete_all" do
    it "deletes a persisted record" do 
      subject.string = "string"
      subject.save

      FullObject.count.must_equal(1)
      FullObject.where("id > 0").delete_all
      FullObject.count.must_equal(0)
    end
  end

  describe "#insert" do
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

  describe "#update" do
    it "string" do 
      change_to = "string2"
      subject.string = "string"
      subject.save

      retrieved = FullObject.find(subject.id)
      retrieved.update(:string => change_to)
      retrieved.reload.string.must_equal(change_to)
    end

    it "text" do 
      change_to = "text2"
      subject.text = "text"
      subject.save

      retrieved = FullObject.find(subject.id)
      retrieved.update(:text => change_to)
      retrieved.reload.text.must_equal(change_to)
    end

    it "integer" do 
      change_to = 4321
      subject.integer = 1234
      subject.save

      retrieved = FullObject.find(subject.id)
      retrieved.update(:integer => change_to)
      retrieved.reload.integer.must_equal(change_to)
    end

    it "float" do 
      change_to = 4321.1234
      subject.float = 1234.4321
      subject.save

      retrieved = FullObject.find(subject.id)
      retrieved.update(:float => change_to)
      retrieved.reload.float.must_equal(change_to)
    end

    it "decimal" do 
      change_to = 4321.1234
      subject.decimal = 1234.4321
      subject.save

      retrieved = FullObject.find(subject.id)
      retrieved.update(:decimal => change_to)
      retrieved.reload.decimal.must_equal(change_to)
    end

    it "datetime" do 
      change_to = Time.new(2010).utc
      subject.datetime = Time.current.utc
      subject.save

      retrieved = FullObject.find(subject.id)
      retrieved.update(:datetime => change_to)
      retrieved.reload.datetime.to_s.must_equal(change_to.to_s)
    end

    it "time" do 
      change_to = Time.new(2010).utc
      subject.time = Time.current.utc
      subject.save

      retrieved = FullObject.find(subject.id)
      retrieved.update(:time => change_to)
      retrieved.reload.time.strftime("%H%M%S").must_equal(change_to.strftime("%H%M%S"))
    end

    it "date" do 
      change_to = Time.new(2010).utc
      subject.date = Time.current
      subject.save

      retrieved = FullObject.find(subject.id)
      retrieved.update(:date => change_to)
      retrieved.reload.date.strftime("%Y%m%d").must_equal(change_to.strftime("%Y%m%d"))
    end

    it "boolean (false)" do 
      change_to = true
      subject.boolean = false
      subject.save

      retrieved = FullObject.find(subject.id)
      retrieved.update(:boolean => change_to)
      retrieved.reload.boolean.must_equal(change_to)
    end

    it "boolean (true)" do 
      change_to = false
      subject.boolean = true
      subject.save

      retrieved = FullObject.find(subject.id)
      retrieved.update(:boolean => change_to)
      retrieved.reload.boolean.must_equal(change_to)
    end
  end

  describe "#update_all" do
    it "boolean (false)" do
      change_to = true
      subject.boolean = false
      subject.save

      another = FullObject.new
      another.boolean = false
      another.save

      FullObject.where(:boolean => false).count.must_equal(2)
      FullObject.where(:boolean => false).update_all(:boolean => true)
      FullObject.where(:boolean => false).count.must_equal(0)
      FullObject.where(:boolean => true).count.must_equal(2)
    end
  end
end
