require "dcr/version"

module Dcr

  History = :@_dcr_history

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

      set_history klass, unbound_org_method
    end

    def singleton object, org_method_name=nil, &decorator
      org_method_name = parse_method_name(decorator) unless org_method_name
      org_method = object.method org_method_name

      new_method = lambda do |*args|
        decorator.call org_method, *args
      end

      object.define_singleton_method org_method_name, &new_method

      set_history object, org_method
    end

    def parse_method_name a_lambda=nil, &block
      a_lambda = block_given? ? block : a_lambda
      a_lambda.parameters[0][1]
    end

    def set_history ko, method
      file, line, _ =  caller[1].split(':')
      get_history(ko, method.name).unshift [method, file, line.to_i]
    end

    def get_history ko, method_name
      ko.instance_variable_set(History, {}) unless ko.instance_variable_defined? History
      history = ko.instance_variable_get History
      history[method_name] ||= []
    end

    def list ko, method_name
      get_history(ko, method_name).
        map do |method, file, line|
          [file, line]
        end
    end

    def rollback_instance klass, method_name
      org_method = last_buried klass, method_name
      klass.send :define_method, method_name, org_method
    end

    def rollback_all_instance klass, method_name
      history = get_history klass, method_name
      raise NoMethodError,
	"no more history for method: #{method_name}" if history.empty?
      history.size.times do
        rollback_instance klass, method_name
      end
    end

    def rollback_singleton object, method_name
      org_method = last_buried object, method_name
      object.define_singleton_method method_name, org_method
    end

    def rollback_all_singleton object, method_name
      history = get_history object, method_name
      raise NoMethodError,
	"no more history for method: #{method_name}" if history.empty?
      history.size.times do
        rollback_singleton object, method_name
      end
    end

    def last_buried ko, method_name
      history = get_history ko, method_name
      raise NoMethodError,
	"no more history for method: #{method_name}" if history.empty?
      history.shift[0]
    end
  end
end
