require File.join(File.dirname(__FILE__), "../spec_helper")
require 'revs_parser'

describe "Revisions parser" do
  before(:all) do
    @revs_parser = RevsParser.new
  end

  it "should return schedule with development start date" do
    schedule = @revs_parser.parse(['2013-04-16T04:36:22.762Z | SCHEDULE STATE changed from [Defined] to [In-Progress]'])

    schedule.should have_exactly(1).item
    schedule.first.should include('In-Progress' => DateTime.iso8601('2013-04-16T04:36:22.762Z'))
  end

  it "should return empty schedule if revision does not involve state change" do
    schedule = @revs_parser.parse(['2013-04-16T04:36:22.762Z | blah blah blah'])
    schedule.should be_empty
  end
end