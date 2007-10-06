require File.dirname(__FILE__) + '/test_helper.rb'

class TestPost < Test::Unit::TestCase
  
  def setup
    Mirrored::Base.establish_connection(:magnolia, 'jnunemaker', 'password')
  end
  
  test 'should get posts' do
    data = open(File.join(File.dirname(__FILE__), 'fixtures/xml/posts.xml')).read
    FakeWeb.register_uri(URI.join(Mirrored::Base.api_url, 'posts/get'), :string => data)
    posts = Mirrored::Post.find(:get)
    assert_equal 3, posts.size
    first = posts.first
    assert_equal 'http://codersifu.blogspot.com/2007/10/restful-pdf-on-rails-20.html', first.href
    assert_equal 'CoderSifu: RESTful PDF on Rails 2.0', first.description
    assert_equal 'A nice simple example of responding to the pdf format using rails rest-fulness.', first.extended
    assert_equal '580485cf09ea39f3cb4a1182390a6dfb', first.hash
    assert_equal '1', first.others
    assert_equal ['ruby on rails', 'rest', 'pdf', 'plugins', 'railstips'], first.tags
    assert_equal Time.utc(2007, 10, 05, 14, 59, 02), first.time
  end
  
  test 'should get posts by tag' do
    data = open(File.join(File.dirname(__FILE__), 'fixtures/xml/posts_by_tag.xml')).read
    FakeWeb.register_uri(URI.join(Mirrored::Base.api_url, 'posts/get?tag=ruby'), :string => data)
    posts = Mirrored::Post.find(:get, :tag => 'ruby')
    assert_equal 1, posts.size
  end
  
  test 'should get posts by date' do
    data = open(File.join(File.dirname(__FILE__), 'fixtures/xml/posts_by_date.xml')).read
    FakeWeb.register_uri(URI.join(Mirrored::Base.api_url, 'posts/get?dt=2007-10-05'), :string => data)
    posts = Mirrored::Post.find(:get, :dt => '2007-10-05')
    assert_equal 2, posts.size
  end
  
  test 'should get posts by url' do
    data = open(File.join(File.dirname(__FILE__), 'fixtures/xml/posts_by_url.xml')).read
    FakeWeb.register_uri(URI.join(Mirrored::Base.api_url, 'posts/get?url=http://www.railsontherun.com/2007/10/4/sexy-charts-in-less-than-5-minutes'), :string => data)
    posts = Mirrored::Post.find(:get, :url => 'http://www.railsontherun.com/2007/10/4/sexy-charts-in-less-than-5-minutes')
    assert_equal 1, posts.size
  end
  
  test 'should filter by recent posts' do
    data = open(File.join(File.dirname(__FILE__), 'fixtures/xml/recent_posts.xml')).read
    FakeWeb.register_uri(URI.join(Mirrored::Base.api_url, 'posts/recent'), :string => data)
    posts = Mirrored::Post.find(:recent)
    assert_equal 15, posts.size
  end
  
  test 'should filter recent posts by tag' do
    data = open(File.join(File.dirname(__FILE__), 'fixtures/xml/recent_posts_by_tag.xml')).read
    FakeWeb.register_uri(URI.join(Mirrored::Base.api_url, 'posts/recent?tag=ruby'), :string => data)
    posts = Mirrored::Post.find(:recent, :tag => 'ruby')
    assert_equal 15, posts.size
  end
  
  test 'should filter recent posts by tag and count' do
    data = open(File.join(File.dirname(__FILE__), 'fixtures/xml/recent_posts_by_tag_and_count.xml')).read
    # TODO: make fake web realize that tag=ruby&count=5 is the same as count=5&tag=ruby
    FakeWeb.register_uri(URI.join(Mirrored::Base.api_url, 'posts/recent?tag=ruby&count=5'), :string => data)
    FakeWeb.register_uri(URI.join(Mirrored::Base.api_url, 'posts/recent?count=5&tag=ruby'), :string => data)
    posts = Mirrored::Post.find(:recent, :tag => 'ruby', :count => 5)
    assert_equal 5, posts.size
  end
  
  test 'should get all posts' do
    data = open(File.join(File.dirname(__FILE__), 'fixtures/xml/all_posts.xml')).read
    FakeWeb.register_uri(URI.join(Mirrored::Base.api_url, 'posts/all'), :string => data)
    posts = Mirrored::Post.find(:all)
    assert_equal 2607, posts.size
  end
  
  test 'should get all posts for tag' do
    data = open(File.join(File.dirname(__FILE__), 'fixtures/xml/all_posts_by_tag.xml')).read
    FakeWeb.register_uri(URI.join(Mirrored::Base.api_url, 'posts/all?tag=actionscript'), :string => data)
    posts = Mirrored::Post.find(:all, :tag => 'actionscript')
    assert_equal 24, posts.size
  end
  
  test 'should be able to convert post to hash' do
    data = open(File.join(File.dirname(__FILE__), 'fixtures/xml/posts_by_url.xml')).read
    FakeWeb.register_uri(URI.join(Mirrored::Base.api_url, 'posts/get?url=http://www.railsontherun.com/2007/10/4/sexy-charts-in-less-than-5-minutes'), :string => data)
    posts = Mirrored::Post.find(:get, :url => 'http://www.railsontherun.com/2007/10/4/sexy-charts-in-less-than-5-minutes')
    post = posts.first
    post_hash = {
      :description => 'Easy charting with amcharts and ruby on rails.',
      :extended    => 'Rails on the Run - Sexy charts in less than 5 minutes',
      :tags        => 'charts ruby_on_rails railstips',
      :url         => 'http://www.railsontherun.com/2007/10/4/sexy-charts-in-less-than-5-minutes',
      :share       => 'yes'
    }
    assert_equal post_hash.keys.map { |k| k.to_s }.sort, post.to_h.keys.map { |k| k.to_s }.sort
    assert_equal post_hash.values.sort, post.to_h.values.sort
  end
  
  # TODO: Figure out best way to test this. Fakeweb craps out because of hash keys not being ordered correctly in url. I don't feel like thinking about it now.
  # test 'should be able to add post' do
  #   data = open(File.join(File.dirname(__FILE__), 'fixtures/xml/add_post_done.xml')).read
  #   FakeWeb.register_uri(URI.join(Mirrored::Base.api_url, 'posts/add?'), :string => data)
  #   p             = Mirrored::Post.new
  #   p.url         = 'http://addictedtonew.com'
  #   p.description = 'Addicted to New by John Nuneamker'
  #   p.dt          = Time.now.utc
  #   p.extended    = 'Really cool dude'
  #   p.tags        = %w(cool dude ruby)
  #   p.save(false)
  # end
  
  test 'should know if destroy succeeded' do
    data = open(File.join(File.dirname(__FILE__), 'fixtures/xml/delete_post.xml')).read
    FakeWeb.register_uri(URI.join(Mirrored::Base.api_url, 'posts/delete?url=http://www.railsontherun.com/2007/10/4/sexy-charts-in-less-than-5-minutes'), :string => data)
    assert Mirrored::Post.destroy('http://www.railsontherun.com/2007/10/4/sexy-charts-in-less-than-5-minutes')
  end
  
  test 'should also know if aliased delete succeeded' do
    data = open(File.join(File.dirname(__FILE__), 'fixtures/xml/delete_post.xml')).read
    FakeWeb.register_uri(URI.join(Mirrored::Base.api_url, 'posts/delete?url=http://www.railsontherun.com/2007/10/4/sexy-charts-in-less-than-5-minutes'), :string => data)
    assert Mirrored::Post.delete('http://www.railsontherun.com/2007/10/4/sexy-charts-in-less-than-5-minutes')
  end
  
  test 'should know if destroy failed' do
    data = open(File.join(File.dirname(__FILE__), 'fixtures/xml/delete_post_failed.xml')).read
    FakeWeb.register_uri(URI.join(Mirrored::Base.api_url, 'posts/delete?url=http://www.railsontherun.com/2007/10/4/sexy-charts-in-less-than-5-minutes'), :string => data)
    assert ! Mirrored::Post.destroy('http://www.railsontherun.com/2007/10/4/sexy-charts-in-less-than-5-minutes')
  end
  
  test 'should also know if aliased delete failed' do
    data = open(File.join(File.dirname(__FILE__), 'fixtures/xml/delete_post_failed.xml')).read
    FakeWeb.register_uri(URI.join(Mirrored::Base.api_url, 'posts/delete?url=http://www.railsontherun.com/2007/10/4/sexy-charts-in-less-than-5-minutes'), :string => data)
    assert ! Mirrored::Post.delete('http://www.railsontherun.com/2007/10/4/sexy-charts-in-less-than-5-minutes')
  end
  
end