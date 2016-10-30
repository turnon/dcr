require 'test_helper'

class RollbackSingletonMethodHistoryTest < Minitest::Test

  class Bird
    def eat
      'eat'
    end
  end

  def test_rollback_singleton_method
    bird = Bird.new
    hist = Dcr::SingletonMethodHistory.new bird

    dcr_1 = __LINE__ + 1
    hist.commit(:eat){ |method| 1 }
    dcr_2 = __LINE__ + 1
    hist.commit(:eat){ |method| 2 }
    dcr_3 = __LINE__ + 1
    hist.commit(:eat){ |method| 3 }
    dcr_4 = __LINE__ + 1
    hist.commit(:eat){ |method| 4 }


    hist.rollback :eat
    assert_equal [[__FILE__, dcr_3], [__FILE__, dcr_2], [__FILE__, dcr_1]], hist.list(:eat)
    assert_equal 3, bird.eat

    hist.rollback :eat
    assert_equal [[__FILE__, dcr_2], [__FILE__, dcr_1]], hist.list(:eat)
    assert_equal 2, bird.eat

    hist.rollback_all :eat
    assert_equal [], hist.list(:eat)
    assert_equal 'eat', bird.eat

    assert_raises(NoMethodError) do
      hist.rollback :eat
    end
    assert_equal [], hist.list(:eat)
    assert_equal 'eat', bird.eat

    assert_raises(NoMethodError) do
      hist.rollback_all :eat
    end
    assert_equal [], hist.list(:eat)
    assert_equal 'eat', bird.eat
  end

end
