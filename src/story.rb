require 'date'

class Story
  attr_reader :id, :name, :estimate

  def initialize(id, name, estimate, timeline = [])
    @id = id
    @name = name
    @estimate = estimate.to_f
    @timeline = timeline
  end

  def dev_days
    days_between(:dev, :qa)
  end

  def qa_days
    days_between(:qa, :done)
  end

  def to_s
    <<-STR
      Id : #{@id}
      Name : #{@name}
      Timeline:
      #{@timeline.join("\n")}
    STR
  end

  private

  def days_between(act1, act2)
    start = @timeline.find { |act| act[0] == act1 }
    finish = @timeline.find { |act| act[0] == act2 }
    date_diff_rounded(finish[1], start[1])
  end

  def date_diff_rounded(date1, date2)
    (date1 - date2).to_f.round(1)
  end
end