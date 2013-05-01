require File.join(File.dirname(__FILE__), "../spec_helper")
require 'revs_parser'

describe "Revisions parser" do
  before(:all) do
    @revs_parser = Rally::RevsParser.new
  end

  it "should parse revision and return dev start time" do
    timeline = @revs_parser.parse(['2013-04-16T04:36:22.762Z | SCHEDULE STATE changed from [Defined] to [In-Progress]'])

    timeline.should have_exactly(1).item
    timeline.first.should eq [:dev, DateTime.iso8601('2013-04-16T04:36:22.762Z')]
  end

  it "should parse multiple revision texts and return timeline" do
    timeline = @revs_parser.parse(
        [
            '2013-04-17T12:00:01Z | SCHEDULE STATE changed from [Completed] to [Accepted]',
            '2013-04-16T12:00:01Z | SCHEDULE STATE changed from [In-Progress] to [Completed]',
            '2013-04-16T04:36:22.762Z | SCHEDULE STATE changed from [Defined] to [In-Progress], IN PROGRESS DATE added [Mon Apr 22 23:24:22 MDT 2013]'
        ])

    timeline.should have_exactly(3).item
    timeline[0].should eq [:done, DateTime.iso8601('2013-04-17T12:00:01Z')]
    timeline[1].should eq [:qa, DateTime.iso8601('2013-04-16T12:00:01Z')]
    timeline[2].should eq [:dev, DateTime.iso8601('2013-04-16T04:36:22.762Z')]
  end

  it "should return empty timeline if revision does not involve state change" do
    schedule = @revs_parser.parse(['2013-04-16T04:36:22.762Z | blah blah blah'])
    schedule.should be_empty
  end
end