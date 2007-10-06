require File.dirname(__FILE__) + '/test_helper.rb'

class TestBase < Test::Unit::TestCase
  
  def setup
    Mirrored::Base.remove_connection
  end
  
  test 'should know service' do
    Mirrored::Base.establish_connection(:delicious, 'jnunemaker', 'password')
    assert_equal :delicious, Mirrored::Base.service
  end
  
  test 'should allow using valid service' do
    assert_nothing_raised do
      Mirrored::Base.establish_connection(:delicious, 'jnunemaker', 'password')
      Mirrored::Base.establish_connection(:magnolia, 'jnunemaker', 'password')
    end
  end
  
  test 'should not allowing using invalid service' do
    assert_raises(Mirrored::InvalidService) do
      Mirrored::Base.establish_connection(:funkychicken, 'jnunemaker', 'password')
    end
  end
  
  test 'should find correct api url based on service' do
    Mirrored::Base.establish_connection(:delicious, 'jnunemaker', 'password')
    assert_equal 'https://api.del.icio.us/v1', Mirrored::Base.api_url
    Mirrored::Base.establish_connection(:magnolia, 'jnunemaker', 'password')
    assert_equal 'https://ma.gnolia.com/api/mirrord/v1', Mirrored::Base.api_url
  end
end