module Mirrored
  
  class InvalidService < Exception; end
  class ConnectionNotSet < Exception; end
  
  API_URL = {:delicious => 'https://api.del.icio.us/v1', :magnolia => 'https://ma.gnolia.com/api/mirrord/v1'}
  
  class Base #:nodoc:
    class << self
      def establish_connection(s, u, p)
        remove_connection
        raise InvalidService unless valid_service?(s)
        @@service = s
        @@connection = Connection.new(api_url, :username => u, :password => p)
      end
      
      def remove_connection
        @@service, @@connection = nil, nil
      end
      
      def valid_service?(s)
        s = s.nil? ? '' : s
        API_URL.keys.include?(s)
      end
      
      def api_url
        API_URL[@@service]
      end
      
      def service
        @@service
      end
      
      def connection
        @@connection
      end
    end
    
    private
      def ensure_connection_set
        raise ConnectionNotSet if self.class.connection.nil? || self.class.service.nil?
      end
  end
end