require 'test_helper'

class RollbackTest < Minitest::Test

  class Bird
    def fly
      'fly'
    end

    def eat
      'eat'
    end
  end

  def test_rollback_instance_method
    dcr_1 = __LINE__ + 1
    Dcr.instance(Bird, :fly){ |method| 1 }
    dcr_2 = __LINE__ + 1
    Dcr.instance(Bird, :fly){ |method| 2 }
    dcr_3 = __LINE__ + 1
    Dcr.instance(Bird, :fly){ |method| 3 }
    dcr_4 = __LINE__ + 1
    Dcr.instance(Bird, :fly){ |method| 4 }

    bird = Bird.new

    rollbacked = Dcr.rollback_instance Bird, :fly
    assert rollbacked
    assert_equal [[__FILE__, dcr_3], [__FILE__, dcr_2], [__FILE__, dcr_1]], Dcr.list(Bird, :fly)
    assert_equal 3, bird.fly

    rollbacked = Dcr.rollback_instance Bird, :fly
    assert rollbacked
    assert_equal [[__FILE__, dcr_2], [__FILE__, dcr_1]], Dcr.list(Bird, :fly)
    assert_equal 2, bird.fly

    rollbacked = Dcr.rollback_all_instance Bird, :fly
    assert rollbacked
    assert_equal [], Dcr.list(Bird, :fly)
    assert_equal 'fly', bird.fly

    assert_raises(NoMethodError) do
      Dcr.rollback_instance Bird, :fly
    end
    assert_equal [], Dcr.list(Bird, :fly)
    assert_equal 'fly', bird.fly

    assert_raises(NoMethodError) do
      Dcr.rollback_all_instance Bird, :fly
    end
    assert_equal [], Dcr.list(Bird, :fly)
    assert_equal 'fly', bird.fly
  end

  def test_rollback_singleton_method
    bird = Bird.new

    dcr_1 = __LINE__ + 1
    Dcr.singleton(bird, :eat){ |method| 1 }
    dcr_2 = __LINE__ + 1
    Dcr.singleton(bird, :eat){ |method| 2 }
    dcr_3 = __LINE__ + 1
    Dcr.singleton(bird, :eat){ |method| 3 }
    dcr_4 = __LINE__ + 1
    Dcr.singleton(bird, :eat){ |method| 4 }


    rollbacked = Dcr.rollback_singleton bird, :eat
    assert rollbacked
    assert_equal [[__FILE__, dcr_3], [__FILE__, dcr_2], [__FILE__, dcr_1]], Dcr.list(bird, :eat)
    assert_equal 3, bird.eat

    rollbacked = Dcr.rollback_singleton bird, :eat
    assert rollbacked
    assert_equal [[__FILE__, dcr_2], [__FILE__, dcr_1]], Dcr.list(bird, :eat)
    assert_equal 2, bird.eat

    rollbacked = Dcr.rollback_all_singleton bird, :eat
    assert rollbacked
    assert_equal [], Dcr.list(bird, :eat)
    assert_equal 'eat', bird.eat

    assert_raises(NoMethodError) do
      Dcr.rollback_singleton bird, :eat
    end
    assert_equal [], Dcr.list(bird, :eat)
    assert_equal 'eat', bird.eat

    assert_raises(NoMethodError) do
      Dcr.rollback_all_ingleton bird, :eat
    end
    assert_equal [], Dcr.list(bird, :eat)
    assert_equal 'eat', bird.eat
  end

end
