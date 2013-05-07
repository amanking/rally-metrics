require 'date'

class UnitOfWork
  attr_reader :id, :name, :estimate

  def initialize(id, name, estimate, timeline = [])
    @id = id
    @name = name
    @estimate = estimate.to_f
    @time_spent = time_spent_per_stage(timeline)
  end

  def dev_days
    days_in(:dev)
  end

  def qa_days
    days_in(:qa)
  end

  def to_s
    <<-STR
      Id : #{@id}
      Name : #{@name}
      Time spent: #{@time_spent.map { |t| "{#{t[0]} : #{t[1]}}" }.join(' , ')}
    STR
  end

  private

  def days_in(stage)
    @time_spent.find_all { |tuple| tuple[0] == stage }.inject(0) { |sum, tuple| sum + tuple[1] }
  end

  def time_spent_per_stage(timeline)
    sorted_timeline = timeline.sort_by { |t| t[1] }

    dates = sorted_timeline.collect { |t| t[1] }
    shifted_dates = dates.push(DateTime.now).drop(1)

    time_spent = shifted_dates.zip(dates).map { |pair| date_diff_rounded(pair[0], pair[1]) }
    sorted_timeline.collect { |t| t[0] }.zip(time_spent)
  end

  def date_diff_rounded(date1, date2)
    (date1 - date2).to_f.round(1)
  end
end