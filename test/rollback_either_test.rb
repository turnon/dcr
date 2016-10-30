require 'test_helper'

class RollbackEitherTest < Minitest::Test

  class Bird
    def fly
      'fly'
    end

    def eat
      'eat'
    end

  end

  def test_rollback_instance_but_not_singleton
    bird = Bird.new
    Dcr.instance(Bird, :fly){ |method| method.call + ' in sky' }
    Dcr.singleton(bird, :fly){ |method| method.call + ' over sea' }
    assert_equal 'fly in sky over sea', bird.fly

    Dcr.rollback_instance Bird, :fly
    assert_equal 'fly over sea', bird.fly

    Dcr.instance(Bird, :fly){ |method| method.call + 'ing' }
    assert_equal 'flying over sea', bird.fly
  end

  def test_rollback_singleton_but_not_instance
    bird = Bird.new
    Dcr.instance(Bird, :eat){ |method| method.call + ' insect' }
    Dcr.singleton(bird, :eat){ |method| method.call + ' and fish' }
    assert_equal 'eat insect and fish', bird.eat

    Dcr.rollback_singleton bird, :eat
    assert_equal 'eat insect', bird.eat
  end

end
