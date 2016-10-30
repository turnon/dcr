require 'test_helper'
require 'dcr/instance_method_history'

class InstanceMethodHistoryCommitTest < Minitest::Test

  class Cat
    def meow
      'meow'
    end
  end

  def test_commit
    before, after = 0, 2
    old_cat = Cat.new
    hist = Dcr::InstanceMethodHistory.new Cat
    hist.commit :meow do |method, *args|
      before = before.succ
      result = method.call
      after = after.succ
      result * 2
    end
    young_cat = Cat.new

    assert_equal 'meowmeow', old_cat.meow
    assert_equal 'meowmeow', young_cat.meow
    assert_equal 2, before
    assert_equal 4, after
  end

end
