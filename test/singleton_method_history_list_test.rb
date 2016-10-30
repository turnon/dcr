require 'test_helper'
require 'dcr/singleton_method_history'

class SingletonMethodHistoryTest < Minitest::Test

  class Bird
    def fly
      'fly'
    end

    def eat
      'eat'
    end
  end

  def test_list
    hist = Dcr::SingletonMethodHistory.new Bird.new
    dcr_1 = __LINE__ + 1
    hist.commit :fly do |method|
    end
    dcr_2 = __LINE__ + 1
    hist.commit :fly do |method|
    end
    dcr_3 = __LINE__ + 1
    hist.commit :fly do |method|
    end
    dcr_4 = __LINE__ + 1
    hist.commit :eat do |method|
    end

    assert_equal [[__FILE__, dcr_3], [__FILE__, dcr_2], [__FILE__, dcr_1]], hist.list(:fly)
    assert_equal [[__FILE__, dcr_4]], hist.list(:eat)
  end
end
