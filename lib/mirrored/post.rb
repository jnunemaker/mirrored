module Mirrored
  class Post < Base
    attr_accessor :href, :description, :extended, :hash, :others, :tags, :time, :code, :share
    
    alias :url :href
    alias :url= :href=
    alias :dt :time
    alias :dt= :time=
    
    class << self
      # Creates a new post from an hpricot post instance.
      def new_from_xml(xml) #:nodoc:
        p             = Post.new
        p.href        = (xml)['href']
        p.description = (xml)['description']
        p.extended    = (xml)['extended']
        p.hash        = (xml)['hash']
        p.others      = (xml)['others']
        p.tags        = (xml)['tag']
        p.time        = Time.parse((xml)['time'])
        p
      end
      
      # Does all the hard work finding your posts by various filters and such.
      #
      # Usage:
      #
      # Valid hash options for :get are :tag, :dt and :url. All are optional and can be used in any combination.
      #   Mirrored::Post.find(:get)                                     # => posts
      #   Mirrored::Post.find(:get, :tag => 'ruby')                     # => posts tagged ruby
      #   Mirrored::Post.find(:get, :tag => 'ruby', :dt => '2007-10-05')# => posts tagged ruby on oct. 5, 2007
      #   Mirrored::Post.find(:get, :url => 'http://addictedtonew')     # => posts with url http://addictedtonew
      #
      # Valid hash option for :all is :tag. All are optional and can be used in any combination.
      # Use sparingly according to magnolia and delicious.
      #   Mirrored::Post.find(:all)                                     # => all posts
      #   Mirrored::Post.find(:all, :tag => 'ruby')                     # => all posts for tag ruby
      #
      # Valid hash options for :recent are :tag and :count. All are optional and can be used in any combination.
      #   Mirrored::Post.find(:recent)                                  # most recent posts
      #   Mirrored::Post.find(:recent, :tag => 'ruby')                  # => most recent posts for tag ruby
      #   Mirrored::Post.find(:recent, :tag => 'ruby', :count => '5')   # => 5 most recent posts for tag ruby
      def find(*args)
        raise ArgumentError, "First argument must be symbol (:all or :recent)" unless args.first.kind_of?(Symbol)
        params = args.extract_options!
        params = params == {} ? nil : params
        
        filter = case args.first
        when :recent
          'recent'
        when :all
          'all'
        else
          'get'
        end
        
        doc = Hpricot::XML(connection.get("posts/#{filter}", params))
        (doc/:post).inject([]) { |elements, el| elements << Post.new_from_xml(el); elements }
      end
      
      # Destroys a post by url.
      #
      # Usage:
      #   Mirrored::Post.destroy('http://microsoft.com')  
      #   Mirrored::Post.delete('http://microsoft.com')   # => aliased version
      def destroy(url)
        doc = Hpricot::XML(connection.get('posts/delete', :url => url))
        code = doc.at('result')['code']
        code == 'done' ? true : false
      end
      alias :delete :destroy
    end
    
    # Saves a post to delicious or magnolia.
    #
    # Usage:
    #   p             = Mirrored::Post.new
    #   p.url         = 'http://addictedtonew.com'
    #   p.description = 'Addicted to New by John Nuneamker'
    #   p.extended    = 'Really cool dude'
    #   p.tags        = %w(cool dude ruby)
    #   p.save        # => do not replace if post already exists
    #   p.save(true)  # => replace post if it already exists
    def save(replace=false)
      attrs = to_h.merge((replace) ? {:replace => 'yes'} : {:replace => 'no'})
      puts attrs.inspect
      doc = Hpricot::XML(self.class.connection.get('posts/add', attrs))
      @code = doc.at('result')['code']
      (@code == 'done') ? true : false
    end
    
    def to_h #:nodoc:
      {
        :url         => url, 
        :description => description, 
        :extended    => extended, 
        :tags        => (tags ? tags.map { |t| t.gsub(' ', '_') }.join(' ') : ''),
        :share       => share
      }
    end
    
    # Defaults share to yes
    def share
      @share ? @share : 'yes'
    end
    
    # Makes it so that tags= can take a string or array.
    #
    # Usage:
    #   Mirrored::Post.new.tags = %w(ruby rails sweet)  # => %w(ruby rails sweet)
    #   Mirrored::Post.new.tags = 'ruby rails sweet'    # => %w(ruby rails sweet)
    def tags=(string_or_array)
      if string_or_array.kind_of?(Array)
        @tags = string_or_array
      else
        @tags = string_or_array.split(' ').map { |t| t.gsub('_', ' ') }
      end
    end
  end
end