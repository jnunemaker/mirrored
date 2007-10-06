require File.dirname(__FILE__) + '/test_helper.rb'

class TestUpdate < Test::Unit::TestCase
  
  def setup
    Mirrored::Base.establish_connection(:delicious, 'jnunemaker', 'password')
  end
  
  test 'should find last updated time' do
    FakeWeb.register_uri(URI.join(Mirrored::Base.api_url, 'posts/update'), :string => %q{<update time="2007-10-05T14:59:02Z" />})
    assert_equal Time.utc(2007, 10, 05, 14, 59, 02), Mirrored::Update.last
  end
  
  test 'should not bomb' do
    FakeWeb.register_uri(URI.join(Mirrored::Base.api_url, 'posts/update'), :string => "")
    assert_equal '', Mirrored::Update.last
  end
end