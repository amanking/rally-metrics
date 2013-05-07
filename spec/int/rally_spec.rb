require File.join(File.dirname(__FILE__), "../spec_helper")
require 'rally_client'

def display_tasks(stories)
  stories.each { |st| puts st }
end

def approx_equal(float_val)
  be_within(0.01).of(float_val)
end

describe "Rally", :broken => true do
  before(:all) do
    @rally = Rally::RallyClient.new("<user>", "<pass>", "<workspace>", "<project>")
  end

  it "should get iteration for a given date" do
    iteration = @rally.iteration(Date.iso8601('2013-05-07'))
    iteration.should == "Sprint 16-1"
  end

  it "should report error if no iteration found for given date"

  it "should fetch story data for given sprint" do
    stories = @rally.stories("Sprint 15-4")

    stories.should have(4).items

    last = stories.last
    last.id.should == 'US62622'
    last.estimate.should approx_equal(3.0)
    last.dev_days.should approx_equal(1.4)
    last.qa_days.should approx_equal(5.7)
  end

  it "should fetch defect data for given sprint" do
    defects = @rally.defects("Sprint 15-4")

    defects.should have(5).items

    last = defects.last
    last.id.should == 'DE23703'
    last.estimate.should approx_equal(0.0)
    last.dev_days.should approx_equal(0.0)
    last.qa_days.should approx_equal(0.1)
  end
end
