module Mirrored
  class Update < Base
    # Returns a ruby time object that is equal to the last time you posted something. If you haven't posted anything it returns an empty string (probably).
    #
    # Usage:
    #   Mirrored::Update.last # => a ruby time object in UTC
    def self.last
      result = connection.get('posts/update')
      doc    = Hpricot::XML(result)
      update = doc.at('update')
      update ? Time.parse(update['time']) : ''
    end
  end
end