require 'test_helper'
require 'dcr/singleton_method_history'

class SingletonMethodHistoryCommitTest < Minitest::Test

  class Dog
    def bark
      'bark'
    end
  end

  def test_commit
    before, after = 0, 2
    old_dog = Dog.new
    hist = Dcr::SingletonMethodHistory.new old_dog
    hist.commit :bark do |method, *args|
      before = before.succ
      result = method.call
      after = after.succ
      result * 2
    end
    young_dog = Dog.new

    assert_equal 'barkbark', old_dog.bark
    assert_equal 'bark', young_dog.bark
    assert_equal 1, before
    assert_equal 3, after
  end

end
