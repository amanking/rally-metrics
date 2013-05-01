require File.join(File.dirname(__FILE__), "../spec_helper")
require "unit_of_work"

describe "A Unit of work" do
  it "should return correct dev days even if the task moved from dev to done"
  it "should return dev days even if the task is still in progress"
  it "should return dev days as 0 if a task never went in dev"
  it "should return qa days even if the task is still in progress"
  it "should return qa days as 0 if a task never went in qa"
end