require 'dcr/history'

module Dcr
  class SingletonMethodHistory < History
    def self.ivar
      :@_dcr_sm
    end

    attr_reader :object

    def commit method_name, &decorator
      org_method = object.method method_name

      new_method = lambda do |*args|
	decorator.call org_method, *args
      end

      object.define_singleton_method method_name, &new_method

      add_to_track org_method
    end

    def rollback method_name
      org_method = pop_last_track method_name
      object.define_singleton_method method_name, org_method
    end

    def rollback_all method_name
      org_method = pop_all_track method_name
      object.define_singleton_method method_name, org_method
    end
  end
end
