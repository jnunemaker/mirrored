require File.dirname(__FILE__) + '/test_helper.rb'

class TestDate < Test::Unit::TestCase
  
  def setup
    Mirrored::Base.establish_connection(:magnolia, 'jnunemaker', 'password')
  end
  
  test 'should get all dates' do
    data = open(File.join(File.dirname(__FILE__), 'fixtures/xml/dates.xml')).read
    FakeWeb.register_uri(URI.join(Mirrored::Base.api_url, 'posts/dates'), :string => data)
    dates = Mirrored::Date.find(:all)
    assert_equal 663, dates.size
    assert_equal Date.civil(2005, 5, 10), dates.first.date
    assert_equal '87', dates.first.count
  end
  
  test 'should get all dates for tag' do
    data = open(File.join(File.dirname(__FILE__), 'fixtures/xml/dates_for_tag.xml')).read
    FakeWeb.register_uri(URI.join(Mirrored::Base.api_url, 'posts/dates?tag=ruby'), :string => data)
    dates = Mirrored::Date.find(:all, :tag => 'ruby')
    assert_equal 241, dates.size
    assert_equal Date.civil(2006, 2, 8), dates.first.date
    assert_equal '1', dates.first.count
  end
end