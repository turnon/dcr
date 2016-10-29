require "dcr/version"

module Dcr

  TRACE = :@_dcr_trace

  class << self

    def instance klass, org_method_name=nil, &decorator
      org_method_name = parse_method_name(decorator) unless org_method_name
      unbound_org_method = klass.instance_method org_method_name

      new_method = lambda do |*args|
        bound_method = unbound_org_method.bind self
        decorator.call bound_method, *args
      end

      klass.class_eval do
        define_method org_method_name, &new_method
      end

      set_trace klass, org_method_name, new_method
    end

    def singleton object, org_method_name=nil, &decorator
      org_method_name = parse_method_name(decorator) unless org_method_name
      org_method = object.method org_method_name

      new_method = lambda do |*args|
        decorator.call org_method, *args
      end

      object.define_singleton_method org_method_name, &new_method

      set_trace object, org_method_name, new_method
    end

    def parse_method_name a_lambda=nil, &block
      a_lambda = block_given? ? block : a_lambda
      a_lambda.parameters[0][1]
    end

    def set_trace ko, name, method
      file, line, _ =  caller[1].split(':')
      get_trace(ko, name).unshift [method, file, line.to_i]
    end

    def get_trace ko, method
      ko.instance_variable_set(TRACE, {}) unless ko.instance_variable_defined? TRACE
      trace = ko.instance_variable_get TRACE
      trace[method] ||= []
    end

    def list ko, method
      get_trace(ko, method).
        map do |method, file, line|
          [file, line]
        end
    end

  end
end
