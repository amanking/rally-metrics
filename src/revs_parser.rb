require 'date'

class RevsParser
  @@REV_TEXT_REGEX = /SCHEDULE STATE changed from \[(?<from>.+)\] to \[(?<to>.+)\]/

  def parse(revs_data)
    raise 'Expecting an array of revision data' unless revs_data.kind_of? Array
    revs_data.map { |rev| parse_rev_data(rev) }.compact
  end

  private

  def parse_rev_data(rev_data)
    date, rev_text = rev_data.split('|').map { |s| s.strip! }
    end_state = end_state(rev_text)

    if end_state.nil?
      nil
    else
      { end_state => DateTime.iso8601(date) }
    end
  end

  def end_state(rev_text)
    match = @@REV_TEXT_REGEX.match(rev_text)

    if match.nil?
      nil
    else
      match[:to]
    end
  end
end