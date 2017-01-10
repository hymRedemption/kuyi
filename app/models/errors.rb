module Errors
  class TimeRangeError < ArgumentError; end
  class InvalidDate < ArgumentError; end
  class InvalidDateRange < ArgumentError; end
  class NotMeetingRules < ArgumentError; end
end
