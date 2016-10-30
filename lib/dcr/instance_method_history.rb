require 'dcr/history'

module Dcr
  class InstanceMethodHistory < History
    def self.ivar
      :@_dcr_im
    end

    def klass
      @object
    end

    def commit method_name, &decorator
      unbound_org_method = klass.instance_method method_name

      new_method = lambda do |*args|
	bound_method = unbound_org_method.bind self
	decorator.call bound_method, *args
      end

      klass.class_eval do
	define_method method_name, &new_method
      end

      add_to_track unbound_org_method
    end
  end
end
