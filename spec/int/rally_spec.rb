require File.join(File.dirname(__FILE__), "../spec_helper")
require 'rally_client'

def display_stories(stories)
  stories.each { |st| puts st }
end

def approx_equal(float_val)
  be_within(0.01).of(float_val)
end

describe "Rally", :broken => true do
  before(:all) do
    @rally = Rally::RallyClient.new("<user>", "<pass>", "<workspace>", "<project>")
  end

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
    @rally.defects("Sprint 15-4").should have(5).items
  end
end
