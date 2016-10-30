require 'test_helper'
require 'dcr/instance_method_history'

class RollbackInstanceMethodHistoryTest < Minitest::Test

  class Bird
    def fly
      'fly'
    end
  end

  def test_rollback_instance_method
    hist = Dcr::InstanceMethodHistory.new Bird
    dcr_1 = __LINE__ + 1
    hist.commit(:fly){ |method| 1 }
    dcr_2 = __LINE__ + 1
    hist.commit(:fly){ |method| 2 }
    dcr_3 = __LINE__ + 1
    hist.commit(:fly){ |method| 3 }
    dcr_4 = __LINE__ + 1
    hist.commit(:fly){ |method| 4 }

    bird = Bird.new

    hist.rollback :fly
    assert_equal [[__FILE__, dcr_3], [__FILE__, dcr_2], [__FILE__, dcr_1]], hist.list(:fly)
    assert_equal 3, bird.fly

    hist.rollback :fly
    assert_equal [[__FILE__, dcr_2], [__FILE__, dcr_1]], hist.list(:fly)
    assert_equal 2, bird.fly

    hist.rollback_all :fly
    assert_equal [], hist.list(:fly)
    assert_equal 'fly', bird.fly

    assert_raises(NoMethodError) do
      hist.rollback :fly
    end
    assert_equal [], hist.list(:fly)
    assert_equal 'fly', bird.fly

    assert_raises(NoMethodError) do
      hist.rollback :fly
    end
    assert_equal [], hist.list(:fly)
    assert_equal 'fly', bird.fly
  end

end
