= Mirrored

Mirrored is a really easy to use wrapper for the delicious api (http://del.icio.us/help/api) and magnolia's mirrored version (http://wiki.ma.gnolia.com/Mirror%27d_API).

== Install

	sudo gem install mirrored -y
	
== Usage

1. Setup your connection to either :magnolia or :delicious.

	Mirrored::Base.establish_connection(:magnolia, 'jnunemaker', 'password')

2. Work the mirrored classes (Post, Tag, Update and Date)	

	# => posts tagged ruby
	Mirrored::Post.find(:get, :tag => 'ruby')
	
You can also manipulate tags, find out when your last update was and see information about your posting habits. See the rubyforge page for more information (http://mirrored.rubyforge.org).