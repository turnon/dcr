require 'test_helper'

class DcrTest < Minitest::Test

  class Cat
    def meow
      'meow'
    end
  end

  class Dog
    def bark
      'bark'
    end
  end

  class Fish
    def swim n
      'swim' * n
    end
  end

  class Bird
    def fly
      'fly'
    end

    def eat
      'eat'
    end
  end

  def test_that_it_has_a_version_number
    refute_nil ::Dcr::VERSION
  end

  def test_parse_method_name_from_block
    method_name = Dcr.parse_method_name do |abc|
    end
    assert_equal :abc, method_name
  end

  def test_parse_method_name_from_lambda
    a_lambda = -> efg{}
    method_name = Dcr.parse_method_name a_lambda
    assert_equal :efg, method_name
  end

  def test_decorate_instance_method
    before, after = 0, 2
    old_cat = Cat.new
    Dcr.instance Cat do |meow, *args|
      before = before.succ
      result = meow.call
      after = after.succ
      result * 2
    end
    young_cat = Cat.new

    assert_equal 'meowmeow', old_cat.meow
    assert_equal 'meowmeow', young_cat.meow
    assert_equal 2, before
    assert_equal 4, after
  end

  def test_decorate_singleton_method
    before, after = 0, 2
    old_dog = Dog.new
    Dcr.singleton old_dog do |bark, *args|
      before = before.succ
      result = bark.call
      after = after.succ
      result * 2
    end
    young_dog = Dog.new

    assert_equal 'barkbark', old_dog.bark
    assert_equal 'bark', young_dog.bark
    assert_equal 1, before
    assert_equal 3, after
  end

  def test_decorate_instance_method_with_name_specified_outside_block
    fish = Fish.new
    Dcr.instance Fish, :swim do |method, *args|
      method.call *args
    end
    assert_equal 'swimswimswim', fish.swim(3)
  end

  def test_decorate_singleton_method_with_name_specified_outside_block
    fish = Fish.new
    Dcr.singleton fish, :swim do |method, *args|
      method.call *args
    end
    assert_equal 'swimswim', fish.swim(2)
  end

  def test_list_decorate_history_of_instance_method
    bird = Bird.new
    first_dcr = __LINE__ + 1
    Dcr.instance Bird, :fly do |method|
    end
    second_dcr = __LINE__ + 1
    Dcr.instance Bird, :fly do |method|
    end
    third_dcr = __LINE__ + 1
    Dcr.instance Bird, :eat do |method|
    end

    assert_equal [[__FILE__, first_dcr], [__FILE__, second_dcr]], Dcr.list(Bird, :fly)
    assert_equal [[__FILE__, third_dcr]], Dcr.list(Bird, :eat)
  end

  def test_list_decorate_history_of_singleton_method
    bird = Bird.new
    first_dcr = __LINE__ + 1
    Dcr.singleton bird, :fly do |method|
    end
    second_dcr = __LINE__ + 1
    Dcr.singleton bird, :fly do |method|
    end
    third_dcr = __LINE__ + 1
    Dcr.singleton bird, :eat do |method|
    end

    assert_equal [[__FILE__, first_dcr], [__FILE__, second_dcr]], Dcr.list(bird, :fly)
    assert_equal [[__FILE__, third_dcr]], Dcr.list(bird, :eat)
  end
end
