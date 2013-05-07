require 'date'

module Rally

  class RevsParser
    @@ACTIVITY_MAP = {
        'In-Progress' => :dev,
        'Completed' => :qa,
        'Accepted' => :done
    }

    def parse(revs_data)
      raise 'Expecting an array of revision data' unless revs_data.kind_of? Array
      revs_data.map { |rev|
        parse_rev_data(rev)
      }.compact
    end

    private

    def parse_rev_data(rev_data)
      date, rev_text = rev_data.split('|').map { |s| s.strip! }
      end_state = end_state(rev_text)

      if end_state.nil?
        nil
      else
        [end_state, DateTime.iso8601(date)]
      end
    end

    def end_state(rev_text)
      match = Rally::REV_TEXT_REGEX.match(rev_text)
      if match.nil? then
        nil
      else
        @@ACTIVITY_MAP[match[:to]]
      end
    end
  end
end
