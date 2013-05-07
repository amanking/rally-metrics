require File.join(File.dirname(__FILE__), "../spec_helper")
require 'unit_of_work'
require 'date'


def approx_equal(float_val)
  be_within(0.01).of(float_val)
end

describe "A Unit of work" do
  it "should return dev days" do
    work = UnitOfWork.new('', '', '', [
        [:dev, DateTime.iso8601('2013-04-12T12:00:01Z')],
        [:qa, DateTime.iso8601('2013-04-13T12:00:01Z')]
    ])

    work.dev_days.should approx_equal(1.0)
  end

  it "should return correct dev days even if the task moved from dev to done" do
    work = UnitOfWork.new('', '', '', [
        [:dev, DateTime.iso8601('2013-04-12T12:00:01Z')],
        [:done, DateTime.iso8601('2013-04-16T12:00:01Z')]
    ])

    work.dev_days.should approx_equal(4.0)
  end

  it "should return dev days even if the task is still in progress" do
    work = UnitOfWork.new('', '', '', [
        [:dev, DateTime.iso8601('2013-04-12T12:00:01Z')]
    ])

    work.dev_days.should approx_equal(25.2)
  end

  it "should return dev days as 0 if a task never went in dev" do
    work = UnitOfWork.new('', '', '', [])
    work.dev_days.should approx_equal(0.0)
  end

  it "should return dev days combined if it went in dev multiple times" do
    work = UnitOfWork.new('', '', '', [
        [:dev, DateTime.iso8601('2013-04-12T12:00:01Z')],
        [:qa, DateTime.iso8601('2013-04-16T12:00:01Z')],
        [:dev, DateTime.iso8601('2013-04-16T22:00:01Z')],
        [:done, DateTime.iso8601('2013-04-18T12:00:01Z')]
    ])

    work.dev_days.should approx_equal(5.6)
  end

  it "should return qa days even if the task is still in progress"
  it "should return qa days as 0 if a task never went in qa"
  it "should return qa days combined if it went in qa multiple times"

end