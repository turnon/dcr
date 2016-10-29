require "dcr/version"

module Dcr
  class << self
    def instance klass, &decorator
      org_method_name = parse_method_name(decorator)
      unbound_org_method = klass.instance_method org_method_name
      klass.class_eval do
        define_method unbound_org_method.name do |*args|
          bound_method = unbound_org_method.bind self
          decorator.call bound_method, *args
        end
      end
    end

    def singleton object, &decorator
      org_method_name = parse_method_name(decorator)
      org_method = object.method org_method_name
      object.define_singleton_method org_method_name do |*args|
	decorator.call org_method, *args
      end
    end

    def parse_method_name a_lambda=nil, &block
      a_lambda = block_given? ? block : a_lambda
      a_lambda.parameters[0][1]
    end

  end
end
