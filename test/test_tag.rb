require File.dirname(__FILE__) + '/test_helper.rb'

class TestTag < Test::Unit::TestCase
  
  def setup
    Mirrored::Base.establish_connection(:magnolia, 'jnunemaker', 'password')
  end
  
  test 'should find tags' do
    data = open(File.join(File.dirname(__FILE__), 'fixtures/xml/tags.xml')).read
    FakeWeb.register_uri(URI.join(Mirrored::Base.api_url, 'tags/get'), :string => data)
    tags = Mirrored::Tag.find(:all)
    assert_equal 1229, tags.size
    assert_equal '300', tags.first.name
    assert_equal '2', tags.first.count
  end
  
  test 'should be able to rename tag' do
    data = open(File.join(File.dirname(__FILE__), 'fixtures/xml/tag_rename.xml')).read
    FakeWeb.register_uri(URI.join(Mirrored::Base.api_url, 'tags/rename'), :string => data)
    assert Mirrored::Tag.rename('fart', 'poo')
  end
end