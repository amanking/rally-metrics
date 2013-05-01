require File.join(File.dirname(__FILE__), "../spec_helper")
require 'rally'

describe "Rally", :broken => true do
  before(:all) do
    @rally = Rally.new("<user_name>", "<user_pass>", "<workspace_name>", "<project_name>")
  end

  it "should fetch story data for given sprint" do
    @rally.stories_in("<sprint_name>").should have(4).items
  end

  it "should fetch defect data for given sprint" do
    @rally.defects_in("<sprint_name>").should have(4).items
  end
end