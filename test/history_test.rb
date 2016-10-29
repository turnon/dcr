require 'test_helper'

class HistoryTest < Minitest::Test

  class Bird
    def fly
      'fly'
    end

    def eat
      'eat'
    end
  end

  def test_list_decorate_history_of_instance_method
    dcr_1 = __LINE__ + 1
    Dcr.instance Bird, :fly do |method|
    end
    dcr_2 = __LINE__ + 1
    Dcr.instance Bird, :fly do |method|
    end
    dcr_3 = __LINE__ + 1
    Dcr.instance Bird, :fly do |method|
    end
    dcr_4 = __LINE__ + 1
    Dcr.instance Bird, :eat do |method|
    end

    assert_equal [[__FILE__, dcr_3], [__FILE__, dcr_2], [__FILE__, dcr_1]], Dcr.list(Bird, :fly)
    assert_equal [[__FILE__, dcr_4]], Dcr.list(Bird, :eat)
  end

  def test_list_decorate_history_of_singleton_method
    bird = Bird.new
    idcr_1 = __LINE__ + 1
    Dcr.singleton bird, :fly do |method|
    end
    idcr_2 = __LINE__ + 1
    Dcr.singleton bird, :fly do |method|
    end
    idcr_3 = __LINE__ + 1
    Dcr.singleton bird, :fly do |method|
    end
    idcr_4 = __LINE__ + 1
    Dcr.singleton bird, :eat do |method|
    end

    assert_equal [[__FILE__, idcr_3], [__FILE__, idcr_2], [__FILE__, idcr_1]], Dcr.list(bird, :fly)
    assert_equal [[__FILE__, idcr_4]], Dcr.list(bird, :eat)
  end

end
