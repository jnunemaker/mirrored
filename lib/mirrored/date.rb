module Mirrored
  class Date < Base
    attr_accessor :count, :date
    
    class << self
      def new_from_xml(xml) #:nodoc:
        d       = Date.new
        d.date  = ::Date.parse((xml)['date'])
        d.count = (xml)['count']
        d
      end
      
      # Does all the hard work finding the dates you have posted and how many posts on those days.
      #
      # Usage:
      #   Mirrored::Date.find(:all)                 # => finds all dates you have posted with counts for each day
      #   Mirrored::Date.find(:all, :tag => 'ruby') # => finds all dates you have posted something tagged ruby with counts for each day
      def find(*args)
        raise ArgumentError, "First argument must be symbol (:all)" unless args.first.kind_of?(Symbol)
        params = args.extract_options!
        params = params == {} ? nil : params
        
        doc = Hpricot::XML(connection.get("posts/dates", params))
        (doc/:date).inject([]) { |elements, el| elements << new_from_xml(el); elements }
      end
    end
  end
end